import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/utils/logger.dart';
import 'package:my_notes/features/home/data/model/note_model.dart';

class HomeRepository {
  final _fireStore = FirebaseFirestore.instance;

  Future<Either<Failure, String>> createNewNote(NoteModel model) async {
    try {
      final docRef = await _fireStore.collection('notes').add({
        'title': model.title,
        'content': model.content,
        'createdAt': model.createdAt,
        'isPinned': model.isPinned,
      });
      return Right(docRef.id);
    } on FirebaseException catch (e) {
      return Left(_mapFirestoreError(e));
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

  Future<Either<Failure, void>> editNote(NoteModel model) async {
    try {
      await _fireStore.collection('notes').doc(model.id).update({
        'title': model.title,
        'content': model.content,
        'isPinned': model.isPinned,
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirestoreError(e));
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

  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await _fireStore.collection('notes').doc(noteId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirestoreError(e));
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

  Failure _mapFirestoreError(FirebaseException e) {
    final String message;
    final FailureType type;

    switch (e.code) {
      case 'permission-denied':
        message = 'You don\'t have permission to do this.';
        type = FailureType.serverFailure;
      case 'not-found':
        message = 'This note no longer exists.';
        type = FailureType.serverFailure;
      case 'unavailable':
      case 'deadline-exceeded':
        message = 'Server unavailable. Please check your connection.';
        type = FailureType.networkFailure;
      default:
        logger.e('Unhandled Firestore error code: ${e.code}');
        message = 'Something went wrong. Please try again.';
        type = FailureType.serverFailure;
    }

    return Failure(message: message, type: type, details: e.code);
  }
}
