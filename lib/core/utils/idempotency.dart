import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

String generateIdempotencyKey() => _uuid.v4();
