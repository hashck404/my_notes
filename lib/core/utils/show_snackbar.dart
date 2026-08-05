import 'package:flutter/material.dart';

void showSnackbar(
  BuildContext context,
  message,
  Widget? icon, {
  Duration duration = const Duration(seconds: 4),
}) {
  final theme = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(
      backgroundColor: theme.surfaceContainer,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: Row(
        children: [
          Expanded(
            child: Text(message, style: TextStyle(color: theme.onSurface)),
          ),
          ?icon,
        ],
      ),
    ),
  );
}
