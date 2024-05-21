import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stu/src/screens/looper_app_isolate.dart' as looperApp;

class LooperScreen extends StatefulWidget {
  @override
  _LooperScreenState createState() => _LooperScreenState();
}

class _LooperScreenState extends State<LooperScreen> {
  bool _isRecording = false;
  bool _showLoopProgress = false;
  bool _requestedRecording = false;
  bool _mute = false;
  double _progress = 0.0;
  Color _color = Colors.green;
  Timer _animateTimer;

  @override
  void initState() {
    looperApp.createLooperApp().then((created) {
      if(!created) return;
      _animateTimer = Timer.periodic(
        Duration(milliseconds: 50),
        (timer) {
          setState(() {
            looperApp.getLooperAppData().then((app) {
              _isRecording = app.recording;
              _requestedRecording = app.requestedRecording;
              _showLoopProgress = app.firstTrackRecorded;
              _progress = app.loopProgress;
              _mute = app.mute;

              if (_isRecording) {
                _color = Colors.red;
              } else if (_requestedRecording) {
                _color = Colors.grey;
              } else {
                _color = Colors.green;
              }
            });
          });
        },
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    looperApp.perform(looperApp.LooperMessage.disposeStream);
    _animateTimer?.cancel();
    super.dispose();
  }

  Widget looperButton() {
    double size = 200;
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        elevation: 10,
        backgroundColor: Colors.white,
        child: _isRecording
            ? Icon(Icons.clear, size: size / 3, color: Colors.red)
            : null,
        onPressed: () {
          if (_isRecording) {
            looperApp.perform(looperApp.LooperMessage.stopRecording);
          } else {
            looperApp.perform(looperApp.LooperMessage.startRecording);
          }
        },
      ),
    );
  }

  Widget recordIndicator() {
    return Icon(
      Icons.brightness_1,
      color: _color,
    );
  }

  Widget loopProgress() {
    double size = 240.0;
    Color color = _color;
    if (!_showLoopProgress) color = color.withAlpha(0);
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        value: _progress,
        strokeWidth: 10,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Looper",
          style: GoogleFonts.bungee(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            Flexible(
              flex: 1,
              child: recordIndicator(),
            ),
            Spacer(flex: 2),
            Flexible(
              flex: 5,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  loopProgress(),
                  looperButton(),
                ],
              ),
            ),
            Spacer(),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 2,
                    child: IconButton(
                      icon: Icon(Icons.undo),
                      onPressed: () {
                        looperApp
                            .perform(looperApp.LooperMessage.undoPreviosTake);
                      },
                    ),
                  ),
                  //Spacer(),
                  Flexible(
                    flex: 2,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        looperApp.perform(looperApp.LooperMessage.reset);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: IconButton(
                      icon: Icon(_mute ? Icons.volume_off : Icons.volume_up),
                      onPressed: () {
                        _mute
                            ? looperApp
                                .perform(looperApp.LooperMessage.unmuteLoop)
                            : looperApp
                                .perform(looperApp.LooperMessage.muteLoop);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _LooperScreenState extends State<LooperScreen> {
//   bool _isRecording = false;
//   bool _showLoopProgress = false;
//   bool _requestedRecording = false;
//   double _progress = 0.0;
//   LooperApp _app;
//   Timer _animateTimer;
//   Color _color = Colors.green;
//   bool _mute = false;

//   @override
//   void initState() {
//     _app = LooperApp();
//     _animateTimer = Timer.periodic(
//       Duration(milliseconds: 100),
//       (timer) {
//         setState(() {
//           _isRecording = _app.recording;
//           _requestedRecording = _app.requestedRecord;
//           if (_isRecording) {
//             _color = Colors.red;
//           } else if (_requestedRecording) {
//             _color = Colors.grey;
//           } else {
//             _color = Colors.green;
//           }
//           _showLoopProgress = _app.firstTrackRecorded;
//           _progress = _app.loopProgress;
//           _mute = _app.mute;
//         });
//       },
//     );
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _app.disposeStream();
//     super.dispose();
//   }

//   Widget looperButton() {
//     double size = 200;
//     return SizedBox(
//       width: size,
//       height: size,
//       child: FloatingActionButton(
//         elevation: 10,
//         backgroundColor: Colors.white,
//         child: _isRecording
//             ? Icon(Icons.clear, size: size / 3, color: Colors.red)
//             : null,
//         onPressed: () {
//           if (_isRecording) {
//             _app.stopRecording();
//           } else {
//             _app.startRecording();
//           }
//         },
//       ),
//     );
//   }

//   Widget recordIndicator() {
//     return Icon(
//       Icons.brightness_1,
//       color: _color,
//     );
//   }

//   Widget loopProgress() {
//     double size = 240.0;
//     Color color = _color;
//     if (!_showLoopProgress) color = color.withAlpha(0);
//     return SizedBox(
//       height: size,
//       width: size,
//       child: CircularProgressIndicator(
//         value: _progress,
//         strokeWidth: 10,
//         valueColor: AlwaysStoppedAnimation<Color>(color),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Looper",
//           style: GoogleFonts.bungee(color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Spacer(),
//             Flexible(
//               flex: 1,
//               child: recordIndicator(),
//             ),
//             Spacer(flex: 2),
//             Flexible(
//               flex: 5,
//               child: Stack(
//                 alignment: AlignmentDirectional.center,
//                 children: [
//                   loopProgress(),
//                   looperButton(),
//                 ],
//               ),
//             ),
//             Spacer(),
//             Flexible(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Flexible(
//                     flex: 2,
//                     child: IconButton(
//                       icon: Icon(Icons.undo),
//                       onPressed: () {
//                         _app.undoPreviousTake();
//                       },
//                     ),
//                   ),
//                   //Spacer(),
//                   Flexible(
//                     flex: 2,
//                     child: IconButton(
//                       icon: Icon(Icons.delete),
//                       onPressed: () {
//                         _app.reset();
//                       },
//                     ),
//                   ),
//                   Flexible(
//                     flex: 2,
//                     child: IconButton(
//                       icon: Icon(_mute ? Icons.volume_off : Icons.volume_up),
//                       onPressed: () {
//                         _mute ? _app.mute = false : _app.mute = true;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
