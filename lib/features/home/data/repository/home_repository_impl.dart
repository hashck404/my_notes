import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/network/connection_checker.dart';
import 'package:my_notes/core/utils/logger.dart';
import 'package:my_notes/features/home/data/data_source/home_local_data_source.dart';
import 'package:my_notes/features/home/data/data_source/home_remote_data_source.dart';
import 'package:my_notes/features/home/data/model/note_change_model.dart';
import 'package:my_notes/features/home/data/model/note_model.dart';
import 'package:my_notes/features/home/repository/home_repository.dart';
import 'package:uuid/uuid.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseAuth _firebaseAuth;
  final HomeLocalDataSource _homeLocalDataSource;
  final HomeRemoteDataSource _homeRemoteDataSource;
  final ConnectionChecker _connectionChecker;

  HomeRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required HomeLocalDataSource homeLocalDataSource,
    required HomeRemoteDataSource homeRemoteDataSource,
    required ConnectionChecker connectionChecker,
  }) : _firebaseAuth = firebaseAuth,
       _homeLocalDataSource = homeLocalDataSource,
       _homeRemoteDataSource = homeRemoteDataSource,
       _connectionChecker = connectionChecker;

  @override
  Future<Either<Failure, void>> createNote(
    String? title,
    String? content,
  ) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;

      final model = NoteModel(
        ownerId: userId,
        id: const Uuid().v4(),
        title: title,
        content: content,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        isPinned: false,
        isSync: false,
        pendingDelete: false,
      );

      if (await _connectionChecker.isConnected && userId != null) {
        await _homeRemoteDataSource.upsertNote(model);
        await _homeLocalDataSource.saveNote(model.copyWith(isSync: true));
      } else {
        await _homeLocalDataSource.saveNote(model);
      }
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

  @override
  Future<Either<Failure, void>> updateNote(
    String id,
    String? title,
    String? content,
    bool? isPinned,
    bool? pendingDelete,
  ) async {
    try {
      final model = _homeLocalDataSource.getNote(id);
      if (model == null) {
        return Left(
          Failure(
            message:
                "failed to find the note in the local data source to update",
            type: FailureType.unknownFailure,
          ),
        );
      }

      final userId = _firebaseAuth.currentUser?.uid;

      final updateModel = model.copyWith(
        ownerId: model.ownerId ?? userId,
        isPinned: isPinned,
        pendingDelete: pendingDelete,
        title: title,
        content: content,
        isSync: false,
      );

      if (await _connectionChecker.isConnected && userId != null) {
        await _homeRemoteDataSource.upsertNote(updateModel);
        await _homeLocalDataSource.saveNote(updateModel.copyWith(isSync: true));
      } else {
        await _homeLocalDataSource.saveNote(updateModel);
      }

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

  @override
  Stream<List<NoteChange>> watchNoteChanges(String ownerId) {
    return _homeRemoteDataSource.watchNoteChanges(ownerId);
  }

  @override
  Future<void> applyRemoteNote(NoteModel note) async {
    final local = _homeLocalDataSource.getNote(note.id);
    if (local == null || note.updatedAt.isAfter(local.updatedAt)) {
      await _homeLocalDataSource.saveNote(note);
    }
  }

  @override
  Future<void> applyRemoteNoteDelete(String id) async {
    await _homeLocalDataSource.removeNote(id);
  }

  @override
  Future<Either<Failure, void>> claimUnownedNote(
    String ownerId,
    String noteId,
  ) async {
    try {
      final note = _homeLocalDataSource.getNote(noteId);
      if (note == null) {
        return Left(
          Failure(
            message:
                'failed to find the note in the local data source to claim',
            type: FailureType.unknownFailure,
          ),
        );
      }

      final claimed = note.copyWith(ownerId: ownerId, isSync: false);
      await _homeLocalDataSource.saveNote(claimed);

      return const Right(null);
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
  Future<Either<Failure, void>> pushUnsyncedNote(String id) async {
    try {
      final localModel = _homeLocalDataSource.getNote(id);
      if (localModel == null) {
        return Left(
          Failure(
            message: 'failed to find the note in the local data source to sync',
            type: FailureType.unknownFailure,
          ),
        );
      }

      await _homeRemoteDataSource.upsertNote(localModel);
      await _homeLocalDataSource.saveNote(localModel.copyWith(isSync: true));

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

  @override
  List<NoteModel> getPendingDeleteNotes() {
    return _homeLocalDataSource.getPendingDeleteNotes();
  }

  @override
  List<NoteModel> getUnownedNotes() {
    return _homeLocalDataSource.getUnownedNotes();
  }

  @override
  List<NoteModel> getUnsyncedNotes() {
    return _homeLocalDataSource.getAllUnsyncedNotes();
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      final model = _homeLocalDataSource.getNote(noteId);
      if (model == null) {
        return Left(
          Failure(
            message:
                'failed to find the note in the local data source to delete',
            type: FailureType.unknownFailure,
          ),
        );
      }
      if (!model.isSync) {
        await _homeLocalDataSource.removeNote(noteId);
        return const Right(null);
      }

      final userId = _firebaseAuth.currentUser?.uid;

      if (await _connectionChecker.isConnected && userId != null) {
        await _homeRemoteDataSource.deleteNote(noteId);
        await _homeLocalDataSource.removeNote(noteId);

        return const Right(null);
      } else {
        await _homeLocalDataSource.saveNote(
          model.copyWith(pendingDelete: true),
        );

        return const Right(null);
      }
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
        break;
      case 'not-found':
        message = 'This note no longer exists.';
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
        break;
    }

    return Failure(message: message, type: type, details: e.code);
  }
}
