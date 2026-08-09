import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor { dev, staging, prod }

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
