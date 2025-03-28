import 'package:fitstrong_gym/src/custom_import.dart';

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightCmController = TextEditingController();
  final TextEditingController heightFeetController = TextEditingController();
  final TextEditingController heightInchesController = TextEditingController();

  double? bmi;
  String category = '';
  String heightUnit = 'cm';
  late Color bmiColor;

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
      double? inches = double.tryParse(heightInchesController.text);
      if (feet != null && inches != null) {
        heightM = ((feet * 12) + inches) * 0.0254;
      }
    }

    if (weight != null && heightM != null && heightM > 0) {
      setState(() {
        bmi = weight / (heightM! * heightM);
        category = getBMICategory(bmi!);
        bmiColor = getBMIColor(bmi!);
      });
    }
  }

  Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 24.9) {
      return Colors.green;
    } else if (bmi < 29.9) {
      return Colors.yellow;
    } else if (bmi < 34.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        title: Text('BMI Calculator', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Weight(in kg)',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(
                  hintText: 'Enter Weight(in kg)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                  suffixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Weight';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Choose height unit',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              DropdownButtonFormField<String>(
                value: heightUnit,
                onChanged: (value) {
                  setState(() {
                    heightUnit = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'cm', child: Text('Centimeters')),
                  DropdownMenuItem(value: 'ft', child: Text('Feet & Inches')),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter Weight(in kg)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Height',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              if (heightUnit == 'cm')
                TextField(
                  controller: heightCmController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter height(in cm)',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: HexColor('E5E7EB'), width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2),
                    ),
                    suffixIcon: Icon(Icons.height),
                  ),
                ),
              if (heightUnit == 'ft')
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: heightFeetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter feet',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: HexColor('E5E7EB'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: HexColor('E5E7EB'), width: 2),
                          ),
                          suffixIcon: Icon(Icons.height),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: heightInchesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter Inches',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: HexColor('E5E7EB'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: HexColor('E5E7EB'), width: 2),
                          ),
                          suffixIcon: Icon(Icons.height),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Calculate BMI',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
              if (bmi != null)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: bmiColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your BMI:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          bmi!.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          category,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/BMI.jpg',
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
