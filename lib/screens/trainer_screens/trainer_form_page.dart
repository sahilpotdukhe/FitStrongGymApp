import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

/// Add a trainer, or edit one. One form for both, because the fields are
/// identical and keeping two copies in step never lasts.
class TrainerFormPage extends StatefulWidget {
  const TrainerFormPage({super.key, this.trainer});

  /// null means "adding a new trainer".
  final TrainerModel? trainer;

  bool get isEditing => trainer != null;

  @override
  State<TrainerFormPage> createState() => _TrainerFormPageState();
}

class _TrainerFormPageState extends State<TrainerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _experienceController;
  late final TextEditingController _salaryController;
  late final TextEditingController _addressController;

  XFile? _photo;
  late String _gender;
  late String _specialization;
  late DateTime _joiningDate;
  TimeOfDay? _shiftStart;
  TimeOfDay? _shiftEnd;
  late Set<String> _workingDays;
  late bool _isActive;

  bool _saving = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    final trainer = widget.trainer;
    _nameController = TextEditingController(text: trainer?.name ?? '');
    _mobileController =
        TextEditingController(text: trainer?.mobileNumber ?? '');
    _experienceController = TextEditingController(
      text: trainer == null ? '' : trainer.experienceYears.toString(),
    );
    _salaryController = TextEditingController(
      text: trainer == null || trainer.salary == 0
          ? ''
          : trainer.salary.toStringAsFixed(0),
    );
    _addressController = TextEditingController(text: trainer?.address ?? '');

    _gender = trainer?.gender.isNotEmpty == true ? trainer!.gender : 'Male';
    _specialization = trainer?.specialization.isNotEmpty == true
        ? trainer!.specialization
        : TrainerModel.specializations.first;
    _joiningDate = trainer?.joiningDate ?? DateTime.now();
    _shiftStart = ClockTime.parse(trainer?.shiftStart);
    _shiftEnd = ClockTime.parse(trainer?.shiftEnd);
    _workingDays = {
      ...?trainer?.workingDays,
    };
    if (_workingDays.isEmpty) {
      // A six day week is what most gyms run, so it is the starting point
      // rather than an empty set the owner has to fill in from scratch.
      _workingDays =
          TrainerModel.allWorkingDays.where((day) => day != 'Sun').toSet();
    }
    _isActive = trainer?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _experienceController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    return Stack(
      children: [
        AppScaffold(
          title: widget.isEditing ? 'Edit trainer' : 'Add trainer',
          bottomBar: ShadcnButton(
            fullWidth: true,
            size: ShadcnButtonSize.lg,
            loading: _saving,
            leading: const Icon(Icons.check_rounded, size: 18),
            onPressed: _save,
            child: Text(widget.isEditing ? 'Save changes' : 'Add trainer'),
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
                    imageUrl: widget.trainer?.photoUrl,
                    onPicked: _pickImage,
                    errorText: _showErrors && !_hasPhoto
                        ? 'A photo is required'
                        : null,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Center(
                  child: ShadcnText(
                    // Members are photographed, and so are trainers: the
                    // picture is how anyone on the floor is recognised.
                    'Tap to add a photo',
                    variant: ShadcnTextVariant.small,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                ShadcnText('Details', variant: ShadcnTextVariant.h4),
                const ShadcnGap(ShadcnSpacing.md),
                ShadcnInput(
                  controller: _nameController,
                  label: 'Full name',
                  placeholder: 'Trainer name',
                  textCapitalization: TextCapitalization.words,
                  leading: const Icon(Icons.person_outline_rounded, size: 18),
                  validator: ShadcnValidators.required('Please enter a name'),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _mobileController,
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
                AppSelect<String>(
                  label: 'Specialises in',
                  value: _specialization,
                  items: [
                    for (final item in TrainerModel.specializations)
                      ShadcnSelectItem(value: item, label: item),
                  ],
                  onChanged: (value) => setState(() => _specialization = value),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ShadcnInput(
                        controller: _experienceController,
                        label: 'Experience (years)',
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
                        controller: _salaryController,
                        label: 'Monthly pay',
                        placeholder: 'Optional',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        leading: const Text('₹'),
                      ),
                    ),
                  ],
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
                  value: _gender,
                  onChanged: (value) => setState(() => _gender = value),
                  direction: Axis.horizontal,
                  options: const [
                    ShadcnRadioOption(value: 'Male', label: 'Male'),
                    ShadcnRadioOption(value: 'Female', label: 'Female'),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _addressController,
                  label: 'Address',
                  placeholder: 'Where the trainer lives',
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                ShadcnText('Schedule', variant: ShadcnTextVariant.h4),
                const ShadcnGap(ShadcnSpacing.md),
                AppPickerField(
                  label: 'Joined on',
                  value: DateFormat('d MMM yyyy').format(_joiningDate),
                  onTap: _pickJoiningDate,
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppPickerField(
                        label: 'Shift starts',
                        icon: Icons.schedule_rounded,
                        value: _shiftStart?.format(context),
                        placeholder: 'Select time',
                        onTap: () => _pickShiftTime(isStart: true),
                        errorText: _showErrors && _shiftStart == null
                            ? 'Pick a start time'
                            : null,
                      ),
                    ),
                    const ShadcnGap(ShadcnSpacing.md),
                    Expanded(
                      child: AppPickerField(
                        label: 'Shift ends',
                        icon: Icons.schedule_rounded,
                        value: _shiftEnd?.format(context),
                        placeholder: 'Select time',
                        onTap: () => _pickShiftTime(isStart: false),
                        errorText: _showErrors && _shiftEnd == null
                            ? 'Pick an end time'
                            : null,
                      ),
                    ),
                  ],
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                Text(
                  'Working days',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: t.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                _DayPicker(
                  selected: _workingDays,
                  onToggle: (day) => setState(() {
                    if (!_workingDays.remove(day)) _workingDays.add(day);
                  }),
                ),
                if (_showErrors && _workingDays.isEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Pick at least one working day',
                    style: TextStyle(fontSize: 12.5, color: t.destructive),
                  ),
                ],
                if (widget.isEditing) ...[
                  const ShadcnGap(ShadcnSpacing.xl2),
                  ShadcnCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShadcnText(
                                'Still working here',
                                variant: ShadcnTextVariant.h4,
                              ),
                              const SizedBox(height: 2),
                              ShadcnText(
                                'Turn this off when a trainer leaves. Their '
                                'members keep the record of who coached them.',
                                variant: ShadcnTextVariant.small,
                              ),
                            ],
                          ),
                        ),
                        const ShadcnGap(ShadcnSpacing.md),
                        ShadcnSwitch(
                          value: _isActive,
                          onChanged: (value) =>
                              setState(() => _isActive = value),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_saving)
          AppSavingOverlay(
            message: widget.isEditing ? 'Saving changes…' : 'Adding trainer…',
          ),
      ],
    );
  }

  /// True when there is a photo to save: either one picked just now, or
  /// the one already on an existing trainer's record.
  bool get _hasPhoto =>
      _photo != null || (widget.trainer?.photoUrl.trim().isNotEmpty ?? false);

  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (!mounted || pickedFile == null) return;
    setState(() => _photo = pickedFile);
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _joiningDate = picked);
  }

  Future<void> _pickShiftTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _shiftStart : _shiftEnd) ??
          TimeOfDay(hour: isStart ? 6 : 11, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _shiftStart = picked;
      } else {
        _shiftEnd = picked;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _showErrors = true);
    final fieldsValid = _formKey.currentState!.validate();
    // Shift times and working days live outside the Form, so they are
    // checked by hand.
    if (!fieldsValid ||
        !_hasPhoto ||
        _shiftStart == null ||
        _shiftEnd == null ||
        _workingDays.isEmpty) {
      return;
    }

    setState(() => _saving = true);

    final trainer = TrainerModel(
      id: widget.trainer?.id ?? '',
      name: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      gender: _gender,
      specialization: _specialization,
      experienceYears: int.tryParse(_experienceController.text) ?? 0,
      photoUrl: widget.trainer?.photoUrl ?? '',
      joiningDate: _joiningDate,
      shiftStart: ClockTime.toStorage(_shiftStart),
      shiftEnd: ClockTime.toStorage(_shiftEnd),
      workingDays:
          TrainerModel.allWorkingDays.where(_workingDays.contains).toList(),
      salary: double.tryParse(_salaryController.text.trim()) ?? 0,
      address: _addressController.text.trim(),
      isActive: _isActive,
    );

    final provider = Provider.of<TrainerProvider>(context, listen: false);
    try {
      if (widget.isEditing) {
        await provider.updateTrainer(trainer, photo: _photo);
      } else {
        await provider.addTrainer(trainer, photo: _photo);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorDialog(
        context: context,
        title: 'Could not save trainer',
        desc: 'Check your connection and try again.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);
    showSuccessToast(
      context,
      widget.isEditing ? 'Trainer updated' : 'Trainer added',
      description: trainer.name,
    );
    Navigator.pop(context);
  }
}

/// Seven tappable day chips. Quicker than a list of switches, and the whole
/// week is visible at a glance.
class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Wrap(
      spacing: ShadcnSpacing.sm,
      runSpacing: ShadcnSpacing.sm,
      children: [
        for (final day in TrainerModel.allWorkingDays)
          GestureDetector(
            onTap: () => onToggle(day),
            child: Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected.contains(day) ? t.primary : t.muted,
                borderRadius: BorderRadius.circular(t.radiusMd),
                border: Border.all(
                  color: selected.contains(day) ? t.primary : t.border,
                ),
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected.contains(day)
                      ? t.primaryForeground
                      : t.mutedForeground,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
