import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/authentication/data/controller/auth_controller.dart';
import 'package:my_notes/features/authentication/data/data_source/local_data_source.dart';
import 'package:my_notes/features/authentication/data/data_source/remote_data_source.dart';
import 'package:my_notes/features/authentication/data/repository/auth_repository_impl.dart';
import 'package:my_notes/features/authentication/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(),
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

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

final authLocalDataSource = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(ref.watch(sharedPreferencesProvider)),
);
