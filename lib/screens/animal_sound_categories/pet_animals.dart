import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio_handler.dart';
import '../../main.dart';

class PetAnimalsPage extends ConsumerWidget {
  const PetAnimalsPage({Key? key}) : super(key: key);

  final List<Map<String, String>> petSounds = const [
    {'title': 'Meow Sound', 'file': 'assets/pet_animals/meow_sound.mp3', 'image': 'assets/pet_animals/meow_meow.jpg'},
    {'title': 'Mouth Clicking', 'file': 'assets/pet_animals/mouth_clicking.mp3', 'image': 'assets/pet_animals/mouth_clicking.png'},
  ];

  Future<void> _playAssetSound(WidgetRef ref, int index) async {
    final audioHandler =
    await ref.read(audioHandlerProvider.future) as MyAudioHandler;

    final playlistNotifier = ref.read(playlistProvider.notifier);
    final indexNotifier = ref.read(currentIndexProvider.notifier);

    final playlist = petSounds.map((e) => e['file']!).toList();

    playlistNotifier.state = playlist;
    indexNotifier.state = index;

    await audioHandler.setPlaylist(playlist, index);
    await audioHandler.play();

    ref.read(isPlayingProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Animals'),
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
