import 'package:flutter/material.dart';

class VolumeControl extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeControl({
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Volume: ${(volume * 100).toInt()}%'),
        Slider(
          value: volume,
          min: 0,
          max: 1,
          onChanged: onVolumeChanged,
        ),
      ],
    );
  }
}
