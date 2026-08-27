import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/core/network/connection_checker.dart';
import 'package:my_notes/core/utils/logger.dart';
import 'package:my_notes/features/note/data/data_source/note_local_data_source.dart';
import 'package:my_notes/features/note/data/data_source/note_remote_data_source.dart';
import 'package:my_notes/features/note/data/model/note_change_model.dart';
import 'package:my_notes/features/note/data/model/note_model.dart';
import 'package:my_notes/features/note/repository/note_repository.dart';
import 'package:uuid/uuid.dart';

class NoteRepositoryImpl implements NoteRepository {
  final FirebaseAuth _firebaseAuth;
  final NoteLocalDataSource _noteLocalDataSource;
  final NoteRemoteDataSource _noteRemoteDataSource;
  final ConnectionChecker _connectionChecker;

  NoteRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required NoteLocalDataSource noteLocalDataSource,
    required NoteRemoteDataSource noteRemoteDataSource,
    required ConnectionChecker connectionChecker,
  }) : _firebaseAuth = firebaseAuth,
       _noteLocalDataSource = noteLocalDataSource,
       _noteRemoteDataSource = noteRemoteDataSource,
       _connectionChecker = connectionChecker;

  @override
  Stream<List<NoteModel>> watchNotes() async* {
    final stream = _noteLocalDataSource.watchNotes();
    await for (final data in stream) {
      final sortedList = List<NoteModel>.from(data)
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.localUpdatedAt.compareTo(a.localUpdatedAt);
        });

      yield sortedList;
    }
  }

  @override
  Future<Either<Failure, void>> createNote(
    String? content,
    bool? isPinned,
  ) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;

      final model = NoteModel(
        ownerId: userId,
        id: const Uuid().v4(),
        content: content,
        remoteCreatedAt: null,
        remoteUpdatedAt: null,
        localUpdatedAt: DateTime.now().toUtc(),
        isPinned: isPinned ?? false,
        isSync: false,
        pendingDelete: false,
      );

      if (await _connectionChecker.isConnected && userId != null) {
        await _noteRemoteDataSource.upsertNote(model);
        await _noteLocalDataSource.saveNote(model.copyWith(isSync: true));
      } else {
        await _noteLocalDataSource.saveNote(model);
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
    String? content,
    bool? isPinned,
    bool? pendingDelete,
  ) async {
    try {
      final model = _noteLocalDataSource.getNote(id);
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
        content: content,
        isSync: false,
      );

      if (await _connectionChecker.isConnected && userId != null) {
        await _noteRemoteDataSource.upsertNote(updateModel);
        await _noteLocalDataSource.saveNote(updateModel.copyWith(isSync: true));
      } else {
        await _noteLocalDataSource.saveNote(updateModel);
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
    return _noteRemoteDataSource.watchNoteChanges(ownerId);
  }

  @override
  Future<void> applyRemoteNote(NoteModel note) async {
    final local = _noteLocalDataSource.getNote(note.id);

    if (local == null) {
      await _noteLocalDataSource.saveNote(note);
      return;
    }

    final incoming = note.remoteUpdatedAt;
    final existing = local.remoteUpdatedAt;

    if (incoming == null) return;

    if (existing == null || incoming.isAfter(existing)) {
      await _noteLocalDataSource.saveNote(note);
    }
  }

  @override
  Future<void> applyRemoteNoteDelete(String id) async {
    await _noteLocalDataSource.removeNote(id);
  }

  @override
  Future<Either<Failure, void>> claimUnownedNote(
    String ownerId,
    String noteId,
  ) async {
    try {
      final note = _noteLocalDataSource.getNote(noteId);
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
      await _noteLocalDataSource.saveNote(claimed);

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
      final localModel = _noteLocalDataSource.getNote(id);
      if (localModel == null) {
        return Left(
          Failure(
            message: 'failed to find the note in the local data source to sync',
            type: FailureType.unknownFailure,
          ),
        );
      }

      await _noteRemoteDataSource.upsertNote(localModel);
      await _noteLocalDataSource.saveNote(localModel.copyWith(isSync: true));

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
    return _noteLocalDataSource.getPendingDeleteNotes();
  }

  @override
  List<NoteModel> getUnownedNotes() {
    return _noteLocalDataSource.getUnownedNotes();
  }

  @override
  List<NoteModel> getUnsyncedNotes() {
    return _noteLocalDataSource.getAllUnsyncedNotes();
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      final model = _noteLocalDataSource.getNote(noteId);
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
        await _noteLocalDataSource.removeNote(noteId);

        return const Right(null);
      }

      final userId = _firebaseAuth.currentUser?.uid;

      if (await _connectionChecker.isConnected && userId != null) {
        await _noteRemoteDataSource.deleteNote(noteId);
        await _noteLocalDataSource.removeNote(noteId);
        logger.i('note deleted');
        return const Right(null);
      } else {
        await _noteLocalDataSource.saveNote(
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
