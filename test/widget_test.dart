import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// PlaybackControls for play, pause, and stop actions
class PlaybackControls extends StatelessWidget {
  final Function onPlay;
  final Function onPause;
  final Function onStop;
  final bool isPlaying;

  const PlaybackControls({super.key, 
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () => isPlaying ? onPause() : onPlay(),
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: () => onStop(),
        ),
      ],
    );
  }
}

// TimerControls for setting a timer to stop audio after a specified time
class TimerControls extends StatelessWidget {
  final Function(int) setTimer;

  const TimerControls({super.key, required this.setTimer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () => setTimer(5), child: Text('5 Min Timer')),
        SizedBox(width: 10),
        ElevatedButton(onPressed: () => setTimer(10), child: Text('10 Min Timer')),
      ],
    );
  }
}

// SoundItem widget to represent each sound item in the grid
class SoundItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final Function onTap;

  const SoundItem({super.key, required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.black54,
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Main SoundGrid widget for displaying the grid of sounds
class SoundGrid extends StatelessWidget {
  final List<Map<String, String>> sounds;
  final Function(String) playSound;

  const SoundGrid({super.key, required this.sounds, required this.playSound});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        return SoundItem(
          title: sounds[index]['title']!,
          imagePath: sounds[index]['image']!,
          onTap: () => playSound(sounds[index]['file']!),
        );
      },
    );
  }
}

// VolumeControl widget for adjusting the volume
class VolumeControl extends StatelessWidget {
  final double volume;
  final Function(double) onVolumeChanged;

  const VolumeControl({super.key, required this.volume, required this.onVolumeChanged});

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: volume,
      min: 0.0,
      max: 1.0,
      onChanged: onVolumeChanged,
    );
  }
}
