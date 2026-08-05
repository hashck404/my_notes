import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSource(this.sharedPreferences);

  Future<void> saveUsername(String username) async {
    await sharedPreferences.setString('username', username);
  }

  Future<String> getUsername() async {
    final username = sharedPreferences.getString('username');

    if (username == null) {
      throw Exception('Username not found');
    }

    return username;
  }
}
