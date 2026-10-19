import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Enrol a new member: their details, the plan they bought, and how they
/// paid. Ends on their invoice.
class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedPaymentMethod;
  static const List<String> _paymentMethods = ['Cash', 'Online'];

  XFile? _photo;
  String? _planId;

  /// '' means nobody is assigned, which is allowed — a gym may not run
  /// personal training at all.
  String _trainerId = '';
  double _selectedPlanFee = 0.0;
  DateTime? _dateOfBirth;
  DateTime? _dateOfAdmission;
  bool _isLoading = false;
  String? gender = 'Male';
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;

  /// Errors for the controls that live outside [Form]'s validation — the
  /// photo and the two dates. They were previously reported as a snackbar
  /// (photo) or silently crashed the save (dates).
  bool _showNonFieldErrors = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
    // Needed for the trainer picker further down the form.
    Provider.of<TrainerProvider>(context, listen: false).fetchTrainers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileNumberController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    // Hidden plans are retired, so they are not offered to a new member.
    final plans = Provider.of<GymPlanProvider>(context).sellablePlans;
    final trainers = Provider.of<TrainerProvider>(context).activeTrainers;
    final UserModel? userModel = Provider.of<UserProvider>(context).getUser;

    return Stack(
      children: [
        AppScaffold(
          title: 'Add member',
          // Only shown when this page was pushed on top of something. As
          // the "Add" tab it sits at the root of the stack, so there is
          // nothing to go back to and the arrow is left off.
          leading: Navigator.of(context).canPop()
              ? ShadcnButton(
                  variant: ShadcnButtonVariant.ghost,
                  size: ShadcnButtonSize.icon,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                )
              : null,
          bottomBar: ShadcnButton(
            fullWidth: true,
            size: ShadcnButtonSize.lg,
            loading: _isLoading,
            leading: const Icon(Icons.check_rounded, size: 18),
            onPressed: _saveForm,
            child: const Text('Save member'),
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
                  child: AppPhotoPicker(
                    localFile: _photo,
                    onPicked: _pickImage,
                    errorText: _showNonFieldErrors && _photo == null
                        ? 'A photo is required'
                        : null,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Center(
                  child: ShadcnText(
                    'Tap to add a photo',
                    variant: ShadcnTextVariant.small,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                _SectionLabel('Personal details'),
                const ShadcnGap(ShadcnSpacing.md),
                ShadcnInput(
                  controller: _nameController,
                  label: 'Full name',
                  placeholder: 'Member name',
                  textCapitalization: TextCapitalization.words,
                  leading: const Icon(Icons.person_outline_rounded, size: 18),
                  validator: ShadcnValidators.required('Please enter a name'),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _mobileNumberController,
                  label: 'Mobile number',
                  placeholder: '10-digit number',
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
                        placeholder: '5.8',
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
                        placeholder: '72',
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
                AppPickerField(
                  label: 'Date of birth',
                  value: _dateOfBirth == null
                      ? null
                      : DateFormat('d MMM yyyy').format(_dateOfBirth!),
                  placeholder: 'Select date of birth',
                  onTap: _pickDateOfBirth,
                  errorText: _showNonFieldErrors && _dateOfBirth == null
                      ? 'Please pick a date of birth'
                      : null,
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _addressController,
                  label: 'Address',
                  placeholder: 'Where the member lives',
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  validator:
                      ShadcnValidators.required('Please enter an address'),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: t.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                ShadcnRadioGroup<String>(
                  value: gender,
                  onChanged: (value) => setState(() => gender = value),
                  direction: Axis.horizontal,
                  options: const [
                    ShadcnRadioOption(value: 'Male', label: 'Male'),
                    ShadcnRadioOption(value: 'Female', label: 'Female'),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                _SectionLabel('Membership'),
                const ShadcnGap(ShadcnSpacing.md),
                AppPickerField(
                  label: 'Admission date',
                  value: _dateOfAdmission == null
                      ? null
                      : DateFormat('d MMM yyyy').format(_dateOfAdmission!),
                  placeholder: 'Select admission date',
                  onTap: _pickDateOfAdmission,
                  errorText: _showNonFieldErrors && _dateOfAdmission == null
                      ? 'Please pick an admission date'
                      : null,
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                AppSelect<String>(
                  label: 'Plan',
                  placeholder: plans.isEmpty
                      ? 'No plans yet — create one first'
                      : 'Select a plan',
                  value: _planId,
                  items: [
                    for (final plan in plans)
                      ShadcnSelectItem(
                        value: plan.id,
                        label: _planLabel(plan),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _planId = value;
                      final selectedPlan = GymPlanModel.findById(plans, value);
                      if (selectedPlan != null) {
                        _selectedPlanFee = selectedPlan.fee;
                      }
                    });
                  },
                  validator: ShadcnValidators.required('Please select a plan'),
                ),
                if (_planId != null) ...[
                  const ShadcnGap(ShadcnSpacing.md),
                  _FeeSummary(fee: _selectedPlanFee),
                ],
                const ShadcnGap(ShadcnSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppPickerField(
                        label: 'Check in',
                        icon: Icons.schedule_rounded,
                        value: _checkInTime?.format(context),
                        placeholder: 'Optional',
                        onTap: _pickCheckInTime,
                      ),
                    ),
                    const ShadcnGap(ShadcnSpacing.md),
                    Expanded(
                      child: AppPickerField(
                        label: 'Check out',
                        icon: Icons.schedule_rounded,
                        value: _checkOutTime?.format(context),
                        placeholder: 'Optional',
                        onTap: _pickCheckOutTime,
                      ),
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                AppTrainerSelect(
                  trainers: trainers,
                  value: _trainerId,
                  onChanged: (value) => setState(() => _trainerId = value),
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                _SectionLabel('Payment'),
                const ShadcnGap(ShadcnSpacing.md),
                AppSelect<String>(
                  label: 'Payment mode',
                  placeholder: 'How did they pay?',
                  value: _selectedPaymentMethod,
                  items: [
                    for (final method in _paymentMethods)
                      ShadcnSelectItem(value: method, label: method),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedPaymentMethod = value),
                  validator:
                      ShadcnValidators.required('Please select a payment mode'),
                ),
                if (_selectedPaymentMethod == 'Online') ...[
                  const ShadcnGap(ShadcnSpacing.lg),
                  _UpiQr(user: userModel, amount: _selectedPlanFee),
                ],
              ],
            ),
          ),
        ),
        if (_isLoading) const AppSavingOverlay(message: 'Saving member…'),
      ],
    );
  }

  String _planLabel(GymPlanModel plan) {
    final parts = <String>[
      if (plan.months != 0)
        '${plan.months} month${plan.months == 1 ? '' : 's'}',
      if (plan.days != 0) '${plan.days} day${plan.days == 1 ? '' : 's'}',
    ];
    return parts.isEmpty ? plan.name : '${plan.name} · ${parts.join(' ')}';
  }

  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (!mounted || pickedFile == null) return;
    setState(() => _photo = pickedFile);
  }

  void _pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      setState(() => _dateOfBirth = pickedDate);
    }
  }

  void _pickDateOfAdmission() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfAdmission ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      setState(() => _dateOfAdmission = pickedDate);
    }
  }

  void _pickCheckInTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _checkInTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      setState(() => _checkInTime = pickedTime);
    }
  }

  void _pickCheckOutTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _checkOutTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      setState(() => _checkOutTime = pickedTime);
    }
  }

  void _saveForm() async {
    final plans =
        Provider.of<GymPlanProvider>(context, listen: false).sellablePlans;

    // The photo and the two dates sit outside the Form, so they are checked
    // here. Picking an admission date used to be assumed, and skipping it
    // threw a null error instead of pointing at the field.
    setState(() => _showNonFieldErrors = true);
    final fieldsValid = _formKey.currentState!.validate();
    final extrasValid =
        _photo != null && _dateOfBirth != null && _dateOfAdmission != null;
    if (!fieldsValid || !extrasValid) return;

    setState(() => _isLoading = true);

    final selectedPlan = GymPlanModel.findById(plans, _planId!);
    if (selectedPlan == null) {
      setState(() => _isLoading = false);
      showErrorToast(
        context,
        'Plan not found',
        description: 'That plan may have been deleted. Pick another one.',
      );
      return;
    }

    // Shares the renewal helper so a member joining on the 29th, 30th or
    // 31st gets the same expiry date here as they would on renewal.
    final expiryDate =
        MemberModel.addMonths(_dateOfAdmission!, selectedPlan.months)
            .add(Duration(days: selectedPlan.days));

    final newMember = MemberModel(
      id: '',
      name: _nameController.text,
      mobileNumber: _mobileNumberController.text,
      dateOfBirth: _dateOfBirth!,
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      photoUrl: '',
      // This will be updated in provider
      planId: _planId!,
      dateOfAdmission: _dateOfAdmission!,
      renewalDate: expiryDate,
      expiryDate: expiryDate,
      address: _addressController.text,
      gender: gender ?? 'Male',
      checkInTime: MemberModel.timeOfDayToString(context, _checkInTime),
      checkOutTime: MemberModel.timeOfDayToString(context, _checkOutTime),
      trainerId: _trainerId,
    );

    MemberModel? savedMember;
    try {
      // The saved copy is used from here on: it carries the id Firestore
      // handed out, which the invoice record needs to point at this member.
      savedMember = await Provider.of<MemberProvider>(context, listen: false)
          .addMember(newMember, _photo!);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorDialog(
        context: context,
        title: 'Could not save member',
        desc: 'Check your connection and try again.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    await showSuccessDialog(
      context: context,
      title: 'Member added',
      desc: '${newMember.name} is now on your books. '
          'Their invoice is next.',
    );

    // Guards against the owner leaving while the dialog was open.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ViewInvoicePage(
          member: savedMember ?? newMember,
          paymentMethod: _selectedPaymentMethod!,
          amountPaid: _selectedPlanFee,
          transactionType: 'New Membership',
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShadcnText(text, variant: ShadcnTextVariant.h4);
  }
}

