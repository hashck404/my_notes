import 'package:either_dart/either.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  );

  UserModel? getUser();

  Future<Either<Failure, void>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<void> logOut();
}
