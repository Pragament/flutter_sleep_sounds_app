import 'package:flutter/material.dart';

class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const PlaybackControls({
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          iconSize: 36.0,
          onPressed: isPlaying ? onPause : onPlay,
        ),
        IconButton(
          icon: Icon(Icons.stop),
          iconSize: 36.0,
          onPressed: onStop,
        ),
      ],
    );
  }
}
