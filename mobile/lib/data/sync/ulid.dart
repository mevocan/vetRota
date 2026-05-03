import 'dart:math';

// Crockford base32 alfabesi (ULID standardi).
const _crockford = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
final _rng = Random.secure();

// 26 karakter ULID: 10 char timestamp (48 bit) + 16 char random (80 bit).
// sync-api.md §4.1: client_sync_id ULID 26 char olmali.
String generateUlid([DateTime? now]) {
  final ms = (now ?? DateTime.now().toUtc()).millisecondsSinceEpoch;
  final buf = StringBuffer();

  // Timestamp: 48-bit, sagdan sola 10 karakter base32.
  final tsChars = List<String>.filled(10, '0');
  var t = ms;
  for (var i = 9; i >= 0; i--) {
    tsChars[i] = _crockford[t & 0x1F];
    t >>= 5;
  }
  buf.writeAll(tsChars);

  // Random: 80-bit = 16 karakter base32.
  for (var i = 0; i < 16; i++) {
    buf.write(_crockford[_rng.nextInt(32)]);
  }
  return buf.toString();
}
