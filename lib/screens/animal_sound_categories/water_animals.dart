import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../main.dart';

class WaterAnimalsPage extends ConsumerWidget {
  const WaterAnimalsPage({Key? key}) : super(key: key);

  final List<Map<String, String>> petSounds = const [
    {'title': 'Dolphin Sound', 'file': 'assets/water_animals/dolphin_sound.mp3', 'image': 'assets/water_animals/dolphin_image.jpg'},
  ];

  Future<void> _playAssetSound(WidgetRef ref, int index) async {
    final player = ref.read(audioPlayerProvider);
    final playlistNotifier = ref.read(playlistProvider.notifier);
    final indexNotifier = ref.read(currentIndexProvider.notifier);

    playlistNotifier.state = petSounds.map((e) => e['file']!).toList();
    indexNotifier.state = index;

    await player.setAsset(petSounds[index]['file']!);
    await player.setLoopMode(LoopMode.one);
    await player.play();

    ref.read(isPlayingProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Animals'),
      ),
      body: Column(
        children: [
          Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: petSounds.length,
                  itemBuilder: (context, index) {
                    final sound = petSounds[index];
                    return GestureDetector(
                      onTap: () => _playAssetSound(ref, index),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(sound['image']!, fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withOpacity(0.3),
                              child: Center(
                                child: Text(
                                  sound['title']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },)
          ),
          const CommonBottomControls(),
        ],
      ),
    );
  }
}
