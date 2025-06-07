import 'package:hive/hive.dart';

part 'profile_photo.g.dart';

@HiveType(typeId: 0)
class ProfilePhoto extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String photoPath;

  ProfilePhoto({
    required this.email,
    required this.photoPath,
  });
}
