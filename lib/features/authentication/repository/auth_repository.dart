import 'package:either_dart/either.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  );

  Future<Either<Failure, UserModel>> getUser(String uid);

  Future<Either<Failure, String>> loginWithEmailAndPassword(
    String email,
    String password,
  );
}
