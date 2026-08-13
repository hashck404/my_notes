import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel {
  @HiveField(0)
  final String? ownerId;
  @HiveField(1)
  final String id;
  @HiveField(2)
  final String? title;
  @HiveField(3)
  final String? content;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final DateTime updatedAt;
  @HiveField(6)
  final bool isPinned;
  @HiveField(7)
  final bool isSync;
  @HiveField(8)
  final bool pendingDelete;

  NoteModel({
    required this.ownerId,
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.isSync,
    required this.pendingDelete,
  });

  NoteModel copyWith({
    String? ownerId,
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isSync,
    bool? pendingDelete,
  }) {
    return NoteModel(
      ownerId: ownerId ?? this.ownerId,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isSync: isSync ?? this.isSync,
      pendingDelete: pendingDelete ?? this.pendingDelete,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isPinned': isPinned,
    };
  }

  factory NoteModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NoteModel(
      ownerId: data['ownerId'] as String?,
      id: id,
      title: data['title'] as String?,
      content: data['content'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPinned: data['isPinned'] as bool? ?? false,
      isSync: true,
      pendingDelete: false,
    );
  }
}
