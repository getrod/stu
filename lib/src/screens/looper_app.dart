import 'package:stu/src/audio/audio_buffer.dart';
import 'package:stu/src/audio/audio_engine.dart';
import 'dart:math';

class LooperApp {
  LooperApp() {
    _engine = AudioEngine(
      framesPerCallback: 516,
      latencyFactor: 10,
      onAudioCallback: (input, output) {
        if (_recording) {
          _buffer.addAll(input.raw);
          int bufferSeconds =
              (_buffer.length ~/ _engine.channelCount) ~/ _engine.sampleRate;
          if (bufferSeconds >= maxRecordTime.inSeconds) {
            _stopRecording();
          }
        }

        if (firstTrackRecorded) {
          for (int channel = 0; channel < output.numChannels; channel++) {
            for (int frame = 0; frame < output.numFrames; frame++) {
              if (mute) break;
              double sample = _loopTrack
                  .getChannel(channel)
                  .getSample(_framesPlayed + frame);
              output
                  .getChannel(channel)
                  .setSample(frame, /*Random().nextDouble() * 2.0 - 1*/ sample);
            }
          }

          // loop occurs here
          if (_framesPlayed >= _loopTrack.numFrames) {
            _framesPlayed = 0;
            if (_recording) {
              _stopRecording();
              _copyRecordedAudio();
            }
            if (_requestRecord) {
              _startRecording();
              _requestRecord = false;
            }
          }

          _framesPlayed += output.numFrames;

          // // loop occurs here
          // if (_framesPlayed >= _loopTrack.numFrames) {
          //   _framesPlayed = 0;
          //   if (_recording) {
          //     _stopRecording();
          //     _copyRecordedAudio();
          //   }
          //   if (_requestRecord) {
          //     _startRecording();
          //     _requestRecord = false;
          //   }
          // }
        }
      },
    );

    _engine.startStream();
  }
  // LooperApp() {
  //   requestMicPermission().then((mic) {
  //     if (!mic) return;
  //     _engine = AudioEngine(
  //       onAudioCallback: (input, output) {
  //         if (_recording) {
  //           _buffer.addAll(input.raw);
  //           int bufferSeconds =
  //               (_buffer.length ~/ _engine.channelCount) ~/ _engine.sampleRate;
  //           if (bufferSeconds >= maxRecordTime.inSeconds) {
  //             _stopRecording();
  //           }
  //         }

  //         if (firstTrackRecorded) {
  //           for (int channel = 0; channel < output.numChannels; channel++) {
  //             for (int frame = 0; frame < output.numFrames; frame++) {
  //               if (mute) break;
  //               double sample = _loopTrack
  //                   .getChannel(channel)
  //                   .getSample(_framesPlayed + frame);
  //               output.getChannel(channel).setSample(frame, sample);
  //             }
  //           }

  //           _framesPlayed += output.numFrames;

  //           // loop occurs here
  //           if (_framesPlayed >= _loopTrack.numFrames) {
  //             _framesPlayed = 0;
  //             if (_recording) {
  //               _stopRecording();
  //               _copyRecordedAudio();
  //             }
  //             if (_requestRecord) {
  //               _startRecording();
  //               _requestRecord = false;
  //             }
  //           }
  //         }
  //       },
  //     );

  //     _engine.startStream();
  //   });
  // }

  static const maxRecordTime = Duration(minutes: 1);

  bool _recording = false;

  int _framesPlayed = 0;

  bool _requestRecord = false;

  bool mute = false;

  bool get requestedRecord => _requestRecord;

  bool get recording => _recording;

  bool _firstTrackRecorded = false;

  bool get firstTrackRecorded => _firstTrackRecorded;

  double get loopProgress =>
      firstTrackRecorded ? _framesPlayed / _loopTrack.numFrames : 0;

  AudioEngine _engine;
  //AudioBuffer _firstTrack;
  AudioBuffer _loopTrack;
  AudioBuffer _backupTrack;
  List<double> _buffer = [];

  void startRecording() {
    if (!firstTrackRecorded) {
      _startRecording();
    } else {
      _requestRecord = true;
    }
  }

  void _startRecording() {
    if (_recording) return;
    _buffer.clear();
    _recording = true;
  }

  void stopRecording() {
    _stopRecording();
    if (!firstTrackRecorded) {
      _copyRecordedAudio();
    }
  }

  void _stopRecording() {
    if (!_recording) return;
    _recording = false;
  }

  void _copyRecordedAudio() {
    AudioBuffer recordedAudio = AudioBuffer.fromRaw(
      numChannels: _engine?.channelCount,
      numFrames: _buffer.length ~/ _engine?.channelCount,
      raw: _buffer,
    );

    if (!firstTrackRecorded) {
      //_firstTrack = recordedAudio;
      _loopTrack = recordedAudio;
      _backupTrack = _loopTrack;

      _firstTrackRecorded = true;
    } else {
      _backupTrack = _loopTrack.copy();

      for (int channel = 0; channel < _loopTrack.numChannels; channel++) {
        for (int frame = 0; frame < _loopTrack.numFrames; frame++) {
          double sample = recordedAudio.getChannel(channel).getSample(frame);
          _loopTrack.getChannel(channel).addSample(frame, sample);
        }
      }
    }
  }

  void undoPreviousTake() {
    _loopTrack = _backupTrack;
  }

  void reset() {
    _stopRecording();
    //_firstTrack = null;
    _firstTrackRecorded = false;
    _framesPlayed = 0;
  }

  void muteLoop() => mute = true;
  void unmuteLoop() => mute = false;

  void disposeStream() {
    _engine?.dispose();
    _engine = null;
  }

  LooperAppData toData() {
    return LooperAppData(
      recording: recording,
      requestedRecording: requestedRecord,
      firstTrackRecorded: firstTrackRecorded,
      mute: mute,
      loopProgress: loopProgress,
    );
  }
}

class LooperAppData {
  const LooperAppData({
    this.recording,
    this.requestedRecording,
    this.firstTrackRecorded,
    this.mute,
    this.loopProgress,
  });

  final bool recording;
  final bool requestedRecording;
  final bool firstTrackRecorded;
  final bool mute;
  final double loopProgress;
}
