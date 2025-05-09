// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `flutter pub run build_runner build` to update

part of 'podcast.dart';

// ignore_for_file: type=lint

@HiveType(typeId: 0)
class PodcastAdapter extends TypeAdapter<Podcast> {
  @override
  final int typeId = 0;

  @override
  Podcast read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Podcast(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      imageUrl: fields[3] as String,
      description: fields[4] as String,
      episodes: (fields[5] as List).cast<Episode>(),
      subtitle: fields[6] as String?,
      summary: fields[7] as String?,
      language: fields[8] as String?,
      copyright: fields[9] as String?,
      category: fields[10] as String?,
      explicitTag: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Podcast obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.episodes)
      ..writeByte(6)
      ..write(obj.subtitle)
      ..writeByte(7)
      ..write(obj.summary)
      ..writeByte(8)
      ..write(obj.language)
      ..writeByte(9)
      ..write(obj.copyright)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.explicitTag);
  }
}
