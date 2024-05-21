import 'dart:isolate';
import 'package:stu/src/audio/audio_permission.dart';

import 'looper_app.dart';

SendPort _audioSendPort;
Isolate _audioIsolate;

enum LooperMessage {
  sendData,
  startRecording,
  stopRecording,
  undoPreviosTake,
  reset,
  muteLoop,
  unmuteLoop,
  disposeStream,
}

Future<bool> createLooperApp() async {
  bool mic = await requestMicPermission();

  if(!mic) return false;

  ReceivePort receivePort = ReceivePort();

  _audioIsolate = await Isolate.spawn(
    _audioIsolateEntryPoint,
    receivePort.sendPort,
  );

  _audioSendPort = await receivePort.first;

  return true;
}

void _audioIsolateEntryPoint(SendPort callerSendPort) {
  ReceivePort audioIsolateReceivePort = ReceivePort();

  callerSendPort.send(audioIsolateReceivePort.sendPort);

  LooperApp app = LooperApp();

  audioIsolateReceivePort.listen((dynamic message) {
    if (message is CrossIsolatesMessage<LooperMessage>) {
      switch (message.message) {
        case LooperMessage.sendData:
          message.sender.send(app.toData());
          break;
        case LooperMessage.startRecording:
          app.startRecording();
          message.sender.send(0);
          break;
        case LooperMessage.stopRecording:
          app.stopRecording();
          message.sender.send(0);
          break;
        case LooperMessage.undoPreviosTake:
          app.undoPreviousTake();
          message.sender.send(0);
          break;
        case LooperMessage.reset:
          app.reset();
          message.sender.send(0);
          break;
        case LooperMessage.muteLoop:
          app.muteLoop();
          message.sender.send(0);
          break;
        case LooperMessage.unmuteLoop:
          app.unmuteLoop();
          message.sender.send(0);
          break;
        case LooperMessage.disposeStream:
          app.disposeStream();
          message.sender.send(0);
          break;
      }
    }
  });
}

Future<dynamic> getLooperAppData() {
  ReceivePort port = ReceivePort();

  _audioSendPort?.send(
    CrossIsolatesMessage(
      sender: port.sendPort,
      message: LooperMessage.sendData,
    ),
  );

  return port.first;
}

Future<void> perform(LooperMessage message) async {
  ReceivePort port = ReceivePort();

  _audioSendPort?.send(
    CrossIsolatesMessage(
      sender: port.sendPort,
      message: message,
    ),
  );

  await port.first;
}


void disposeAudioThread() {
  _audioIsolate?.kill(priority: Isolate.immediate);
  _audioIsolate = null;
}

class CrossIsolatesMessage<T> {
  final SendPort sender;
  final T message;

  CrossIsolatesMessage({
    this.sender,
    this.message,
  });
}
