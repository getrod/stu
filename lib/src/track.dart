import 'audio_clip.dart';

/// A Track.
///
/// Each track has a single [AudioClip].
class Track {
  /// Creates a [Track].
  /// 
  /// The [trackNumber] cannnot be null or
  /// exceed the [maxNumTracks].
  Track({int trackNumber, AudioClip audioClip}) : this.audioClip = audioClip {
    this.trackNumber = trackNumber;
  }

  /// The maximum number of tracks.
  static const maxNumTracks = 5;

  int _trackNumber;

  bool mute = false;

  bool isRecording = false;

  /// The [Track]'s number.
  ///
  /// The [trackNumber] cannnot be null or
  /// exceed the [maxNumTracks].
  int get trackNumber => _trackNumber;
  set trackNumber(int tackNum) {
    //assert(trackNumber != null);
    assert(tackNum > 0 && tackNum <= maxNumTracks);
    _trackNumber = tackNum;
  }

  /// The track's audio clip.
  AudioClip audioClip;

  /// Returns the sample positioned at the [sampleIndex]
  /// in a given [channel] of the track's audio clip.
  ///
  /// If the track has no audio clip, 0 is returned.
  double sampleAt(int channel, int sampleIndex) {
    if (audioClip == null || mute) return 0;
    return audioClip.getSample(channel, sampleIndex);
  }

  static bool inRange(int trackNum) {
    return trackNum > 0 && trackNum <= maxNumTracks;
  }
}
