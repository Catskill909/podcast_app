// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `flutter pub run build_runner build` to update

part of 'episode.dart';

// ignore_for_file: type=lint

@HiveType(typeId: 1)
class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 1;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Episode(
      id: fields[0] as String,
      title: fields[1] as String,
      audioUrl: fields[2] as String,
      description: fields[3] as String,
      duration: fields[4] as Duration,
      podcastImageUrl: fields[5] as String,
      imageUrl: fields[6] as String,
      summary: fields[7] as String?,
      contentHtml: fields[8] as String?,
      audioLength: fields[9] as int?,
      audioType: fields[10] as String?,
      pubDate: fields[11] as DateTime?,
      explicitTag: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.audioUrl)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.podcastImageUrl)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.summary)
      ..writeByte(8)
      ..write(obj.contentHtml)
      ..writeByte(9)
      ..write(obj.audioLength)
      ..writeByte(10)
      ..write(obj.audioType)
      ..writeByte(11)
      ..write(obj.pubDate)
      ..writeByte(12)
      ..write(obj.explicitTag);
  }
}
