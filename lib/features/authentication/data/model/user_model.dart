class UserModel {
  final String uid;
  final String username;
  final String email;
  final String createdAt;
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      username: data['username'],
      email: data['email'],
      createdAt: data['createdAt'],
    );
  }
}
