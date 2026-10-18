import 'package:fitstrong_gym/src/custom_import.dart';

/// Members that were deleted but can still be brought back.
class RecycleBinPage extends StatefulWidget {
  const RecycleBinPage({super.key});

  @override
  State<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends State<RecycleBinPage> {
  bool _emptying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.fetchRecycleBinMembers();
  }

  /// Deleting for good cannot be undone, so it asks first and spells out how
  /// many members and photos are about to go.
  Future<void> _confirmEmptyBin(int count) async {
    final t = context.shadcn;
    final confirmed = await showShadcnAlertDialog(
      context,
      icon: ShadcnIconBadge(
        Icons.delete_forever_rounded,
        color: t.destructive,
      ),
      title: 'Empty recycle bin?',
      description:
          'This permanently deletes $count member${count == 1 ? '' : 's'} and '
          'their photos. This cannot be undone.',
      confirmLabel: 'Delete forever',
      destructive: true,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _emptying = true);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    try {
      final removed = await memberProvider.emptyRecycleBin();
      if (!mounted) return;
      showSuccessToast(
        context,
        'Recycle bin emptied',
        description:
            '$removed member${removed == 1 ? '' : 's'} removed for good',
      );
    } catch (_) {
      if (!mounted) return;
      showErrorToast(context, 'Could not empty the recycle bin');
    } finally {
      if (mounted) setState(() => _emptying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final memberProvider = Provider.of<MemberProvider>(context);
    final recycleBinMembers = memberProvider.recycleBinMembers;

    return AppScaffold(
      title: 'Recycle bin',
      leading: ShadcnButton(
        variant: ShadcnButtonVariant.ghost,
        size: ShadcnButtonSize.icon,
        onPressed: () => Navigator.popAndPushNamed(context, '/home'),
        child: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
      actions: [
        ShadcnButton(
          variant: ShadcnButtonVariant.ghost,
          size: ShadcnButtonSize.icon,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(screen: 'RecycleBin'),
            ),
          ),
          child: const Icon(Icons.search_rounded, size: 20),
        ),
        if (recycleBinMembers.isNotEmpty)
          ShadcnButton(
            variant: ShadcnButtonVariant.ghost,
            size: ShadcnButtonSize.icon,
            loading: _emptying,
            foregroundColor: t.destructive,
            onPressed: () => _confirmEmptyBin(recycleBinMembers.length),
            child: const Icon(Icons.delete_sweep_outlined, size: 20),
          ),
      ],
      body: recycleBinMembers.isEmpty
          ? const MembersQuietBox(screen: 'recycle')
          : RefreshIndicator(
              color: t.primary,
              backgroundColor: t.card,
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  ShadcnSpacing.lg,
                  ShadcnSpacing.md,
                  ShadcnSpacing.lg,
                  ShadcnSpacing.xl4,
                ),
                itemCount: recycleBinMembers.length,
                itemBuilder: (context, index) => RecycleMemberCard(
                  recycleBinMember: recycleBinMembers[index],
                ),
              ),
            ),
    );
  }
}
