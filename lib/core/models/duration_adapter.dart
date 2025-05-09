import 'package:hive/hive.dart';

/// Register this adapter in main.dart: Hive.registerAdapter(DurationAdapter());
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 42; // Use an unused typeId for Duration

  @override
  Duration read(BinaryReader reader) {
    return Duration(microseconds: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}