/// The amount due for the chosen plan.
class _FeeSummary extends StatelessWidget {
  const _FeeSummary({required this.fee});

  final double fee;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final status = context.status;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ShadcnSpacing.lg,
        vertical: ShadcnSpacing.md,
      ),
      decoration: BoxDecoration(
        color: status.infoSurface,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_rounded, size: 18, color: status.info),
          const ShadcnGap(ShadcnSpacing.sm),
          Text(
            'Fee to collect',
            style: TextStyle(fontSize: 13.5, color: status.infoForeground),
          ),
          const Spacer(),
          Text(
            '₹${fee.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: status.infoForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// UPI QR code for taking payment on the spot.
class _UpiQr extends StatelessWidget {
  const _UpiQr({required this.user, required this.amount});

  final UserModel? user;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    // Without a UPI id the QR would encode an unpayable link, so say what's
    // missing instead of showing a code that silently fails at the counter.
    if (user == null || user!.upiId.trim().isEmpty) {
      return ShadcnCard(
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: t.mutedForeground),
            const ShadcnGap(ShadcnSpacing.md),
            Expanded(
              child: ShadcnText(
                'Add your UPI ID in Profile to show a payment QR code here.',
                variant: ShadcnTextVariant.small,
              ),
            ),
          ],
        ),
      );
    }

    return ShadcnCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ShadcnSpacing.md),
            decoration: BoxDecoration(
              // The QR itself is always dark-on-white: inverting it in dark
              // mode would stop most scanners reading it.
              color: Colors.white,
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: QrImageView(
              data:
                  'upi://pay?pa=${user!.upiId}&pn=${user!.merchantName}&mc=0000&cu=INR&am=$amount',
              size: 220,
            ),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          ShadcnText(
            'Scan to pay ₹${amount.toStringAsFixed(0)}',
            variant: ShadcnTextVariant.small,
          ),
        ],
      ),
    );
  }
}
