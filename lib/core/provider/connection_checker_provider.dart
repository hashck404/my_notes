import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:my_notes/core/network/connection_checker.dart';

final connectionCheckerProvider = Provider(
  (ref) => ConnectionCheckerImpl(
    internetConnection: InternetConnection.createInstance(),
  ),
);
