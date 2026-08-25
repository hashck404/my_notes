import 'package:my_notes/features/note/data/model/note_model.dart';

enum NoteChangeType { added, modified, removed }

class NoteChange {
  final NoteChangeType type;

  final NoteModel? note;
  final String id;

  NoteChange({required this.type, this.note, required this.id});
}
