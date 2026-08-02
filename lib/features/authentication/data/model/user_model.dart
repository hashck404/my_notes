import 'package:flutter/foundation.dart';

class UserModel {
  final String uid;
  final String userName;
  final String email;
  final String createdAt;
  UserModel({
    required this.uid,
    required this.userName,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      userName: data['userName'],
      email: data['email'],
      createdAt: data['createdAt'],
    );
  }
}
