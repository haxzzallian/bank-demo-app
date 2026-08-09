import 'package:google_fonts/google_fonts.dart';
import 'main_prod.dart' as prod;

Future<void> main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await prod.main();
}
