import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// One member's check-in code, saved to their phone and held up at the desk.
/// It never changes on its own, which is why [_reissue] exists.
class MemberQrPage extends StatefulWidget {
  const MemberQrPage({super.key, required this.member});

  final MemberModel member;

  @override
  State<MemberQrPage> createState() => _MemberQrPageState();
}

class _MemberQrPageState extends State<MemberQrPage> {
  late MemberModel _member = widget.member;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ensureToken();
  }

  /// Older members arrive with no token, so the first visit issues one.
  Future<void> _ensureToken() async {
    final provider = Provider.of<MemberProvider>(context, listen: false);
    try {
      final member = await provider.ensureCheckinToken(widget.member);
      if (!mounted) return;
      setState(() {
        _member = member;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Could not issue a check-in token: $error');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Draws the code on a white square. A transparent background would be
  /// black-on-black in a dark chat, and the margin is the scanner's quiet
  /// zone.
  Future<Uint8List> _renderPng(String payload) async {
    const double code = 880;
    const double margin = 72;
    const double side = code + margin * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, side, side),
      Paint()..color = const Color(0xFFFFFFFF),
    );

    QrPainter(
      data: payload,
      version: QrVersions.auto,
      gapless: true,
      // Always dark on light: inverting a QR stops most scanners reading it.
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
    ).paint(
      canvas..translate(margin, margin),
      const Size(code, code),
    );

    final image =
        await recorder.endRecording().toImage(side.toInt(), side.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _share() async {
    if (_busy || _member.checkinToken.isEmpty) return;
    setState(() => _busy = true);
    try {
      final bytes = await _renderPng(CheckinCode.encode(_member.checkinToken));
      final dir = await getTemporaryDirectory();
      // Named after the member, with awkward characters stripped out.
      final safeName = _member.name
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      final file = File(p.join(
        dir.path,
        'checkin-code-${safeName.isEmpty ? _member.id : safeName}.png',
      ));
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          subject: 'Your gym check-in code',
          text: 'Hi ${_member.name}, save this code to your phone and show it '
              'at the front desk to mark your attendance.',
        ),
      );
    } catch (error) {
      debugPrint('Could not share the check-in code: $error');
      if (!mounted) return;
      await showErrorDialog(
        context: context,
        title: 'Could not share the code',
        desc: 'The image could not be prepared. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reissue() async {
    final confirmed = await showShadcnDialog<bool>(
      context: context,
      builder: (dialogContext) => ShadcnDialog(
        icon: ShadcnIconBadge(
          Icons.autorenew_rounded,
          color: context.shadcn.destructive,
        ),
        title: 'Issue a new code?',
        description:
            '${_member.name}\'s current code stops working immediately and '
            'they will need the new one to check in. Use this if their phone '
            'was lost or their code has been shared around.',
        footer: [
          ShadcnButton(
            fullWidth: true,
            variant: ShadcnButtonVariant.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Issue new code'),
          ),
          ShadcnButton(
            fullWidth: true,
            variant: ShadcnButtonVariant.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final provider = Provider.of<MemberProvider>(context, listen: false);
      final member = await provider.regenerateCheckinToken(_member);
      if (!mounted) return;
      setState(() => _member = member);
      await showSuccessDialog(
        context: context,
        title: 'New code issued',
        desc: 'Share the new code with ${_member.name}. The old one no '
            'longer works.',
      );
    } catch (error) {
      debugPrint('Could not reissue the check-in token: $error');
      if (!mounted) return;
      await showErrorDialog(
        context: context,
        title: 'Could not issue a new code',
        desc: 'Please check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final hasToken = _member.checkinToken.isNotEmpty;

    return AppScaffold(
      title: 'Check-in code',
      padBody: true,
      actions: [
        if (hasToken)
          ShadcnButton(
            variant: ShadcnButtonVariant.ghost,
            size: ShadcnButtonSize.icon,
            onPressed: _busy ? null : _reissue,
            child: const Icon(Icons.autorenew_rounded, size: 20),
          ),
      ],
      bottomBar: hasToken
          ? ShadcnButton(
              fullWidth: true,
              loading: _busy,
              onPressed: _busy ? null : _share,
              leading: const Icon(Icons.ios_share_rounded, size: 18),
              child: const Text('Share code'),
            )
          : null,
      body: _loading
          ? const Loading(message: 'Preparing the code')
          : !hasToken
              ? const AppEmptyState(
                  icon: Icons.qr_code_2_rounded,
                  title: 'No code yet',
                  description:
                      'This member could not be issued a check-in code. '
                      'Check your connection and open this screen again.',
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const ShadcnGap(ShadcnSpacing.lg),
                      ShadcnText(
                        _member.name,
                        variant: ShadcnTextVariant.h3,
                      ),
                      const ShadcnGap(ShadcnSpacing.xs),
                      ShadcnText(
                        _member.isExpired()
                            ? 'Membership expired — this code will be turned '
                                'away at the desk until the plan is renewed.'
                            : 'Save this to your phone and show it at the '
                                'front desk.',
                        variant: ShadcnTextVariant.muted,
                        textAlign: TextAlign.center,
                      ),
                      const ShadcnGap(ShadcnSpacing.xl),
                      ShadcnCard(
                        child: Container(
                          padding: const EdgeInsets.all(ShadcnSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(t.radiusMd),
                          ),
                          child: QrImageView(
                            data: CheckinCode.encode(_member.checkinToken),
                            size: 240,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const ShadcnGap(ShadcnSpacing.xl),
                      ShadcnText(
                        'This code does not expire. If the member loses their '
                        'phone, issue a new one from the button above.',
                        variant: ShadcnTextVariant.muted,
                        textAlign: TextAlign.center,
                      ),
                      const ShadcnGap(ShadcnSpacing.lg),
                    ],
                  ),
                ),
    );
  }
}
