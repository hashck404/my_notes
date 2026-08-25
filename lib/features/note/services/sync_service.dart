import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/core/utils/logger.dart';
import 'package:my_notes/core/utils/show_toast_bar.dart';
import 'package:my_notes/features/note/data/model/note_change_model.dart';
import 'package:my_notes/features/note/repository/note_repository.dart';

class NoteSyncServices {
  final NoteRepository _noteRepository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<List<NoteChange>>? _subscription;

  NoteSyncServices({
    required FirebaseAuth firebaseAuth,
    required NoteRepository noteRepository,
  }) : _noteRepository = noteRepository,
       _firebaseAuth = firebaseAuth;

  Future<void> startLiveSync() async {
    final ownerId = _firebaseAuth.currentUser?.uid;
    if (ownerId == null) return;

    _subscription?.cancel();

    _subscription = _noteRepository
        .watchNoteChanges(ownerId)
        .listen(
          (changes) async {
            for (NoteChange change in changes) {
              switch (change.type) {
                case NoteChangeType.added:
                case NoteChangeType.modified:
                  await _noteRepository.applyRemoteNote(change.note!);
                  break;
                case NoteChangeType.removed:
                  await _noteRepository.applyRemoteNoteDelete(change.id);
              }
            }
          },
          onError: (e, s) {
            logger.e(e.toString(), stackTrace: s);
            showToastBar('Live sync failed: ${e.toString()}');
          },
        );
  }

  void stopLiveSync() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> syncAll() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    await claimUnownedNote();
    await pushUnsyncedNotes();
    await completePendingDelete();
  }

  Future<void> completePendingDelete() async {
    final pendingDeleteNotes = _noteRepository.getPendingDeleteNotes();
    var failureCount = 0;

    for (final pendingDeleteNote in pendingDeleteNotes) {
      final result = await _noteRepository.deleteNote(pendingDeleteNote.id);

      result.fold((failure) {
        failureCount++;
        logger.e(failure.message);
      }, (_) {});
    }

    if (failureCount > 0) {
      showToastBar(
        failureCount == 1
            ? 'Failed to delete 1 note'
            : 'Failed to delete $failureCount notes',
      );
    }
  }

  Future<void> pushUnsyncedNotes() async {
    final unsyncedNotes = _noteRepository.getUnsyncedNotes();
    var failureCount = 0;

    for (final unsyncedNote in unsyncedNotes) {
      final result = await _noteRepository.pushUnsyncedNote(unsyncedNote.id);
      result.fold((failure) {
        failureCount++;
        logger.e(failure.message);
      }, (_) {});
    }

    if (failureCount > 0) {
      showToastBar(
        failureCount == 1
            ? 'Failed to sync 1 note'
            : 'Failed to sync $failureCount notes',
      );
    }
  }

  Future<void> claimUnownedNote() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    final unownedNotes = _noteRepository.getUnownedNotes();
    var failureCount = 0;

    for (final unownedNote in unownedNotes) {
      final result = await _noteRepository.claimUnownedNote(
        userId,
        unownedNote.id,
      );

      result.fold((failure) {
        failureCount++;
        logger.e(failure.message);
      }, (_) {});
    }

    if (failureCount > 0) {
      showToastBar(
        failureCount == 1
            ? 'Failed to claim 1 note'
            : 'Failed to claim $failureCount notes',
      );
    }
  }
}
