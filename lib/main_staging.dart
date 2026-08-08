import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/config/app_flavor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are resolved from the bundled asset manifest only — never fetched
  // over the network at runtime. `google_fonts` defaults this to `true`, so
  // it has to be set explicitly here too, not just in dev/prod.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    ProviderScope(
      overrides: [appFlavorProvider.overrideWithValue(AppFlavor.staging)],
      child: const BankDumpApp(flavor: AppFlavor.staging),
    ),
  );
}
