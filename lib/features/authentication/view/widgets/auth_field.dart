import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    this.hint,
    this.validate,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validate;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      controller: controller,
      validator: validate,
      decoration: InputDecoration(
        hint: Text(hint ?? ''),
        border: OutlineInputBorder(),
      ),
    );
  }
}
