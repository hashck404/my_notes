import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/features/note/provider/note_provider.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, void>(SessionController.new);

class SessionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}
  Future<void> logOut() async {
    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      ref.read(noteSyncServicesProvider).stopLiveSync();
      await ref.read(noteControllerProvider.notifier).clearAllData();
      await ref.read(authControllerProvider.notifier).logOut();
    });
  }
}
