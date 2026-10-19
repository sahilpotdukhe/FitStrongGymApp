import 'package:fitstrong_gym/src/custom_import.dart';

/// Correct a member's recorded details. Plan and dates are not editable
/// here — those change through renewal.
class EditMemberDetailsPage extends StatefulWidget {
  const EditMemberDetailsPage({required this.member, super.key});

  final MemberModel member;

  @override
  State<EditMemberDetailsPage> createState() => _EditMemberDetailsPageState();
}

class _EditMemberDetailsPageState extends State<EditMemberDetailsPage> {
  // The form had no key at all before, so its validators never ran and a
  // blank name or a letter in the weight field went straight to Firestore.
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _addressController;
  late TextEditingController _checkInTimeController;
  late TextEditingController _checkOutTimeController;
  bool _loading = false;
  late String _trainerId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _mobileNumberController =
        TextEditingController(text: widget.member.mobileNumber);
    _heightController =
        TextEditingController(text: widget.member.height.toString());
    _weightController =
        TextEditingController(text: widget.member.weight.toString());
    _addressController = TextEditingController(text: widget.member.address);
    _checkInTimeController =
        TextEditingController(text: widget.member.checkInTime);
    _checkOutTimeController =
        TextEditingController(text: widget.member.checkOutTime);
    _trainerId = widget.member.trainerId;
    // Loaded here so the trainer picker has something to show straight away.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TrainerProvider>(context, listen: false).fetchTrainers();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileNumberController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _addressController.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final trainers = Provider.of<TrainerProvider>(context).activeTrainers;

    return Stack(
      children: [
        AppScaffold(
          title: 'Edit member',
          bottomBar: ShadcnButton(
            fullWidth: true,
            size: ShadcnButtonSize.lg,
            loading: _loading,
            leading: const Icon(Icons.check_rounded, size: 18),
            onPressed: _updateMemberDetails,
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
                Center(
                  child: Column(
                    children: [
                      AppAvatar(
                        widget.member.photoUrl,
                        size: 96,
                        backgroundColor: t.secondary,
                      ),
                      const ShadcnGap(ShadcnSpacing.sm),
                      // Says why there is no camera badge here, rather than
                      // leaving people tapping a photo that cannot change.
                      ShadcnText(
                        'Photos are set when the member is added',
                        variant: ShadcnTextVariant.small,
                      ),
                    ],
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                ShadcnInput(
                  controller: _nameController,
                  label: 'Full name',
                  textCapitalization: TextCapitalization.words,
                  leading: const Icon(Icons.person_outline_rounded, size: 18),
                  validator: ShadcnValidators.required('Please enter a name'),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _mobileNumberController,
                  label: 'Mobile number',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  leading: const Icon(Icons.phone_outlined, size: 18),
                  validator: ShadcnValidators.combine([
                    ShadcnValidators.required('Please enter a mobile number'),
                    ShadcnValidators.pattern(
                      RegExp(r'^[0-9]{10}$'),
                      'Enter a 10 digit mobile number',
                    ),
                  ]),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ShadcnInput(
                        controller: _heightController,
                        label: 'Height (ft)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: ShadcnValidators.combine([
                          ShadcnValidators.required('Required'),
                          ShadcnValidators.numeric('Numbers only'),
                        ]),
                      ),
                    ),
                    const ShadcnGap(ShadcnSpacing.md),
                    Expanded(
                      child: ShadcnInput(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: ShadcnValidators.combine([
                          ShadcnValidators.required('Required'),
                          ShadcnValidators.numeric('Numbers only'),
                        ]),
                      ),
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _addressController,
                  label: 'Address',
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  validator:
                      ShadcnValidators.required('Please enter an address'),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                AppTrainerSelect(
                  trainers: trainers,
                  value: _trainerId,
                  onChanged: (value) => setState(() => _trainerId = value),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppPickerField(
                        label: 'Check in',
                        icon: Icons.schedule_rounded,
                        value: _checkInTimeController.text,
                        placeholder: 'Select time',
                        onTap: () => _pickTime(_checkInTimeController),
                      ),
                    ),
                    const ShadcnGap(ShadcnSpacing.md),
                    Expanded(
                      child: AppPickerField(
                        label: 'Check out',
                        icon: Icons.schedule_rounded,
                        value: _checkOutTimeController.text,
                        placeholder: 'Select time',
                        onTap: () => _pickTime(_checkOutTimeController),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_loading) const AppSavingOverlay(message: 'Saving changes…'),
      ],
    );
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime:
          MemberModel.stringToTimeOfDay(controller.text) ?? TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      setState(() => controller.text = pickedTime.format(context));
    }
  }

  Future<void> _updateMemberDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('members')
            .doc(widget.member.id)
            .update({
          'name': _nameController.text,
          'mobileNumber': _mobileNumberController.text,
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'address': _addressController.text,
          'checkInTime': _checkInTimeController.text,
          'checkOutTime': _checkOutTimeController.text,
          'trainerId': _trainerId,
        });

        // Keeps the in-memory lists in step, so the member list behind this
        // screen shows the new details without a manual refresh.
        if (mounted) {
          await Provider.of<MemberProvider>(context, listen: false)
              .getAllMembers();
        }

        if (!mounted) return;
        setState(() => _loading = false);
        await showSuccessDialog(
          context: context,
          title: 'Details updated',
          desc: '${_nameController.text}\'s record has been saved.',
        );
        if (!mounted) return;
        goHome(context);
        return;
      }
    } catch (_) {
      if (!mounted) return;
      showErrorDialog(
        context: context,
        title: 'Could not save changes',
        desc: 'Check your connection and try again.',
      );
    }

    if (mounted) setState(() => _loading = false);
  }
}
