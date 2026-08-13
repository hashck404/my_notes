import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_notes/core/provider/connection_checker_provider.dart';
import 'package:my_notes/core/provider/firebase_providers.dart';
import 'package:my_notes/features/home/data/data_source/home_local_data_source.dart';
import 'package:my_notes/features/home/data/data_source/home_remote_data_source.dart';
import 'package:my_notes/features/home/data/model/note_model.dart';
import 'package:my_notes/features/home/data/repository/home_repository_impl.dart';
import 'package:my_notes/features/home/repository/home_repository.dart';

final noteBoxProvider = Provider<Box<NoteModel>>(
  (ref) => throw UnimplementedError(),
);

final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>(
  (ref) => HomeLocalDataSource(noteBox: ref.watch(noteBoxProvider)),
);

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>(
  (ref) =>
      HomeRemoteDataSource(firebaseFirestore: ref.watch(firestoreProvider)),
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    homeLocalDataSource: ref.watch(homeLocalDataSourceProvider),
    homeRemoteDataSource: ref.watch(homeRepositoryProvider),
    connectionChecker: ref.watch(connectionCheckerProvider),
  ),
);
