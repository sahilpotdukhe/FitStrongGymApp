import 'package:fitstrong_gym/src/custom_import.dart';

/// The gym's trainers, with the ones who have left kept behind a filter.
class TrainersPage extends StatefulWidget {
  const TrainersPage({super.key});

  @override
  State<TrainersPage> createState() => _TrainersPageState();
}

enum _TrainerFilter { active, all }

class _TrainersPageState extends State<TrainersPage> {
  _TrainerFilter _filter = _TrainerFilter.active;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trainerProvider =
        Provider.of<TrainerProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await Future.wait([
      trainerProvider.fetchTrainers(),
      // The member list is what the per-trainer counts are worked out from,
      // so it has to be loaded before the counts mean anything.
      memberProvider.getAllMembers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final trainerProvider = Provider.of<TrainerProvider>(context);
    final members = Provider.of<MemberProvider>(context).members;

    final all = trainerProvider.trainers;
    final active = trainerProvider.activeTrainers;
    final visible = _filter == _TrainerFilter.active ? active : all;

    return AppScaffold(
      title: 'Trainers',
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.primary,
        foregroundColor: t.primaryForeground,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrainerFormPage()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: all.isEmpty
          ? AppEmptyState(
              icon: Icons.sports_gymnastics_rounded,
              title: 'No trainers yet',
              description:
                  'Add the coaches who work at your gym, then assign members '
                  'to them so you always know who trains who.',
              actionLabel: 'Add trainer',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerFormPage(),
                ),
              ),
            )
          : RefreshIndicator(
              color: t.primary,
              backgroundColor: t.card,
              onRefresh: _load,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ShadcnSpacing.lg,
                      ShadcnSpacing.md,
                      ShadcnSpacing.lg,
                      0,
                    ),
                    child: AppSegmentedFilter<_TrainerFilter>(
                      value: _filter,
                      onChanged: (value) => setState(() => _filter = value),
                      segments: [
                        AppSegment(
                          value: _TrainerFilter.active,
                          label: 'Active',
                          count: active.length,
                        ),
                        AppSegment(
                          value: _TrainerFilter.all,
                          label: 'All',
                          count: all.length,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? AppEmptyState(
                            icon: Icons.person_off_outlined,
                            title: 'No active trainers',
                            description:
                                'Every trainer on your books is marked as '
                                'having left.',
                            actionLabel: 'Show all',
                            onAction: () =>
                                setState(() => _filter = _TrainerFilter.all),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              ShadcnSpacing.lg,
                              ShadcnSpacing.md,
                              ShadcnSpacing.lg,
                              ShadcnSpacing.xl4,
                            ),
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final trainer = visible[index];
                              return TrainerCard(
                                trainer: trainer,
                                memberCount:
                                    membersOfTrainer(members, trainer.id)
                                        .length,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TrainerDetailsPage(trainer: trainer),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
