import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final FirebaseAuth _firebaseAuth;
  final Box<UserModel> _userBox;
  AuthLocalDataSource({
    required SharedPreferences sharedPreference,
    required FirebaseAuth firebaseAuth,
    required Box<UserModel> userBox,
  }) : _sharedPreferences = sharedPreference,
       _firebaseAuth = firebaseAuth,
       _userBox = userBox;

  Future<void> saveUser(UserModel model) async {
    await _userBox.put('user', model);
  }

  UserModel? getUser() {
    return _userBox.get('user');
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _sharedPreferences.remove('username');
    await _userBox.clear();
  }
}
