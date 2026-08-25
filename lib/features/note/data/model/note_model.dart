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
  final String? content;
  @HiveField(3)
  final DateTime? remoteCreatedAt;
  @HiveField(4)
  final DateTime? remoteUpdatedAt;
  @HiveField(5)
  final bool isPinned;
  @HiveField(6)
  final bool isSync;
  @HiveField(7)
  final bool pendingDelete;
  @HiveField(8)
  final DateTime localUpdatedAt;

  NoteModel({
    required this.ownerId,
    required this.id,
    required this.content,
    required this.remoteCreatedAt,
    required this.remoteUpdatedAt,
    required this.isPinned,
    required this.isSync,
    required this.pendingDelete,
    required this.localUpdatedAt,
  });

  NoteModel copyWith({
    String? ownerId,
    String? id,
    String? title,
    String? content,
    DateTime? remoteCreatedAt,
    DateTime? remoteUpdatedAt,
    bool? isPinned,
    bool? isSync,
    bool? pendingDelete,
    DateTime? localUpdatedAt,
  }) {
    return NoteModel(
      ownerId: ownerId ?? this.ownerId,
      id: id ?? this.id,
      content: content ?? this.content,
      remoteCreatedAt: remoteCreatedAt ?? this.remoteCreatedAt,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      isPinned: isPinned ?? this.isPinned,
      isSync: isSync ?? this.isSync,
      pendingDelete: pendingDelete ?? this.pendingDelete,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'ownerId': ownerId,
      'content': content,
      'isPinned': isPinned,
      'remoteUpdatedAt': FieldValue.serverTimestamp(),
    };

    if (remoteCreatedAt == null) {
      data['remoteCreatedAt'] = FieldValue.serverTimestamp();
    }

    return data;
  }

  factory NoteModel.fromFirestore(String id, Map<String, dynamic> data) {
    final remoteUpdatedAt = (data['remoteUpdatedAt'] as Timestamp?)?.toDate();
    return NoteModel(
      ownerId: data['ownerId'] as String?,
      id: id,
      content: data['content'] as String?,
      remoteCreatedAt: (data['remoteCreatedAt'] as Timestamp?)?.toDate(),
      remoteUpdatedAt: remoteUpdatedAt,
      isPinned: data['isPinned'] as bool? ?? false,
      isSync: true,
      pendingDelete: false,
      localUpdatedAt: remoteUpdatedAt ?? DateTime.now().toUtc(),
    );
  }
}
