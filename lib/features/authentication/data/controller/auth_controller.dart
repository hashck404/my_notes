import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/authentication/data/model/user_model.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signUp(String email, String password, String name) async {
    state = AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.createUserWithEmailAndPassword(
      email,
      password,
      name,
    );

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (success) {
        state = AsyncData(null);
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    state = AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithEmailAndPassword(email, password);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (success) {
        state = AsyncData(null);
      },
    );
  }

  UserModel? getUser() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.getUser();
  }

  Future<void> logOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logOut();
  }
}
