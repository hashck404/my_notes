import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_notes/core/provider/firebase_providers.dart';
import 'package:my_notes/core/provider/shared_preferences_provider.dart';
import 'package:my_notes/features/authentication/data/controller/auth_controller.dart';
import 'package:my_notes/features/authentication/data/data_source/auth_local_data_source.dart';
import 'package:my_notes/features/authentication/data/data_source/auth_remote_data_source.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:my_notes/features/authentication/data/repository/auth_repository_impl.dart';
import 'package:my_notes/features/authentication/repository/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firebaseFirestore: ref.watch(firestoreProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSource),
  ),
);

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
final userBoxProvider = Provider<Box<UserModel>>(
  (ref) => throw UnimplementedError(),
);

final authLocalDataSource = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(
    userBox: ref.watch(userBoxProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    sharedPreference: ref.watch(sharedPreferencesProvider),
  ),
);
