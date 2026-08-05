import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    this.hint,
    this.validate,
  });
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validate;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validate,
      decoration: InputDecoration(
        hint: Text(hint ?? ''),
        border: OutlineInputBorder(),
          
      ),

    );
  }
}
