// import 'package:flutter/material.dart';
//
// class GripStrengthTestScreen extends StatefulWidget {
//   @override
//   _GripStrengthTestScreenState createState() => _GripStrengthTestScreenState();
// }
//
// class _GripStrengthTestScreenState extends State<GripStrengthTestScreen> {
//   double leftHandPressure = 0.0;
//   double rightHandPressure = 0.0;
//   Offset targetPosition = Offset(100, 100);
//   int tapCount = 0;
//   DateTime? startTime;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Grip Strength Test')),
//       body: Column(
//         children: [
//           // Grip Strength Test
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     GestureDetector(
//                       onForcePressUpdate: (details) {
//                         setState(() {
//                           leftHandPressure = details.pressure;
//                         });
//                       },
//                       child: CircleAvatar(radius: 50, child: Text('Left Hand')),
//                     ),
//                     GestureDetector(
//                       onForcePressUpdate: (details) {
//                         setState(() {
//                           rightHandPressure = details.pressure;
//                         });
//                       },
//                       child: CircleAvatar(radius: 50, child: Text('Right Hand')),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 Text('Left Hand Pressure: $leftHandPressure'),
//                 Text('Right Hand Pressure: $rightHandPressure'),
//               ],
//             ),
//           ),
//
//           // Finger-to-Nose Coordination Test
//           Expanded(
//             child: GestureDetector(
//               onPanUpdate: (details) {
//                 setState(() {
//                   targetPosition = details.localPosition;
//                 });
//               },
//               child: Stack(
//                 children: [
//                   Positioned(
//                     left: targetPosition.dx,
//                     top: targetPosition.dy,
//                     child: CircleAvatar(radius: 20, child: Text('Target')),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Finger Dexterity & Coordination Test
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         if (startTime == null) {
//                           startTime = DateTime.now();
//                         }
//                         setState(() {
//                           tapCount++;
//                         });
//                       },
//                       child: CircleAvatar(radius: 50, child: Text('Tap 1')),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         if (startTime == null) {
//                           startTime = DateTime.now();
//                         }
//                         setState(() {
//                           tapCount++;
//                         });
//                       },
//                       child: CircleAvatar(radius: 50, child: Text('Tap 2')),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 Text('Tap Count: $tapCount'),
//                 if (startTime != null)
//                   Text('Time Elapsed: ${DateTime.now().difference(startTime!).inSeconds} seconds'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:async';


class GripCoordinationScreen extends StatefulWidget {
  @override
  _GripCoordinationScreenState createState() => _GripCoordinationScreenState();
}

class _GripCoordinationScreenState extends State<GripCoordinationScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HandGripperExercise(),
    TheraputtyExercise(),
    TapAndDragGame(),
    MazeNavigationGame(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Grip & Coordination Exercises")),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Gripper"),
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: "Putty"),
          BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: "Tap & Drag"),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: "Maze"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Hand Gripper Exercise
class HandGripperExercise extends StatefulWidget {
  @override
  _HandGripperExerciseState createState() => _HandGripperExerciseState();
}

class _HandGripperExerciseState extends State<HandGripperExercise> {
  bool _isPressed = false;
  Timer? _timer;
  int _duration = 0;

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _duration += 100;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _startTimer();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _stopTimer();
        },
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: _isPressed ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text("$_duration ms", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// Theraputty Exercise
class TheraputtyExercise extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Simulated Putty Exercise - Stretch, Squeeze, Roll", style: TextStyle(fontSize: 18)),
    );
  }
}

// Tap and Drag Game
class TapAndDragGame extends StatefulWidget {
  @override
  _TapAndDragGameState createState() => _TapAndDragGameState();
}

class _TapAndDragGameState extends State<TapAndDragGame> {
  Offset _position = Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(_position.dx + details.delta.dx, _position.dy + details.delta.dy);
              });
            },
            child: Container(width: 50, height: 50, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

// Maze Navigation
class MazeNavigationGame extends StatefulWidget {
  @override
  _MazeNavigationGameState createState() => _MazeNavigationGameState();
}

class _MazeNavigationGameState extends State<MazeNavigationGame> {
  Offset _playerPosition = Offset(50, 50);
  final Offset _goalPosition = Offset(250, 400);

  void _movePlayer(DragUpdateDetails details) {
    setState(() {
      _playerPosition = Offset(
        _playerPosition.dx + details.delta.dx,
        _playerPosition.dy + details.delta.dy,
      );
    });
  }

  bool _checkWinCondition() {
    return (_playerPosition - _goalPosition).distance < 30;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _movePlayer,
      child: Stack(
        children: [
          Positioned(
            left: _goalPosition.dx,
            top: _goalPosition.dy,
            child: Container(width: 50, height: 50, color: Colors.green),
          ),
          Positioned(
            left: _playerPosition.dx,
            top: _playerPosition.dy,
            child: Container(width: 30, height: 30, color: Colors.red),
          ),
          if (_checkWinCondition())
            Center(
              child: AlertDialog(
                title: Text("You Win!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _playerPosition = Offset(50, 50);
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Restart"),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
