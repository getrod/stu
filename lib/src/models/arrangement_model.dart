import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:stu/src/arrangement.dart';
import 'package:stu/src/audio/audio_buffer.dart';

class ArrangementModel extends ChangeNotifier {
  Arrangement _arrangement = Arrangement();

  UnmodifiableListView get tracks => UnmodifiableListView(_arrangement.tracks);

  int get currentTime => _arrangement.currentTime;

  void addTrack() {
    _arrangement.addTrack();
    notifyListeners();
  }

  void removeTrack(int trackNumber) {
    _arrangement.removeTrack(trackNumber);
    notifyListeners();
  }

  void processBlock(AudioBuffer out) {
    _arrangement.processBlock(out);
  }

  void activateButton(int trackNum, bool active) {
    _arrangement.tracks[trackNum - 1].mute = active;
    notifyListeners();
  }

  void activateRecording(int trackNum, bool active) {
    _arrangement.tracks[trackNum - 1].isRecording = active;
    notifyListeners();
  }
}
