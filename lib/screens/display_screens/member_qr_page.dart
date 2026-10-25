import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:fitstrong_gym/resources/member_qr_card.dart';
import 'package:fitstrong_gym/resources/member_qr_share.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
      // The page was handed a copy of the member from whichever list opened
      // it, which may predate their token. Start from the provider's copy.
      final current = provider.members.firstWhere(
        (m) => m.id == widget.member.id,
        orElse: () => widget.member,
      );
      final member = await provider.ensureCheckinToken(current);
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

  Future<void> _share() async {
    if (_busy || _member.checkinToken.isEmpty) return;
    setState(() => _busy = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).getUser;
      final file = await MemberQrShare.render(_member, user);
      if (!mounted) return;

      if (!await MemberQrShare.send(file, _member)) {
        if (!mounted) return;
        await showErrorDialog(
          context: context,
          title: 'Could not share the code',
          desc: 'The image could not be prepared. Please try again.',
        );
      }
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
    final status = context.status;
    final hasToken = _member.checkinToken.isNotEmpty;
    final expired = _member.isExpired();

    return AppScaffold(
      title: 'Check-in code',
      padBody: true,
      bottomBar: hasToken
          ? ShadcnButton(
              fullWidth: true,
              size: ShadcnButtonSize.lg,
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
                      // The code itself leads: name, then the image, then one
                      // line of instruction. Everything that is not the code
                      // sits below the fold.
                      ShadcnText(_member.name, variant: ShadcnTextVariant.h3),
                      if (expired) ...[
                        const ShadcnGap(ShadcnSpacing.sm),
                        ShadcnBadge(
                          style: ShadcnBadgeStyle(
                            backgroundColor: status.dangerSurface,
                            foregroundColor: status.dangerForeground,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Expired — will be turned away'),
                        ),
                      ],
                      const ShadcnGap(ShadcnSpacing.xl),
                      ShadcnCard(
                        child: Container(
                          padding: const EdgeInsets.all(ShadcnSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(t.radiusMd),
                          ),
                          child: QrImageView.withQr(
                            qr: buildCheckinQr(_member.checkinToken),
                            size: 240,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const ShadcnGap(ShadcnSpacing.md),
                      ShadcnText(
                        'Show this at the front desk. The same code works '
                        'every visit.',
                        variant: ShadcnTextVariant.muted,
                        textAlign: TextAlign.center,
                      ),
                      const ShadcnGap(ShadcnSpacing.xl2),
                      const ShadcnSeparator(),
                      const ShadcnGap(ShadcnSpacing.md),
                      // Deliberately plain and last: this kills the code on
                      // the member's phone, so it should never be the thing
                      // the eye lands on first.
                      ShadcnButton(
                        variant: ShadcnButtonVariant.ghost,
                        size: ShadcnButtonSize.sm,
                        onPressed: _busy ? null : _reissue,
                        leading: const Icon(Icons.autorenew_rounded, size: 16),
                        child: const Text('Issue a new code'),
                      ),
                      const ShadcnGap(ShadcnSpacing.xs),
                      ShadcnText(
                        'Use this only if the phone was lost or the code was '
                        'passed around.',
                        variant: ShadcnTextVariant.small,
                        textAlign: TextAlign.center,
                      ),
                      const ShadcnGap(ShadcnSpacing.lg),
                    ],
                  ),
                ),
    );
  }
}
