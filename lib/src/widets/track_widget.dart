import 'package:flutter/material.dart';

class TrackWidget extends StatelessWidget {
  TrackWidget({
    this.currentTime,
    this.isActive,
    this.isRecording,
    this.duration,
    this.trackNumber,
    this.activeButtonFunction,
    this.microphoneButtonFunction,
  });
  final Duration currentTime;
  final Duration duration;
  final bool isActive;
  final bool isRecording;
  final int trackNumber;
  final Function activeButtonFunction;
  final Function microphoneButtonFunction;
  static const pixelsPerSecond = 50.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FlatButton(
          color: Colors.yellow,
          child: Text("$trackNumber"),
          onPressed: activeButtonFunction,
        ),
        IconButton(
          icon: Icon(
            Icons.mic,
            color: isRecording ? Colors.red : Colors.grey,
          ),
          onPressed: microphoneButtonFunction,
        ),
        Slider(
          inactiveColor: Colors.grey,
          activeColor: isActive ? Colors.red : Colors.grey,
          onChanged: (_) => 0,
          value: currentTime.inMilliseconds / duration.inMilliseconds,
        ),
      ],
    );
  }
}
