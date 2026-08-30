import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:my_notes/features/note/data/model/note_model.dart';

class HiveBoxes {
  final Box<UserModel> userBox;
  final Box<NoteModel> noteBox;
  HiveBoxes({required this.userBox, required this.noteBox});
}
