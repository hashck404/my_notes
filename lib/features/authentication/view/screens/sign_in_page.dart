import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/utils/show_snackbar.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/features/authentication/view/widgets/auth_field.dart';
import 'package:my_notes/features/authentication/view/widgets/loading_animation.dart';
import 'package:my_notes/features/home/view/home_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Please enter your email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter the password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (error is Failure) {
            showSnackbar(
              context,
              error.message,
              const Icon(Icons.error_outline),
            );
          } else {
            showSnackbar(
              context,
              error.toString(),
              const Icon(Icons.error_outline),
            );
          }
        },

        data: (data) => Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (ctx) => HomePage())),
      );
    });
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Sign in.',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AuthField(
                        controller: _emailController,
                        hint: 'Email',
                        validate: _validateEmail,
                      ),
                      SizedBox(height: 10),
                      AuthField(
                        controller: _passwordController,
                        hint: 'Password',
                        validate: _validatePassword,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(authControllerProvider.notifier)
                                .signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 70),
                          textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade800),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text('Sign in'),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: authState.isLoading,
                child: Align(
                  alignment: Alignment.center,
                  child: LoadingAnimation(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
