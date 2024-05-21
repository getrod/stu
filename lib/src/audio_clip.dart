import 'package:meta/meta.dart';
import 'audio/audio_buffer.dart';

/// An Audio Clip.
class AudioClip {
  /// Creates a new AudioClip with [audioData] and 
  /// a [startTime].
  AudioClip({
    @required AudioBuffer audioData,
    int startTime,
  })  : assert(audioData != null),
        assert(startTime != null) {
    _audioData = audioData;
    _duration = _audioData.numFrames;
    this.startTime = startTime;
  }

  AudioBuffer _audioData;

  int _startTime = 0;

  /// The start time of an [AudioClip].
  /// 
  /// Time is in terms of the sample rate.
  /// If the sample rate is 44,100 and [startTime] is 22,050,
  /// the audio clip will start at 22,050 / 44,100 = 0.5 seconds.
  int get startTime => _startTime;
  set startTime(int time) => _startTime = time.isNegative ? 0 : time;

  int _duration = 0;

  /// The duration of the [AudioClip].
  /// 
  /// Time is in terms of the sample rate.
  /// If the sample rate is 44,100 and [duration] is 22,050,
  /// then the audio clip is 22,050 / 44,100 = 0.5 seconds long.
  int get duration => _duration;

  /// The end time of an [AudioClip].
  /// 
  /// Time is in terms of the sample rate.
  /// If the sample rate is 44,100, [startTime] is 22,050, 
  /// and [duration] is 11,025, then the audio clip will
  /// end at time (22,050 + 11,025) / 44,100 = 0.75 seconds
  int get endTime => _startTime + _duration;

  /// Returns the sample of the audio clip at the [sampleIndex]
  /// in the specified [channel].
  /// 
  /// If the [sampleIndex] isn't in the range of the [AudioClip], 
  /// 0 is returned.
  double getSample(int channel, int sampleIndex) {
    if (sampleIndex < startTime || sampleIndex > endTime) return 0;
    return _audioData.getChannel(channel).getSample(sampleIndex);
  }
}
