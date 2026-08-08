import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/config/app_flavor.dart';
import 'core/error/global_error_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are resolved from the bundled asset manifest only — never fetched
  // over the network at runtime. An old google_fonts + newer Flutter asset
  // manifest format mismatch previously made every font lookup throw and
  // retry in a tight loop, freezing the UI before a single frame painted.
  GoogleFonts.config.allowRuntimeFetching = false;
  configureErrorHandling(showDetails: true);
  runApp(
    ProviderScope(
      overrides: [appFlavorProvider.overrideWithValue(AppFlavor.dev)],
      child: const BankDumpApp(flavor: AppFlavor.dev),
    ),
  );
}
