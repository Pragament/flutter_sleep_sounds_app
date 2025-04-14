import 'package:flutter/material.dart';

class TimerControls extends StatelessWidget {
  final Function(Duration) setTimer;

  const TimerControls({required this.setTimer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              onPressed: () => setTimer(Duration(minutes: 5)),
              child: Text('5 min')),
          ElevatedButton(
              onPressed: () => setTimer(Duration(minutes: 10)),
              child: Text('10 min')),
          ElevatedButton(
              onPressed: () => setTimer(Duration(minutes: 15)),
              child: Text('15 min')),
        ],
      ),
    );
  }
}
