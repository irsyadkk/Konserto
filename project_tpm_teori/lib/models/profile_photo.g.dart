// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfilePhotoAdapter extends TypeAdapter<ProfilePhoto> {
  @override
  final int typeId = 0;

  @override
  ProfilePhoto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfilePhoto(
      email: fields[0] as String,
      photoPath: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProfilePhoto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.photoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfilePhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
