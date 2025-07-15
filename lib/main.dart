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
  Duration? _remainingTime;
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
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(filePath);
      await _audioPlayer.setLoopMode(LoopMode.one); // loop continuously
      _audioPlayer.setVolume(volume);
      await _audioPlayer.play();
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
    setState(() {
      isPlaying = false;
      _remainingTime = null;
    });
    _timer?.cancel();
  }

  void _setTimer(Duration duration) {
    _timer?.cancel();
    _remainingTime = duration;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime == null || _remainingTime!.inSeconds <= 1) {
        _stopSound();
        timer.cancel();
      } else {
        setState(() {
          _remainingTime = _remainingTime! - Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
          Expanded(
            child: SoundGrid(
              sounds: sounds,
              playSound: _playSound,
            ),
          ),

          if (_remainingTime != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Time Left: ${_formatDuration(_remainingTime)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

          VolumeControl(
            volume: volume,
            onVolumeChanged: (val) {
              setState(() {
                volume = val;
                _audioPlayer.setVolume(volume);
              });
            },
          ),

          PlaybackControls(
            isPlaying: isPlaying,
            onPlay: () => _playSound(sounds[0]['file']!),
            onPause: _pauseSound,
            onStop: _stopSound,
          ),

          TimerControls(setTimer: _setTimer),
        ],
      ),
    );
  }
}
