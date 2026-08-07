import 'package:google_fonts/google_fonts.dart';
import 'main_prod.dart' as prod;

Future<void> main() async {
  // Configure google_fonts before any UI code runs so it can fallback
  // to runtime fetching if AssetManifest.json is not available.
  GoogleFonts.config.allowRuntimeFetching = true;
  await prod.main();
}
