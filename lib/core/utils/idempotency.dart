import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// A fresh UUID for the `Idempotency-Key` header, sent on every deposit/
/// withdraw/transfer request per API_RULES.md so retries are safe. Call
/// once per user-initiated attempt — not memoized, since each new attempt
/// should get its own key.
String generateIdempotencyKey() => _uuid.v4();
