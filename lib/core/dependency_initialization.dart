import 'package:firebase_core/firebase_core.dart';
import 'package:my_notes/firebase_options.dart';

Future<void> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
