import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_notes/core/provider/connection_checker_provider.dart';
import 'package:my_notes/core/provider/firebase_providers.dart';
import 'package:my_notes/features/note/data/controller/note_controller.dart';
import 'package:my_notes/features/note/data/data_source/note_local_data_source.dart';
import 'package:my_notes/features/note/data/data_source/note_remote_data_source.dart';
import 'package:my_notes/features/note/data/model/note_model.dart';
import 'package:my_notes/features/note/data/repository/note_repository_impl.dart';
import 'package:my_notes/features/note/repository/note_repository.dart';
import 'package:my_notes/features/note/services/sync_service.dart';

final noteBoxProvider = Provider<Box<NoteModel>>(
  (ref) => throw UnimplementedError(),
);

final noteLocalDataSourceProvider = Provider<NoteLocalDataSource>(
  (ref) => NoteLocalDataSource(noteBox: ref.watch(noteBoxProvider)),
);

final noteRemoteDataSourceProvider = Provider<NoteRemoteDataSource>(
  (ref) =>
      NoteRemoteDataSource(firebaseFirestore: ref.watch(firestoreProvider)),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    noteLocalDataSource: ref.watch(noteLocalDataSourceProvider),
    noteRemoteDataSource: ref.watch(noteRemoteDataSourceProvider),
    connectionChecker: ref.watch(connectionCheckerProvider),
  ),
);

final noteSyncServicesProvider = Provider<NoteSyncServices>(
  (ref) => NoteSyncServices(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    noteRepository: ref.watch(noteRepositoryProvider),
  ),
);

final noteControllerProvider = AsyncNotifierProvider<NoteController, void>(
  NoteController.new,
);

final noteListProvider = StreamProvider<List<NoteModel>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.watchNotes();
});
