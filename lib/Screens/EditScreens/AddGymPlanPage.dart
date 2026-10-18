import 'package:fitstrong_gym/src/custom_import.dart';

/// Create a membership plan — a name, how long it lasts, and what it costs.
class AddGymPlanPage extends StatefulWidget {
  const AddGymPlanPage({super.key});

  @override
  State<AddGymPlanPage> createState() => _AddGymPlanPageState();
}

class _AddGymPlanPageState extends State<AddGymPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _monthsController = TextEditingController();
  final _daysController = TextEditingController(text: '0');
  final _feeController = TextEditingController();
  bool _isLoading = false;

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
          title: 'New plan',
          leading: ShadcnButton(
            variant: ShadcnButtonVariant.ghost,
            size: ShadcnButtonSize.icon,
            onPressed: () => Navigator.popAndPushNamed(context, '/home'),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          bottomBar: ShadcnButton(
            fullWidth: true,
            size: ShadcnButtonSize.lg,
            loading: _isLoading,
            leading: const Icon(Icons.check_rounded, size: 18),
            onPressed: _saveForm,
            child: const Text('Create plan'),
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
                  placeholder: 'e.g. Quarterly',
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
                        placeholder: '3',
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
                        placeholder: '0',
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
                const ShadcnGap(ShadcnSpacing.sm),
                ShadcnText(
                  'A plan can be months, days, or both — 1 month plus 15 days, for example.',
                  variant: ShadcnTextVariant.small,
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _feeController,
                  label: 'Fee',
                  placeholder: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  leading: const Text('₹'),
                  validator: ShadcnValidators.combine([
                    ShadcnValidators.required('Please enter the fee'),
                    ShadcnValidators.numeric('Numbers only'),
                  ]),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) const AppSavingOverlay(message: 'Creating plan…'),
      ],
    );
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    // A plan of zero length would make every membership expire the day it
    // starts, and the plans list would divide by zero working out its
    // monthly price.
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

    setState(() => _isLoading = true);

    final newPlan = GymPlanModel(
      id: '',
      // ID will be generated by Firestore
      name: _nameController.text,
      months: months,
      days: days,
      fee: double.parse(_feeController.text),
    );

    try {
      await Provider.of<GymPlanProvider>(context, listen: false)
          .addPlan(newPlan);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorDialog(
        context: context,
        title: 'Could not create plan',
        desc: 'Check your connection and try again.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    await showSuccessDialog(
      context: context,
      title: 'Plan created',
      desc: '${newPlan.name} can now be assigned to members.',
    );
    if (!mounted) return;
    Navigator.pop(context);
  }
}
