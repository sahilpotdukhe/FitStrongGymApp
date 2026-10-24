import 'package:uuid/uuid.dart';

/// A member's permanent check-in code: what their QR image actually contains.
///
/// The code carries a random token rather than the member's Firestore id, so a
/// code that leaks — screenshotted and passed to a friend — can be revoked by
/// issuing that one member a fresh token, leaving the member record and their
/// attendance history untouched. Handing out the id itself would leave no way
/// to do that short of deleting the member.
///
/// The [prefix] lets the front desk scanner reject any other QR someone holds
/// up, a payment code or a Wi-Fi code, before it ever costs a database read.
class CheckinCode {
  const CheckinCode._();

  /// Short, and ours. Deliberately not a URL: a code scanned by a generic QR
  /// app should do nothing at all rather than open something.
  static const String prefix = 'FSGC:';

  /// A fresh token for a member who has none yet, or whose code is being
  /// revoked and reissued.
  static String newToken() => const Uuid().v4();

  /// What gets drawn into the QR image.
  static String encode(String token) => '$prefix$token';

  /// The token inside a scanned [raw] string, or null when the QR is not one
  /// of ours or carries nothing after the prefix.
  static String? decode(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.startsWith(prefix)) return null;
    final token = trimmed.substring(prefix.length);
    return token.isEmpty ? null : token;
  }
}
