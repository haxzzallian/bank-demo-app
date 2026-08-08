import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor { dev, staging, prod }

/// Overridden per-entrypoint in `main_dev.dart`/`main_staging.dart`/
/// `main_prod.dart` via `ProviderScope(overrides: [...])`. Defaults to
/// `prod` so anything reading it before an override is applied (e.g. tests)
/// fails safe rather than accidentally enabling verbose logging.
final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.prod);

extension AppFlavorX on AppFlavor {
  String get nameValue => switch (this) {
    AppFlavor.dev => 'dev',
    AppFlavor.staging => 'staging',
    AppFlavor.prod => 'prod',
  };

  String get displayName => switch (this) {
    AppFlavor.dev => 'BankDump DEV',
    AppFlavor.staging => 'BankDump Staging',
    AppFlavor.prod => 'BankDump',
  };
}
