// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      ownerId: fields[0] as String?,
      id: fields[1] as String,
      content: fields[2] as String?,
      remoteCreatedAt: fields[3] as DateTime?,
      remoteUpdatedAt: fields[4] as DateTime?,
      isPinned: fields[5] as bool,
      isSync: fields[6] as bool,
      pendingDelete: fields[7] as bool,
      localUpdatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.ownerId)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.remoteCreatedAt)
      ..writeByte(4)
      ..write(obj.remoteUpdatedAt)
      ..writeByte(5)
      ..write(obj.isPinned)
      ..writeByte(6)
      ..write(obj.isSync)
      ..writeByte(7)
      ..write(obj.pendingDelete)
      ..writeByte(8)
      ..write(obj.localUpdatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
