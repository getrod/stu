import 'dart:isolate';
import 'dart:math';
import 'audio_permission.dart';
import 'audio_engine.dart';
import 'audio_buffer.dart';

SendPort _audioSendPort;
Isolate _audioIsolate;

void initializeAudioEngine() {
  requestMicPermission();
  createAudioIsolate();
}

void createAudioIsolate() async {
	ReceivePort receivePort = ReceivePort();

	_audioIsolate = await Isolate.spawn(
        	_audioIsolateEntryPoint,
        	receivePort.sendPort,
    	);
	
	_audioSendPort = await receivePort.first;
}

void _audioIsolateEntryPoint(SendPort callerSendPort) {
	ReceivePort audioIsolateReceivePort = ReceivePort();

	callerSendPort.send(audioIsolateReceivePort.sendPort);

  Ocs osc;
  AudioEngine _stream = AudioEngine(
    channelCount: 2,
    framesPerCallback: 516,
    latencyFactor: 5,
    onAudioStreamInit: (sampleRate, framesPerCallback, channelCount) {
      osc = Ocs(sampleRate: sampleRate);
    },
    onAudioCallback: (input, output) {
      // for(int channel = 0; channel < output.numChannels; channel++) {
      //   for(int frame = 0; frame < output.numFrames; frame++) {
      //     double sample = input.getChannel(channel).getSample(frame);
      //     output.getChannel(channel).setSample(frame, sample);
      //   }
      // }
      osc.processBlock(output);
    },
  );
  //osc.sampleRate = _stream.sampleRate;

	audioIsolateReceivePort.listen((dynamic message) {
		if (message == 0) {
      _stream?.startStream();
    } else if (message == 1){
      _stream?.stopStream();
    } else if (message is CrossIsolatesMessage<int>) {
      _stream?.dispose();
      message.sender.send(true);
    }
	});
}

void sendAudioIsolateMessage(dynamic message) {
  _audioSendPort?.send(message);
}

Future<dynamic> disposeStream() {
  ReceivePort port = ReceivePort();

  _audioSendPort.send(
    CrossIsolatesMessage<int>(
      sender: port.sendPort,
      message: -1,
    ),
  ); 

  return port.first;
}

void disposeAudioThread() async {
  dynamic val = await disposeStream();
  print("Now disposing audio thread. val: $val");
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

class Ocs {
  Ocs({int sampleRate}) {
    this.sampleRate = sampleRate;
  }

  double _phase1 = 0;
  double _phase2 = 0;

  double get delta1 => _delta1;
  double get delta2 => _delta2;

  double _delta1 = 0;
  double _delta2 = 0;

  set sampleRate(int val) {
    _delta1 = 440 * 2 * pi / val;
    _delta2 = 444 * 2 * pi / val;
  }

  void processBlock(AudioBuffer buffer) {
    for (int frame = 0; frame < buffer.numFrames; frame++) {
      double sample = sin(_phase1);
      buffer.getChannel(0).addSample(frame, sample);
      _phase1 += delta1;
      if (_phase1 >= 2 * pi) {
        _phase1 -= 2 * pi;
      }
    }

    for (int frame = 0; frame < buffer.numFrames; frame++) {
      double sample = sin(_phase2);
      buffer.getChannel(1).addSample(frame, sample);
      _phase2 += delta2;
      if (_phase2 >= 2 * pi) {
        _phase2 -= 2 * pi;
      }
    }
  }
}