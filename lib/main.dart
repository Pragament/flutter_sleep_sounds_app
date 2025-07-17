import 'dart:async';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('mp3_files');
  runApp(ProviderScope(child: SleepSoundsApp()));
}


final audioPlayerProvider = Provider<AudioPlayer>((ref) => AudioPlayer());
final playlistProvider = StateProvider<List<String>>((ref) => []);
final currentIndexProvider = StateProvider<int>((ref) => -1);
final isPlayingProvider = StateProvider<bool>((ref) => false);
final isShuffleProvider = StateProvider<bool>((ref) => false);

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

class SleepSoundsHome extends ConsumerStatefulWidget {
  @override
  _SleepSoundsHomeState createState() => _SleepSoundsHomeState();
}

class _SleepSoundsHomeState extends ConsumerState<SleepSoundsHome> {
  int _selectedIndex = 0;
  final List<Map<String, String>> sounds = [
    {'title': 'Ocean Waves', 'file': 'assets/ocean_waves.mp3', 'image': 'assets/ocean_waves.jpeg'},
    {'title': 'Peaceful Night', 'file': 'assets/peaceful_night.mp3', 'image': 'assets/peaceful_night.jpeg'},
    {'title': 'Rain in Forest', 'file': 'assets/rain_in_forest.mp3', 'image': 'assets/rain_in_forest.jpeg'},
    {'title': 'Rain with Piano', 'file': 'assets/rain_with_piano.mp3', 'image': 'assets/rain_with_piano.jpeg'},
    {'title': 'Spring Rain', 'file': 'assets/spring_rain.mp3', 'image': 'assets/spring_rain.jpeg'},
    {'title': 'White Noise', 'file': 'assets/white_noise.mp3', 'image': 'assets/white_noise.jpeg'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _playAssetSound(int index) async {
    final player = ref.read(audioPlayerProvider);
    final playlistNotifier = ref.read(playlistProvider.notifier);
    final indexNotifier = ref.read(currentIndexProvider.notifier);

    playlistNotifier.state = sounds.map((e) => e['file']!).toList();
    indexNotifier.state = index;

    await player.setAsset(sounds[index]['file']!);
    await player.setLoopMode(LoopMode.one);
    await player.play();

    ref.read(isPlayingProvider.notifier).state = true;
  }

  Widget _buildHome() {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: sounds.map((sound) {
              return GestureDetector(
                onTap: () => _playAssetSound(sounds.indexOf(sound)),
                child: Card(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(sound['image']!, fit: BoxFit.cover),
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Text(sound['title']!, style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        CommonBottomControls(),
      ],
    );
  }

  Widget _buildFind() {
    return Center(
      child: Text('Find Screen (Dummy)', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildLibrary() {
    final box = Hive.box<String>('mp3_files');
    final mp3List = box.values.toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: mp3List.length,
            itemBuilder: (context, index) {
              final path = mp3List[index];
              return ListTile(
                leading: Icon(Icons.music_note),
                title: Text(path.split('/').last),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      final key = box.keys.firstWhere((k) => box.get(k) == path);
                      box.delete(key);
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () async {
                  final player = ref.read(audioPlayerProvider);
                  final playlistNotifier = ref.read(playlistProvider.notifier);
                  final indexNotifier = ref.read(currentIndexProvider.notifier);

                  playlistNotifier.state = mp3List;
                  indexNotifier.state = index;

                  await player.setFilePath(path);
                  await player.setLoopMode(LoopMode.one);
                  await player.play();

                  ref.read(isPlayingProvider.notifier).state = true;
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.audio);
                if (result != null && result.files.single.path != null) {
                  final filePath = result.files.single.path!;
                  final fileName = filePath.split('/').last;

                  final existingNames = mp3List.map((e) => e.split('/').last).toList();
                  if (!existingNames.contains(fileName)) {
                    box.add(filePath);
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('This file is already added!')),
                    );
                  }
                }
              },
            ),
          ),
        ),
        CommonBottomControls(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [_buildHome(), _buildFind(), _buildLibrary()];

    return Scaffold(
      appBar: AppBar(title: Text('Relax Melodies')),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CommonBottomControls extends ConsumerStatefulWidget {
  const CommonBottomControls({Key? key}) : super(key: key);

  @override
  ConsumerState<CommonBottomControls> createState() => _CommonBottomControlsState();
}

class _CommonBottomControlsState extends ConsumerState<CommonBottomControls> {
  Timer? _timer;
  Duration? _remainingTime;
  StreamSubscription<PlayerState>? _playerSubscription;

  @override
  void initState() {
    super.initState();

    final player = ref.read(audioPlayerProvider);

  
    _playerSubscription = player.playerStateStream.listen((state) {
      final isPlaying = state.playing && state.processingState != ProcessingState.completed;

      ref.read(isPlayingProvider.notifier).state = isPlaying;

      setState(() {});
    });
  }

  void _setTimer(Duration duration) {
    _timer?.cancel();
    setState(() => _remainingTime = duration);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingTime == null || _remainingTime!.inSeconds <= 1) {
        await ref.read(audioPlayerProvider).stop();
        ref.read(isPlayingProvider.notifier).state = false;
        ref.read(currentIndexProvider.notifier).state = -1;
        timer.cancel();
        setState(() => _remainingTime = null);
      } else {
        setState(() {
          _remainingTime = _remainingTime! - const Duration(seconds: 1);
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

  Future<void> playAtIndex(int index) async {
    final player = ref.read(audioPlayerProvider);
    final playlist = ref.read(playlistProvider);

    if (playlist.isEmpty) return;

    final file = playlist[index];
    try {
      if (file.startsWith('assets/')) {
        await player.setAsset(file);
      } else {
        await player.setFilePath(file);
      }
      await player.setLoopMode(LoopMode.one);
      await player.play();

      ref.read(currentIndexProvider.notifier).state = index;
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _playerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioPlayerProvider);
    final playlist = ref.watch(playlistProvider);
    final currentIndex = ref.watch(currentIndexProvider);
    final isPlaying = ref.watch(isPlayingProvider);

    final isSongSelected = playlist.isNotEmpty && currentIndex != -1;
    IconData playPauseIcon = isPlaying ? Icons.pause : Icons.play_arrow;

    return Column(
      children: [
        if (_remainingTime != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Time Left: ${_formatDuration(_remainingTime)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: () async {
                if (playlist.isNotEmpty) {
                  final newIndex = Random().nextInt(playlist.length);
                  await playAtIndex(newIndex);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () async {
                if (playlist.isNotEmpty) {
                  final newIndex = (currentIndex - 1 + playlist.length) % playlist.length;
                  await playAtIndex(newIndex);
                }
              },
            ),
            IconButton(
              icon: Icon(playPauseIcon),
              iconSize: 36,
              onPressed: () async {
                if (!isSongSelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a song to play.')));
                  return;
                }
                if (isPlaying) {
                  await player.pause();
                  ref.read(isPlayingProvider.notifier).state = false; 
                } else {
                  if (player.processingState == ProcessingState.completed ||
                      player.processingState == ProcessingState.idle) {
                    await playAtIndex(currentIndex);
                  } else {
                    await player.play();
                    ref.read(isPlayingProvider.notifier).state = true; 
                  }
                }

              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () async {
                if (playlist.isNotEmpty) {
                  final newIndex = (currentIndex + 1) % playlist.length;
                  await playAtIndex(newIndex);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.timer),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Set Timer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: const Text('5 Minutes'),
                          onPressed: () {
                            _setTimer(const Duration(minutes: 5));
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('10 Minutes'),
                          onPressed: () {
                            _setTimer(const Duration(minutes: 10));
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Stop Timer'),
                          onPressed: () {
                            _setTimer(const Duration(seconds: 0));
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
