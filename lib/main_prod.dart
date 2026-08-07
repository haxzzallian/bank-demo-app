import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/config/app_flavor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow google_fonts to fetch fonts at runtime if AssetManifest is missing.
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const ProviderScope(child: BankDumpApp(flavor: AppFlavor.prod)));
}
