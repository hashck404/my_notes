import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/app_theme/dark_theme.dart';
import 'package:my_notes/core/dependency_initialization.dart';
import 'package:my_notes/features/authentication/view/screens/sign_in_page.dart';
import 'package:my_notes/features/authentication/view/screens/sign_up_page.dart';
import 'package:my_notes/features/note/view/pages/note_editing_page.dart';
import 'package:my_notes/features/note/view/pages/note_page.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await initDependencies();
  runApp(ProviderScope(overrides: overrides, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      title: 'Flutter Demo',
      theme: DarkTheme.darkTheme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.idTokenChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return NotePage();
        },
      ),
    );
  }
}
