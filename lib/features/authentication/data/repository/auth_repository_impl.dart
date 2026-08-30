import 'package:firebase_auth/firebase_auth.dart';
import 'package:either_dart/either.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/utils/logger.dart';
import 'package:my_notes/features/authentication/data/data_source/auth_local_data_source.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:my_notes/features/authentication/data/data_source/auth_remote_data_source.dart';
import 'package:my_notes/features/authentication/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDataSource _localDataSource;
  AuthRepositoryImpl(this._remoteDatasource, this._localDataSource);

  @override
  Future<Either<Failure, void>> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final uid = await _remoteDatasource.createUserWithEmailAndPassword(
        email,
        password,
        username,
      );

      final userModel = await _remoteDatasource.getUser(uid);
      if (userModel == null) {
        await _localDataSource.signOut();
        return Left(
          Failure(
            message: 'sign in failed: cannot get user',
            type: FailureType.unknownFailure,
          ),
        );
      }
      await _localDataSource.saveUser(userModel);

      return Right(null);
    } on FirebaseAuthException catch (e) {
      final String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email';
          break;
        case 'weak-password':
          message = 'Password should be at least 6 characters.';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'network-request-failed':
          return Left(
            Failure(
              message: 'No internet connection.',
              type: FailureType.networkFailure,
              details: e.code,
            ),
          );
        default:
          message = 'Something went wrong. Please try again.';
      }

      return Left(
        Failure(
          message: message,
          type: FailureType.authFailure,
          details: e.code,
        ),
      );
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(
        Failure(
          message: 'Something went wrong. Please try again.',

          type: FailureType.unknownFailure,
          details: e.toString(),
        ),
      );
    }
  }

  @override
  UserModel? getUser() {
    return _localDataSource.getUser();
  }

  @override
  Future<Either<Failure, void>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final uid = await _remoteDatasource.loginWithEmailAndPassword(
        email,
        password,
      );

      final userModel = await _remoteDatasource.getUser(uid);
      if (userModel == null) {
        await _localDataSource.signOut();
        return Left(
          Failure(
            message: 'sign in failed: cannot get user',
            type: FailureType.unknownFailure,
          ),
        );
      }

      await _localDataSource.saveUser(userModel);
      return Right(null);
    } on FirebaseAuthException catch (e) {
      final String message;
      final FailureType type;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          type = FailureType.authFailure;
          break;
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          type = FailureType.authFailure;
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Please contact support.';
          type = FailureType.authFailure;
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please wait a moment and try again.';
          type = FailureType.authFailure;
          break;
        case 'network-request-failed':
          message = 'No internet connection.';
          type = FailureType.networkFailure;
          break;
        case 'operation-not-allowed':
          message = 'This sign-in method is currently unavailable.';
          type = FailureType.authFailure;
          break;
        default:
          logger.e('Unhandled FirebaseAuth error code: ${e.code}');
          message = 'Something went wrong. Please try again.';
          type = FailureType.authFailure;
      }

      return Left(Failure(message: message, type: type, details: e.code));
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      return Left(
        Failure(
          message: 'Something went wrong. Please try again.',
          type: FailureType.unknownFailure,
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> logOut() async {
    await _localDataSource.signOut();
  }
}
