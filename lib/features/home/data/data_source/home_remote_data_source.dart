import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_notes/features/home/data/model/note_change_model.dart';
import 'package:my_notes/features/home/data/model/note_model.dart';

class HomeRemoteDataSource {
  final FirebaseFirestore _firebaseFirestore;

  HomeRemoteDataSource({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  Future<void> upsertNote(NoteModel note) async {
    await _firebaseFirestore
        .collection('notes')
        .doc(note.id)
        .set(note.toFirestore(), SetOptions(merge: true));
  }

  Future<List<NoteModel>> getAllNotes(String ownerId) async {
    final snapshot = await _firebaseFirestore
        .collection('notes')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return snapshot.docs
        .map((doc) => NoteModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<NoteModel?> getNote(String id) async {
    final doc = await _firebaseFirestore.collection('notes').doc(id).get();
    if (doc.exists) {
      return null;
    }

    return NoteModel.fromFirestore(doc.id, doc.data()!);
  }

  Stream<List<NoteChange>> watchNoteChanges(String ownerId) {
    return _firebaseFirestore
        .collection('notes')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docChanges.map((change) {
            if (change.type == DocumentChangeType.removed) {
              return NoteChange(
                type: NoteChangeType.removed,
                id: change.doc.id,
              );
            }
            final noteModel = NoteModel.fromFirestore(
              change.doc.id,
              change.doc.data()!,
            );
            return NoteChange(
              type: _mapChangeType(change.type),
              note: noteModel,
              id: noteModel.id,
            );
          }).toList();
        });
  }

  Future<void> deleteNote(String noteId) async {
    final batch = _firebaseFirestore.batch();

    final noteRef = _firebaseFirestore.collection('notes').doc(noteId);
    final tombstoneRef = _firebaseFirestore
        .collection('deleted_notes')
        .doc(noteId);

    batch.delete(noteRef);

    batch.set(tombstoneRef, {
      'noteId': noteId,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  NoteChangeType _mapChangeType(DocumentChangeType type) => switch (type) {
    DocumentChangeType.added => NoteChangeType.added,
    DocumentChangeType.modified => NoteChangeType.modified,
    DocumentChangeType.removed => NoteChangeType.removed,
  };
}
