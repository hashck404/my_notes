import 'package:flutter/material.dart';
import 'package:my_notes/features/authentication/view/screens/sign_in_page.dart';
import 'package:my_notes/features/authentication/view/screens/sign_up_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool isSignIn;

  @override
  void initState() {
    super.initState();
    isSignIn = false;
  }

  void toggleView() {
    setState(() {
      isSignIn = isSignIn ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSignIn) {
      return SignInPage(authModeToggle: toggleView);
    } else {
      return SignUpPage(authModeToggle: toggleView);
    }
  }
}
