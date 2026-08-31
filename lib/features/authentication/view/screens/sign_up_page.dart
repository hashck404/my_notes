import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/utils/show_snackbar.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/features/authentication/view/screens/sign_in_page.dart';
import 'package:my_notes/features/authentication/view/widgets/auth_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:my_notes/features/note/view/pages/note_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key, required this.authModeToggle});
  final VoidCallback authModeToggle;
  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Please enter a username';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(name.trim())) {
      return 'Username must be 3-20 characters and contain only letters, numbers, and _';
    }

    return null;
  }

  String? _validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Please enter your email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          if (error is Failure) {
            showSnackbar(
              context,
              error.message,
              const Icon(Icons.error_outline),
            );
          }
        },
        data: (_) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => NotePage()));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my notes',
          style: TextStyle(fontFamily: 'junicode', fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (ctx) => NotePage())),
            child: Text('skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        'Sign up.',
                        style: TextStyle(
                          fontFamily: 'junicode',
                          fontSize: 60,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      AuthField(
                        controller: _nameController,
                        hint: 'Name',
                        validate: _validateName,
                      ),

                      const SizedBox(height: 10),

                      AuthField(
                        controller: _emailController,
                        hint: 'Email',
                        validate: _validateEmail,
                      ),

                      const SizedBox(height: 10),

                      AuthField(
                        controller: _passwordController,
                        hint: 'Password',
                        validate: _validatePassword,
                        isPassword: true,
                      ),

                      const SizedBox(height: 60),

                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(authControllerProvider.notifier)
                                .signUp(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                  _nameController.text.trim(),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 70),
                          textStyle: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(color: Colors.grey.shade800),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          widget.authModeToggle();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 70),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade800),
                            borderRadius: BorderRadiusGeometry.all(
                              Radius.circular(50),
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'sign in',
                          style: TextStyle(color: Colors.white, fontSize: 28),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (authState.isLoading)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: LoadingAnimationWidget.fallingDot(
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
