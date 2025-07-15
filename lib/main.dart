import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'widgets/sound_grid.dart';
import 'widgets/playback_controls.dart';
import 'widgets/timer_controls.dart';
import 'widgets/volume_control.dart';

void main() {
  runApp(SleepSoundsApp());
}

class SleepSoundsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relax Melodies',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SleepSoundsHome(),
    );
  }
}

class SleepSoundsHome extends StatefulWidget {
  @override
  _SleepSoundsHomeState createState() => _SleepSoundsHomeState();
}

class _SleepSoundsHomeState extends State<SleepSoundsHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Timer? _timer;
  double volume = 1.0;

  final List<Map<String, String>> sounds = [
    {'title': 'Ocean Waves', 'file': 'assets/ocean_waves.mp3', 'image': 'assets/ocean_waves.jpeg'},
    {'title': 'Peaceful Night', 'file': 'assets/peaceful_night.mp3', 'image': 'assets/peaceful_night.jpeg'},
    {'title': 'Rain in Forest', 'file': 'assets/rain_in_forest.mp3', 'image': 'assets/rain_in_forest.jpeg'},
    {'title': 'Rain with Piano', 'file': 'assets/rain_with_piano.mp3', 'image': 'assets/rain_with_piano.jpeg'},
    {'title': 'Spring Rain', 'file': 'assets/spring_rain.mp3', 'image': 'assets/spring_rain.jpeg'},
    {'title': 'White Noise', 'file': 'assets/white_noise.mp3', 'image': 'assets/white_noise.jpeg'},
  ];

  void _playSound(String filePath) async {
    try {
      await _audioPlayer.stop(); // Stop any previous audio
      await _audioPlayer.setAsset(filePath);

      // 🔁 This enables looping
      _audioPlayer.setLoopMode(LoopMode.one);

      _audioPlayer.setVolume(volume);
      _audioPlayer.play();
      setState(() => isPlaying = true);
    } catch (e) {
      print("Error: $e");
    }
  }
  void _pauseSound() {
    _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  void _stopSound() {
    _audioPlayer.stop();
    setState(() => isPlaying = false);
    _timer?.cancel();
  }

  void _setTimer(Duration duration) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      _stopSound();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relax Melodies')),
      body: Column(
        children: [
          // ✅ Main content with sound grid
          Expanded(
            child: SoundGrid(
              sounds: sounds,
              playSound: _playSound,
            ),
          ),

          // ✅ Volume control slider
          VolumeControl(
            volume: volume,
            onVolumeChanged: (val) {
              setState(() {
                volume = val;
                _audioPlayer.setVolume(volume);
              });
            },
          ),

          // ✅ Play/Pause/Stop buttons
          PlaybackControls(
            isPlaying: isPlaying,
            onPlay: () => _playSound(sounds[0]['file']!),
            onPause: _pauseSound,
            onStop: _stopSound,
          ),

          // ✅ Sleep timer
          TimerControls(setTimer: _setTimer),
        ],
      ),
    );
  }
}
