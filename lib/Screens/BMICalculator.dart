import 'package:fitstrong_gym/src/custom_import.dart';

/// Works out a member's body mass index from their height and weight.
class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightCmController = TextEditingController();
  final TextEditingController heightFeetController = TextEditingController();
  final TextEditingController heightInchesController = TextEditingController();

  double? bmi;
  String category = '';
  String heightUnit = 'cm';

  /// Set when the inputs don't add up to a result, so the screen can say why
  /// nothing happened. Tapping Calculate with an empty field used to do
  /// nothing at all, with no explanation.
  String? _inputError;

  @override
  void dispose() {
    weightController.dispose();
    heightCmController.dispose();
    heightFeetController.dispose();
    heightInchesController.dispose();
    super.dispose();
  }

  void calculateBMI() {
    double? weight = double.tryParse(weightController.text);
    double? heightM;

    if (heightUnit == 'cm') {
      double? heightCm = double.tryParse(heightCmController.text);
      if (heightCm != null && heightCm > 0) {
        heightM = heightCm / 100;
      }
    } else {
      double? feet = double.tryParse(heightFeetController.text);
      // Inches are optional: 5 feet flat is a perfectly normal entry, and
      // leaving the box empty used to block the calculation entirely.
      double inches = double.tryParse(heightInchesController.text) ?? 0;
      if (feet != null && feet > 0) {
        heightM = ((feet * 12) + inches) * 0.0254;
      }
    }

    if (weight == null || weight <= 0) {
      setState(() => _inputError = 'Enter a weight in kilograms.');
      return;
    }
    if (heightM == null || heightM <= 0) {
      setState(() => _inputError = 'Enter a height greater than zero.');
      return;
    }

    final metres = heightM;
    setState(() {
      _inputError = null;
      bmi = weight / (metres * metres);
      category = getBMICategory(bmi!);
    });
  }

  /// BMI bands, in the app's semantic colors so they stay readable in dark
  /// mode — the old yellow band was almost invisible on white.
  Color getBMIColor(BuildContext context, double bmi) {
    final status = context.status;
    if (bmi < 18.5) return status.info;
    if (bmi < 24.9) return status.success;
    if (bmi < 29.9) return status.warning;
    return status.danger;
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 24.9) {
      return 'Normal weight';
    } else if (bmi < 29.9) {
      return 'Overweight';
    } else if (bmi < 34.9) {
      return 'Obese';
    } else {
      return 'Extremely Obese';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    return AppScaffold(
      title: 'BMI calculator',
      bottomBar: ShadcnButton(
        fullWidth: true,
        size: ShadcnButtonSize.lg,
        leading: const Icon(Icons.calculate_rounded, size: 18),
        onPressed: calculateBMI,
        child: const Text('Calculate BMI'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShadcnSpacing.lg,
          ShadcnSpacing.xl,
          ShadcnSpacing.lg,
          ShadcnSpacing.xl2,
        ),
        children: [
          ShadcnInput(
            controller: weightController,
            label: 'Weight',
            placeholder: '72',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            trailing: Text(
              'kg',
              style: TextStyle(fontSize: 13, color: t.mutedForeground),
            ),
          ),
          const ShadcnGap(ShadcnSpacing.lg),
          ShadcnSelect<String>(
            label: 'Height unit',
            value: heightUnit,
            items: const [
              ShadcnSelectItem(value: 'cm', label: 'Centimetres'),
              ShadcnSelectItem(value: 'ft', label: 'Feet & inches'),
            ],
            onChanged: (value) => setState(() => heightUnit = value),
          ),
          const ShadcnGap(ShadcnSpacing.lg),
          if (heightUnit == 'cm')
            ShadcnInput(
              controller: heightCmController,
              label: 'Height',
              placeholder: '175',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              trailing: Text(
                'cm',
                style: TextStyle(fontSize: 13, color: t.mutedForeground),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShadcnInput(
                    controller: heightFeetController,
                    label: 'Feet',
                    placeholder: '5',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.md),
                Expanded(
                  child: ShadcnInput(
                    controller: heightInchesController,
                    label: 'Inches',
                    placeholder: '9',
                    keyboardType: TextInputType.number,
                    helperText: 'Optional',
                  ),
                ),
              ],
            ),
          if (_inputError != null) ...[
            const ShadcnGap(ShadcnSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: t.destructive,
                ),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: Text(
                    _inputError!,
                    style: TextStyle(fontSize: 13, color: t.destructive),
                  ),
                ),
              ],
            ),
          ],
          if (bmi != null) ...[
            const ShadcnGap(ShadcnSpacing.xl2),
            _BmiResult(
              bmi: bmi!,
              category: category,
              color: getBMIColor(context, bmi!),
            ),
            const ShadcnGap(ShadcnSpacing.lg),
            const _BmiScale(),
          ],
        ],
      ),
    );
  }
}

class _BmiResult extends StatelessWidget {
  const _BmiResult({
    required this.bmi,
    required this.category,
    required this.color,
  });

  final double bmi;
  final String category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Container(
      padding: const EdgeInsets.all(ShadcnSpacing.xl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(t.radiusXl),
      ),
      child: Column(
        children: [
          Text(
            'YOUR BMI',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: t.mutedForeground,
            ),
          ),
          const ShadcnGap(ShadcnSpacing.sm),
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 44,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: t.foreground,
            ),
          ),
          const ShadcnGap(ShadcnSpacing.sm),
          ShadcnBadge(
            style: ShadcnBadgeStyle(
              backgroundColor: color,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(category),
          ),
        ],
      ),
    );
  }
}

/// The reference bands, so a number on its own means something.
class _BmiScale extends StatelessWidget {
  const _BmiScale();

  @override
  Widget build(BuildContext context) {
    final status = context.status;
    final rows = [
      ('Underweight', 'Below 18.5', status.info),
      ('Normal weight', '18.5 – 24.9', status.success),
      ('Overweight', '25.0 – 29.9', status.warning),
      ('Obese', '30.0 and above', status.danger),
    ];

    return ShadcnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadcnText('Reference', variant: ShadcnTextVariant.h4),
          const ShadcnGap(ShadcnSpacing.md),
          for (final (label, range, color) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: ShadcnSpacing.sm),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const ShadcnGap(ShadcnSpacing.sm),
                  Expanded(
                    child: ShadcnText(label, variant: ShadcnTextVariant.small),
                  ),
                  ShadcnText(range, variant: ShadcnTextVariant.muted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
