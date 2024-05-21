import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';
import 'oboe_ffi.dart';
import 'audio_buffer.dart';

typedef AudioCallback = void Function(AudioBuffer input, AudioBuffer output);
typedef AudioStreamInit = void Function(
  int sampleRate,
  int framesPerCallback,
  int channelCount,
);

class AudioEngine {
  /// Creates an input / output audio stream.
  ///
  /// The requested sample rate, frames per callback, and channel
  /// count for the stream won't nessesarily produce a stream of
  /// these exact values.
  ///
  /// The [sampleRate], [framesPerCallback], and [channelCount]
  /// attributes must be greater than 0.
  AudioEngine({
    int sampleRate = 44100,
    int framesPerCallback = 516,
    int channelCount = 2,
    int latencyFactor = 5,
    AudioStreamInit onAudioStreamInit,
    @required AudioCallback onAudioCallback,
  })  : assert(sampleRate > 0),
        assert(framesPerCallback > 0),
        assert(channelCount > 0),
        assert(latencyFactor > 0),
        _nativeInstance = Oboeffi().createStream(
          sampleRate,
          framesPerCallback,
          channelCount,
          latencyFactor,
        ) {
    assert(_nativeInstance != nullptr);

    _outputBuffer = AudioBuffer(
      numFrames: this.framesPerCallback,
      numChannels: this.channelCount,
    );

    _onAudioCallback = onAudioCallback;

    _muteCallback = true;

    _skipProcessing = false;

    _timer = Timer.periodic(
      Duration(
        microseconds: (this.framesPerCallback /
                this.sampleRate *
                Duration.microsecondsPerSecond)
            .floor(),
      ),
      (timer) {
        _callback();
      },
    );

    if(onAudioStreamInit != null) {
      onAudioStreamInit(this.sampleRate, this.framesPerCallback, this.channelCount);
    }
  }

  final Pointer<Void> _nativeInstance;

  int get sampleRate => Oboeffi().getSampleRate(_nativeInstance);

  int get framesPerCallback => Oboeffi().getFramesPerCallback(_nativeInstance);

  int get channelCount => Oboeffi().getChannelCount(_nativeInstance);

  int get latencyFactor => Oboeffi().getLatencyFactor(_nativeInstance);

  AudioBuffer _outputBuffer;

  AudioBuffer _inputBuffer;

  AudioCallback _onAudioCallback;

  Timer _timer;

  bool _muteCallback;

  bool _skipProcessing;

  int _callbacksToSkip = 10;

  final int _defaultCallbacksToSkip = 10;

  void dispose() {
    Oboeffi().disposeStream(_nativeInstance);
    _timer.cancel();
    print("engine disposed");
  }

  void startStream() {
    _muteCallback = false;
    _callbacksToSkip = _defaultCallbacksToSkip;
    Oboeffi().startStream(_nativeInstance);
  }

  void stopStream() {
    _muteCallback = true;
    Oboeffi().startStream(_nativeInstance);
  }

  void _callback() {
    if (_muteCallback) return;
    if (_callbacksToSkip > 0) {
      _callbacksToSkip--;
      return;
    }

    if (!_skipProcessing) {
      _process();
    } else {
      _skipProcessing = false;
    }

    int samplesPushed = _sendOutputBuffer();
    if (samplesPushed == 0) {
      //wait for the next frame and try to send the buffer again
      _skipProcessing = true;
    }
  }

  void _process() {
    _getInputBuffer();
    _outputBuffer.clean();
    _onAudioCallback(_inputBuffer, _outputBuffer);
  }

  void _getInputBuffer() {
    int length = framesPerCallback * channelCount;
    final list = allocate<Float>(count: length);

    int samplesRead = Oboeffi().getFromInputBuffer(
      _nativeInstance,
      list,
      length,
    );

    int framesRead = samplesRead ~/ channelCount;

    _inputBuffer = AudioBuffer.fromRaw(
      numChannels: channelCount,
      numFrames: framesRead,
      raw: list.asTypedList(framesRead * channelCount).toList(growable: false),
    );

    free(list);
  }

  int _sendOutputBuffer() {
    int length = _outputBuffer.raw.length;

    final list = allocate<Float>(count: length)
      ..asTypedList(length).setAll(0, _outputBuffer.raw);

    int samplesPushed = Oboeffi().pushToOutputBuffer(
      _nativeInstance,
      list,
      length,
    );

    free(list);
    return samplesPushed;
  }
}
