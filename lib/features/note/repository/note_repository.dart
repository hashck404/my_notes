import 'package:either_dart/either.dart';
import 'package:my_notes/core/error/failures.dart';
import 'package:my_notes/features/note/data/model/note_change_model.dart';
import 'package:my_notes/features/note/data/model/note_model.dart';

abstract class NoteRepository {
  Stream<List<NoteModel>> watchNotes();

  Future<Either<Failure, void>> createNote(String? content, bool? isPinned);

  Future<Either<Failure, void>> updateNote(
    String id,
    String? content,
    bool? isPinned,
    bool? pendingDelete,
  );
  Stream<List<NoteChange>> watchNoteChanges(String ownerId);
  Future<void> applyRemoteNote(NoteModel note);
  Future<void> applyRemoteNoteDelete(String id);
  Future<Either<Failure, void>> claimUnownedNote(String ownerId, String noteId);
  Future<Either<Failure, void>> pushUnsyncedNote(String id);
  List<NoteModel> getPendingDeleteNotes();
  List<NoteModel> getUnsyncedNotes();
  List<NoteModel> getUnownedNotes();
  Future<Either<Failure, void>> deleteNote(String noteId);
  Future<void> clearAllData();
}
