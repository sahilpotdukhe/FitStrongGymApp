import 'package:fitstrong_gym/src/custom_import.dart';

/// Where a membership stands right now.
enum MembershipState { active, expiringSoon, expired }

/// Works out a membership's state from its expiry date.
///
/// "Expiring soon" is new: previously a membership was only ever green or
/// red, so the day before it lapsed looked exactly like the day after it was
/// renewed — and renewals were only noticed once a member was already locked
/// out.
MembershipState membershipStateOf(MemberModel member, {int soonDays = 7}) {
  if (member.isExpired()) return MembershipState.expired;
  final now = DateTime.now();
  final daysLeft = member.expiryDate.difference(now).inDays;
  return daysLeft <= soonDays
      ? MembershipState.expiringSoon
      : MembershipState.active;
}

/// How many whole days until the membership lapses; negative once it has.
int daysUntilExpiry(MemberModel member) =>
    member.expiryDate.difference(DateTime.now()).inDays;

/// Coloured status chip used on member cards, the details page and the lists.
class MembershipBadge extends StatelessWidget {
  const MembershipBadge(
      {super.key, required this.member, this.compact = false});

  final MemberModel member;

  /// Drops the day count, for tight rows.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = context.status;
    final state = membershipStateOf(member);
    final daysLeft = daysUntilExpiry(member);

    final (Color fg, Color bg, String label) = switch (state) {
      MembershipState.active => (
          status.successForeground,
          status.successSurface,
          'Active',
        ),
      MembershipState.expiringSoon => (
          status.warningForeground,
          status.warningSurface,
          compact
              ? 'Due soon'
              : daysLeft <= 0
                  ? 'Expires today'
                  : 'Expires in ${daysLeft}d',
        ),
      MembershipState.expired => (
          status.dangerForeground,
          status.dangerSurface,
          'Expired',
        ),
    };

    return ShadcnBadge(
      style: ShadcnBadgeStyle(
        backgroundColor: bg,
        foregroundColor: fg,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
