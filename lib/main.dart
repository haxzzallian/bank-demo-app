import 'package:google_fonts/google_fonts.dart';
import 'main_prod.dart' as prod;

Future<void> main() async {
  // Fonts are resolved from the bundled asset manifest only — never fetched
  // over the network at runtime. Keeps startup deterministic and avoids a
  // banking app depending on an external CDN just to render text.
  GoogleFonts.config.allowRuntimeFetching = false;
  await prod.main();
}
