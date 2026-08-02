import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/core/utils/logger.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:retry/retry.dart';

class AuthRemoteDatasource {
  Future<String> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    //Creates a new user in firebase auth system
    final userCredentials = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final newUser = userCredentials.user;

    if (newUser != null) {
      //Creates a new user document in firestore
      try {
        await retry(
          () => _createUserDocument(newUser.uid, email, username),
          retryIf: (e) =>
              e is FirebaseException &&
              (e.code == 'unavailable' || e.code == 'deadline-exceeded'),
          maxAttempts: 3,
          delayFactor: Duration(milliseconds: 500),
        );
      } catch (e) {
        try {
          await newUser.delete();
        } catch (deleteError) {
          logger.e('Rollback failed — orphaned auth account: ${newUser.uid}');
          rethrow;
        }

        rethrow;
      }
    } else {
      throw Exception('user is null failed to create user document');
    }
    return newUser.uid;
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final userModel = UserModel.fromFirestore(doc.data()!);
      return userModel;
    }
    return null;
  }

  Future<String> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userCredentials = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final User user = userCredentials.user!;

    return user.uid;
    
  }
}

Future<void> _createUserDocument(String uid, email, username) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'uid': uid,
    'email': email,
    'username': username,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
