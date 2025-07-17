// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp3_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MP3ModelAdapter extends TypeAdapter<MP3Model> {
  @override
  final int typeId = 0;

  @override
  MP3Model read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MP3Model(
      path: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MP3Model obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MP3ModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
