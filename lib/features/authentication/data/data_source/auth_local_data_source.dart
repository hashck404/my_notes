import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSource({required SharedPreferences sharedPreference})
    : _sharedPreferences = sharedPreference;

  Future<void> saveUsername(String username) async {
    await _sharedPreferences.setString('username', username);
  }

  Future<String> getUsername() async {
    final username = _sharedPreferences.getString('username');

    if (username == null) {
      throw Exception('Username not found');
    }

    return username;
  }
}
