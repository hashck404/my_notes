class NoteModel {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final bool isPinned;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isPinned,
  });
}
