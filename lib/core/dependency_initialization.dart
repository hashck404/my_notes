import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Override>> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sharedPreference = await SharedPreferences.getInstance();

  return [sharedPreferencesProvider.overrideWithValue(sharedPreference)];
}
