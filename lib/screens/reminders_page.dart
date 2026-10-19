import 'package:fitstrong_gym/src/custom_import.dart';

/// Who to get in touch with today: birthdays, memberships about to run out,
/// and memberships that just lapsed.
///
/// Every row has a WhatsApp button that opens the chat with the message
/// already written. Nothing is ever sent on its own — the owner reads it
/// and presses send.
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    try {
      await memberProvider.getAllMembers();
    } catch (_) {
      // An offline phone still shows whatever was loaded earlier.
    }
    if (!mounted) return;
    setState(() => _loading = false);
    // Opening the screen is also a good moment to re-book tomorrow's
    // notification with today's numbers.
    await ReminderScheduler.refresh(context);
  }

  @override
  Widget build(BuildContext context) {
    final members = Provider.of<MemberProvider>(context).members;
    final digest = ReminderService.build(members);

    return AppScaffold(
      title: 'Reminders',
      body: _loading
          ? const Loading()
          : digest.isEmpty
              ? const AppEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'Nothing needs you today',
                  description:
                      'Birthdays and memberships about to run out show up '
                      'here, with a WhatsApp message ready to send.',
                )
              : RefreshIndicator(
                  color: context.shadcn.primary,
                  backgroundColor: context.shadcn.card,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ShadcnSpacing.lg,
                      ShadcnSpacing.md,
                      ShadcnSpacing.lg,
                      ShadcnSpacing.xl4,
                    ),
                    children: [
                      if (digest.expiring.isNotEmpty) ...[
                        const AppSectionHeader(title: 'Expiring soon'),
                        const ShadcnGap(ShadcnSpacing.md),
                        for (final reminder in digest.expiring)
                          _ReminderCard(reminder: reminder),
                        const ShadcnGap(ShadcnSpacing.lg),
                      ],
                      if (digest.birthdays.isNotEmpty) ...[
                        const AppSectionHeader(title: 'Birthdays'),
                        const ShadcnGap(ShadcnSpacing.md),
                        for (final reminder in digest.birthdays)
                          _ReminderCard(reminder: reminder),
                        const ShadcnGap(ShadcnSpacing.lg),
                      ],
                      if (digest.expired.isNotEmpty) ...[
                        const AppSectionHeader(title: 'Just expired'),
                        const ShadcnGap(ShadcnSpacing.md),
                        for (final reminder in digest.expired)
                          _ReminderCard(reminder: reminder),
                      ],
                    ],
                  ),
                ),
    );
  }
}

/// One person to contact, with the reason and the two ways to reach them.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});

  final MemberReminder reminder;

  ({IconData icon, Color color, String label}) _tone(
    AppStatus status,
    ShadcnTheme t,
  ) {
    switch (reminder.kind) {
      case ReminderKind.birthdayToday:
      case ReminderKind.birthdaySoon:
        return (
          icon: Icons.cake_outlined,
          color: status.info,
          label: 'Birthday ${reminder.whenLabel.toLowerCase()}',
        );
      case ReminderKind.expiringSoon:
        return (
          icon: Icons.schedule_rounded,
          color: status.warning,
          label: 'Expires ${reminder.whenLabel.toLowerCase()}',
        );
      case ReminderKind.expiredRecently:
        return (
          icon: Icons.event_busy_rounded,
          color: status.danger,
          label: 'Expired ${reminder.whenLabel.toLowerCase()}',
        );
    }
  }

  Future<void> _message(BuildContext context) async {
    final gymName =
        Provider.of<UserProvider>(context, listen: false).getUser?.name ?? '';
    final text = ReminderMessages.forReminder(reminder, gymName);

    final opened = await WhatsAppHelper.openChat(
      phoneNumber: reminder.member.mobileNumber,
      message: text,
    );
    if (opened || !context.mounted) return;

    showErrorToast(
      context,
      'Could not open WhatsApp',
      description: WhatsAppHelper.canMessage(reminder.member.mobileNumber)
          ? 'Check that WhatsApp is installed on this phone.'
          : '${reminder.member.name} has no usable mobile number saved.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final tone = _tone(context.status, t);
    final member = reminder.member;

    return Padding(
      padding: const EdgeInsets.only(bottom: ShadcnSpacing.md),
      child: ShadcnCard(
        padding: const EdgeInsets.all(ShadcnSpacing.md),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailsPage(member: member),
          ),
        ),
        child: Row(
          children: [
            CachedImage(
              imageUrl: member.photoUrl,
              isRound: true,
              radius: 46,
              height: 46,
              width: 46,
              fit: BoxFit.cover,
            ),
            const ShadcnGap(ShadcnSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: t.cardForeground,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(tone.icon, size: 13, color: tone.color),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          tone.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: tone.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const ShadcnGap(ShadcnSpacing.sm),
            ShadcnButton(
              size: ShadcnButtonSize.sm,
              variant: ShadcnButtonVariant.outline,
              leading: const FaIcon(FontAwesomeIcons.whatsapp, size: 15),
              onPressed: () => _message(context),
              child: const Text('Message'),
            ),
          ],
        ),
      ),
    );
  }
}
