import 'package:url_launcher/url_launcher.dart';

/// Opens a WhatsApp chat with a member, with the message already typed in.
///
/// Nothing is ever sent automatically: WhatsApp opens on the chat with the
/// text filled in, and the owner presses send. That is the only thing
/// WhatsApp allows from outside the app, and it is also the safer
/// behaviour — no message leaves the phone without the owner seeing it.
class WhatsAppHelper {
  const WhatsAppHelper._();

  /// Country code added to plain 10-digit numbers. Indian gyms are who this
  /// app is for, and WhatsApp refuses a number without a country code.
  static const String defaultCountryCode = '91';

  /// Turns whatever is stored in the member record — "98765 43210",
  /// "+91-98765-43210", "0 9876543210" — into the digits WhatsApp expects.
  /// Returns null when there is nothing usable to dial.
  static String? normalizeNumber(
    String raw, {
    String countryCode = defaultCountryCode,
  }) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    // A leading 0 is the domestic trunk prefix and is dropped abroad.
    while (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    // Numbers saved as 0091… arrive here as 91… already.
    if (digits.length == 10) digits = '$countryCode$digits';

    // Shorter than a full national number means it was never a real mobile.
    if (digits.length < 10) return null;
    return digits;
  }

  /// True when [raw] can be turned into a number WhatsApp will accept.
  static bool canMessage(String raw) => normalizeNumber(raw) != null;

  /// Opens the chat. Returns false when the number is unusable or no app on
  /// the phone can handle the link, so the caller can say why.
  static Future<bool> openChat({
    required String phoneNumber,
    required String message,
  }) async {
    final number = normalizeNumber(phoneNumber);
    if (number == null) return false;

    // wa.me is WhatsApp's own link format and works for both WhatsApp and
    // WhatsApp Business, falling back to the browser if neither is there.
    final uri = Uri.https('wa.me', '/$number', {'text': message});
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
