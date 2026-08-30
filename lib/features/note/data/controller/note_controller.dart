import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/note/provider/note_provider.dart';

class NoteController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  void startNoteSyncingService() async {
    final service = ref.read(noteSyncServicesProvider);
    await service.syncAll();
    await service.startLiveSync();
  }

  void stopNoteSyncService() {
    final service = ref.read(noteSyncServicesProvider);
    service.stopLiveSync();
  }

  Future<void> createNote({required String content, bool? isPinned}) async {
    state = AsyncLoading();
    final repo = ref.read(noteRepositoryProvider);
    final result = await repo.createNote(content, isPinned);

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (success) => state = AsyncData(null),
    );
  }

  Future<void> editNote({
    required String id,
    String? content,
    bool? isPinned,
    bool? pendingDelete,
  }) async {
    state = AsyncLoading();
    final repo = ref.read(noteRepositoryProvider);
    final result = await repo.updateNote(id, content, isPinned, pendingDelete);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (success) => state = AsyncData(null),
    );
  }

  Future<void> deleteNote(String id) async {
    state = AsyncLoading();
    final repo = ref.read(noteRepositoryProvider);
    final result = await repo.deleteNote(id);

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (success) => state = AsyncData(null),
    );
  }

  Future<void> clearAllData() async {
    final repo = ref.watch(noteRepositoryProvider);
    repo.clearAllData();
  }
}
