import 'audio/audio_buffer.dart';
import 'track.dart';

class Arrangement {
  Arrangement() {
    _tracks = List();
    addTrack();
  }

  List<Track> _tracks;

  List<Track> get tracks => _tracks;

  int currentTime = 0;

  void addTrack() {
    if(_tracks.length >= Track.maxNumTracks) return;
    _tracks.add(Track(trackNumber: _tracks.length + 1));
    //_sortTrackNumbers();
  }

  void removeTrack(int trackNumber) {
    if(!Track.inRange(trackNumber)) return;
    _tracks.removeAt(trackNumber - 1);
    _sortTrackNumbers();
  }

  void processBlock(AudioBuffer out) {
    double sample = 0;
    for(int channel = 0; channel < out.numChannels; channel++) {
      for(int sampleIndex = 0; sampleIndex < out.numFrames; sampleIndex++) {
        sample = sampleAt(channel, sampleIndex);
        out.getChannel(channel).setSample(sampleIndex, sample);
      }
    }
  }

  double sampleAt(int channel, int sampleIndex) {
    double sample = 0;
    _tracks.forEach((track) {
      sample += track.sampleAt(channel, sampleIndex);
    });
    return sample;
  }

  void _sortTrackNumbers() {
    for(int i = 0; i < _tracks.length; i++) {
      _tracks[i].trackNumber = i + 1;
    }
  }
}