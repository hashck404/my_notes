import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:my_notes/core/provider/shared_preferences_provider.dart';
import 'package:my_notes/core/storage/hive_boxes.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/features/note/data/model/note_model.dart';
import 'package:my_notes/features/note/provider/note_provider.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Override>> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPreference = await SharedPreferences.getInstance();

  final hiveBox = await _initHive();
  return [
    sharedPreferencesProvider.overrideWithValue(sharedPreference),
    noteBoxProvider.overrideWithValue(hiveBox.noteBox),
    userBoxProvider.overrideWithValue(hiveBox.userBox),
  ];
}

Future<HiveBoxes> _initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(NoteModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  final userBox = await Hive.openBox<UserModel>('user');
  final noteBox = await Hive.openBox<NoteModel>('notes');

  return HiveBoxes(userBox: userBox, noteBox: noteBox);
}
