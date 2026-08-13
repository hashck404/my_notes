import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_notes/features/home/data/model/note_model.dart';

class HomeLocalDataSource {
  final Box<NoteModel> _noteBox;
  HomeLocalDataSource({required Box<NoteModel> noteBox}) : _noteBox = noteBox;

  Future<void> saveNote(NoteModel note) async {
    await _noteBox.put(note.id, note);
  }

  NoteModel? getNote(String id) => _noteBox.get(id);

  List<NoteModel> getAllVisibleNotes() {
    return _noteBox.values.where((n) => !n.pendingDelete).toList();
  }

  List<NoteModel> getPendingDeleteNotes() {
    return _noteBox.values.where((n) => n.pendingDelete).toList();
  }

  List<NoteModel> getAllUnsyncedNotes() {
    return _noteBox.values.where((n) => !n.isSync && !n.pendingDelete).toList();
  }

  List<NoteModel> getUnownedNotes() {
    return _noteBox.values.where((n) => n.ownerId == null).toList();
  }

  Future<void> removeNote(String id) async {
    await _noteBox.delete(id);
  }
}
