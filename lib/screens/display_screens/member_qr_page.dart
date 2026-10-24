import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:fitstrong_gym/resources/member_qr_card.dart';
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
      final plans = Provider.of<GymPlanProvider>(context, listen: false).plans;
      final plan = GymPlanModel.findById(plans, _member.planId);

      final bytes = await renderMemberQrCard(MemberQrCardData(
        memberName: _member.name,
        token: _member.checkinToken,
        gymName: user?.merchantName.isNotEmpty == true
            ? user!.merchantName
            : (user?.name ?? ''),
        lines: [
          if (plan != null) (label: 'Plan', value: plan.name),
          (label: 'Valid till', value: formatCardDate(_member.expiryDate)),
        ],
      ));
      if (bytes == null) throw StateError('nothing to draw');

      if (!mounted) return;
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
                      const ShadcnGap(ShadcnSpacing.lg),
                      ShadcnText(
                        'This code does not change. The same image keeps '
                        'working every visit.',
                        variant: ShadcnTextVariant.muted,
                        textAlign: TextAlign.center,
                      ),
                      const ShadcnGap(ShadcnSpacing.xl2),
                      const Divider(height: 1),
                      const ShadcnGap(ShadcnSpacing.lg),
                      ShadcnText(
                        'Lost phone, or code shared around?',
                        variant: ShadcnTextVariant.small,
                      ),
                      const ShadcnGap(ShadcnSpacing.xs),
                      ShadcnText(
                        'Issuing a new code stops the old one working '
                        'immediately.',
                        variant: ShadcnTextVariant.muted,
                        textAlign: TextAlign.center,
                      ),
                      const ShadcnGap(ShadcnSpacing.md),
                      ShadcnButton(
                        variant: ShadcnButtonVariant.outline,
                        onPressed: _busy ? null : _reissue,
                        leading: const Icon(Icons.autorenew_rounded, size: 18),
                        child: const Text('Issue a new code'),
                      ),
                      const ShadcnGap(ShadcnSpacing.lg),
                    ],
                  ),
                ),
    );
  }
}
