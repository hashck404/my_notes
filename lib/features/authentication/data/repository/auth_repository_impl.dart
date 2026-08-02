import 'package:firebase_auth/firebase_auth.dart';
import 'package:either_dart/either.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/utils/logger.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:my_notes/features/authentication/data/remote_data_source.dart';
import 'package:my_notes/features/authentication/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, String>> createUserWithEmailAndPassword(
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
      return Right(uid);
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
  Future<Either<Failure, UserModel>> getUser(String uid) async {
    try {
      final userModel = await _remoteDatasource.getUser(uid);

      if (userModel == null) {
        logger.e(
          'User doc missing for uid: $uid — signup may have failed to write profile.',
        );
        return Left(
          Failure(
            message:
                'We couldn\'t load your profile. Please try again or contact support.',
            type: FailureType.serverFailure,
            details: 'user-doc-not-found',
          ),
        );
      }
      return Right(userModel);
    } on FirebaseException catch (e) {
      final String message;
      final FailureType type;

      switch (e.code) {
        case 'permission-denied':
          message = 'You don\'t have permission to access this data.';
          type = FailureType.serverFailure;
          break;
        case 'unavailable':
        case 'deadline-exceeded':
          message = 'Server unavailable. Please check your connection.';
          type = FailureType.networkFailure;
          break;
        default:
          logger.e('Unhandled Firestore error code: ${e.code}');
          message = 'Something went wrong. Please try again.';
          type = FailureType.serverFailure;
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
  Future<Either<Failure, String>> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final uid = await _remoteDatasource.loginWithEmailAndPassword(
        email,
        password,
      );
      return Right(uid);
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
}
