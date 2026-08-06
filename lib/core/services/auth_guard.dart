import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import 'token_storage.dart';

class AuthGuard {
  static Future<void> protect(
    BuildContext context, {
    required VoidCallback onAuthenticated,
  }) async {
    final hasToken = await TokenStorage.instance.hasToken();
    if (!hasToken) {
      if (!context.mounted) return;
      context.go(AppRoutes.login);
      return;
    }

    if (!context.mounted) return;
    onAuthenticated();
  }
}
