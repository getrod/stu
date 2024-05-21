import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stu/src/arrangement.dart';
import 'package:stu/src/models/arrangement_model.dart';
import 'package:stu/src/widets/track_widget.dart';

class ArrangementScreen extends StatefulWidget {
  ArrangementScreen(this.arrangement) : assert(arrangement != null);
  final ArrangementModel arrangement;
  @override
  _ArrangementScreenState createState() => _ArrangementScreenState();
}

class _ArrangementScreenState extends State<ArrangementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("STU"),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TrackWidget(
                duration: Duration(seconds: 3),
                currentTime: Duration(seconds: 2),
                isActive: true,
                isRecording: false,
                trackNumber: 1,
                activeButtonFunction: () {
                  widget.arrangement.activateButton(1, true);
                },
                microphoneButtonFunction: () {
                  widget.arrangement.activateRecording(1, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
