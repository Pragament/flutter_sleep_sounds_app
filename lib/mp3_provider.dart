import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_boxes.dart';
import 'mp3_model.dart';

final mp3ListProvider = StateNotifierProvider<MP3ListNotifier, List<MP3Model>>((ref) {
  return MP3ListNotifier();
});

class MP3ListNotifier extends StateNotifier<List<MP3Model>> {
  MP3ListNotifier() : super(Boxes.getMP3Box().values.toList());

  void addMP3(MP3Model mp3) {
    final box = Boxes.getMP3Box();
    box.add(mp3);
    state = box.values.toList();
  }
}
