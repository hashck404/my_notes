import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/utils/show_snackbar.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/features/authentication/view/widgets/auth_field.dart';
import 'package:my_notes/features/home/view/home_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

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
          ).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    const Text(
                      'sign up.',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

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
                    ),

                    const SizedBox(height: 25),

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
                  ],
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
