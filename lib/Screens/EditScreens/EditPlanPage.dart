import 'package:fitstrong_gym/src/custom_import.dart';

/// Change an existing plan's name, length or price.
class EditPlanPage extends StatefulWidget {
  const EditPlanPage({required this.plan, super.key});

  final GymPlanModel plan;

  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _monthsController;
  late final TextEditingController _daysController;
  late final TextEditingController _feeController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan.name);
    _monthsController =
        TextEditingController(text: widget.plan.months.toString());
    _daysController = TextEditingController(text: widget.plan.days.toString());
    _feeController =
        TextEditingController(text: widget.plan.fee.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _monthsController.dispose();
    _daysController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'Edit plan',
          bottomBar: ShadcnButton(
            fullWidth: true,
            size: ShadcnButtonSize.lg,
            loading: _saving,
            leading: const Icon(Icons.check_rounded, size: 18),
            onPressed: _save,
            child: const Text('Save changes'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                ShadcnSpacing.lg,
                ShadcnSpacing.xl,
                ShadcnSpacing.lg,
                ShadcnSpacing.xl2,
              ),
              children: [
                ShadcnInput(
                  controller: _nameController,
                  label: 'Plan name',
                  textCapitalization: TextCapitalization.words,
                  leading: const Icon(Icons.card_membership_outlined, size: 18),
                  validator:
                      ShadcnValidators.required('Please enter a plan name'),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ShadcnInput(
                        controller: _monthsController,
                        label: 'Months',
                        keyboardType: TextInputType.number,
                        validator: ShadcnValidators.combine([
                          ShadcnValidators.required('Required'),
                          ShadcnValidators.pattern(
                            RegExp(r'^\d+$'),
                            'Whole numbers only',
                          ),
                        ]),
                      ),
                    ),
                    const ShadcnGap(ShadcnSpacing.md),
                    Expanded(
                      child: ShadcnInput(
                        controller: _daysController,
                        label: 'Extra days',
                        keyboardType: TextInputType.number,
                        validator: ShadcnValidators.combine([
                          ShadcnValidators.required('Required'),
                          ShadcnValidators.pattern(
                            RegExp(r'^\d+$'),
                            'Whole numbers only',
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _feeController,
                  label: 'Fee',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  leading: const Text('₹'),
                  validator: ShadcnValidators.combine([
                    ShadcnValidators.required('Please enter the fee'),
                    ShadcnValidators.numeric('Numbers only'),
                  ]),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                // Existing members keep the dates they already have; only
                // future renewals use the new length. Worth saying, because
                // editing a plan looks like it might reprice everyone.
                ShadcnText(
                  'Changes apply the next time this plan is sold or renewed. '
                  'Members already on it keep their current expiry date.',
                  variant: ShadcnTextVariant.small,
                ),
              ],
            ),
          ),
        ),
        if (_saving) const AppSavingOverlay(message: 'Saving plan…'),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final months = int.parse(_monthsController.text);
    final days = int.parse(_daysController.text);
    if (months == 0 && days == 0) {
      showErrorToast(
        context,
        'Plan has no length',
        description: 'Set at least one month or one day.',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await Provider.of<GymPlanProvider>(context, listen: false).updatePlan(
        widget.plan.id,
        _nameController.text,
        months,
        days,
        double.parse(_feeController.text),
      );
      if (!mounted) return;
      showSuccessToast(context, 'Plan updated');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorDialog(
        context: context,
        title: 'Could not save plan',
        desc: 'Check your connection and try again.',
      );
    }
  }
}
