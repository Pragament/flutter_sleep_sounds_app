import 'package:hive/hive.dart';
import 'mp3_model.dart';

class Boxes {
  static Box<MP3Model> getMP3Box() => Hive.box<MP3Model>('mp3');
}
