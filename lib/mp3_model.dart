import 'package:hive/hive.dart';

part 'mp3_model.g.dart';

@HiveType(typeId: 0)
class MP3Model extends HiveObject {
  @HiveField(0)
  String path;

  MP3Model({required this.path});
}
