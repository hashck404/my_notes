import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/features/home/data/model/note_model.dart';
import 'package:my_notes/features/home/provider/home_provider.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<List<Override>> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPreference = await SharedPreferences.getInstance();
  final noteBox = await _initHive();
  return [
    sharedPreferencesProvider.overrideWithValue(sharedPreference),
    noteBoxProvider.overrideWithValue(noteBox),
  ];
}

Future<Box<NoteModel>> _initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(NoteModelAdapter());
  }
  return Hive.openBox<NoteModel>('notes');
}
