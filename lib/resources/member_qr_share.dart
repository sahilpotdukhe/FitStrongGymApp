import 'dart:io';

import 'package:fitstrong_gym/models/member_model.dart';
import 'package:fitstrong_gym/models/user_model.dart';
import 'package:fitstrong_gym/resources/member_qr_card.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Renders a member's check-in card and hands it to the share sheet.
///
/// Shared by the member's QR screen and the invoice screen shown just after
/// they join, so both send exactly the same image.
class MemberQrShare {
  const MemberQrShare._();

  /// Draws the card and writes it to a temporary file, or null when the
  /// member has no code yet.
  ///
  /// Rendering takes a moment, so screens that know a share is likely call
  /// this early and keep the future; the tap then costs nothing.
  static Future<File?> render(MemberModel member, UserModel? user) async {
    if (member.checkinToken.isEmpty) return null;
    try {
      final bytes = await renderMemberQrCard(MemberQrCardData(
        memberName: member.name,
        token: member.checkinToken,
        gymName: user?.merchantName.isNotEmpty == true
            ? user!.merchantName
            : (user?.name ?? ''),
        gymPhone: user?.phoneNumber ?? '',
      ));
      if (bytes == null) return null;

      final dir = await getTemporaryDirectory();
      // Named after the member, with awkward characters stripped out.
      final safeName = member.name
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      final file = File(p.join(
        dir.path,
        'checkin-code-${safeName.isEmpty ? member.id : safeName}.png',
      ));
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (error) {
      debugPrint('Could not render the check-in card: $error');
      return null;
    }
  }

  /// Opens the share sheet with [file]. Returns false when there is nothing
  /// to send, so the caller can say so.
  static Future<bool> send(File? file, MemberModel member) async {
    // The OS can clear the temp directory at any time.
    if (file == null || !file.existsSync()) return false;

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: 'Your gym check-in code',
        text: 'Hi ${member.name}, save this code to your phone and show it '
            'at the front desk to mark your attendance.',
      ),
    );
    return true;
  }
}
