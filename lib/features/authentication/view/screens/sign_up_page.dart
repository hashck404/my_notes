import 'package:flutter/material.dart';
import 'package:my_notes/features/authentication/view/widgets/auth_field.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            'sign up.',
            style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                AuthField(controller: _nameNameController, hint: 'Name'),

                SizedBox(height: 10),
                AuthField(controller: _emailController, hint: 'Email'),
                SizedBox(height: 10),

                AuthField(controller: _passwordController, hint: 'Password'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),

            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 70),
                textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text('sign up', style: TextStyle(fontSize: 28)),
            ),
          ),
        ],
      ),
    );
  }
}
