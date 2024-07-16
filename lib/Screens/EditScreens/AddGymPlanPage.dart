
import 'package:fitstrong_gym/src/custom_import.dart';

class AddGymPlanPage extends StatefulWidget {
  @override
  _AddGymPlanPageState createState() => _AddGymPlanPageState();
}

class _AddGymPlanPageState extends State<AddGymPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _monthsController = TextEditingController();
  final _daysController = TextEditingController(); // New controller for days

  final _feeController = TextEditingController();
  bool _personalTraining = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          'Add Gym Plan',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home');
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Plan Name',
                    labelText: 'Plan Name',
                    labelStyle:
                        TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                    floatingLabelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18 * ScaleUtils.scaleFactor,
                        color: HexColor('3957ED')),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor('3957ED'), width: 2),
                    ),
                    suffixIcon:
                        Icon(Icons.card_membership, color: HexColor('3957ED')),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter plan name';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _monthsController,
                  decoration: InputDecoration(
                    hintText: 'Enter Months',
                    labelText: 'Months',
                    labelStyle:
                        TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                    floatingLabelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18 * ScaleUtils.scaleFactor,
                        color: HexColor('3957ED')),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor('3957ED'), width: 2),
                    ),
                    suffixIcon: Icon(Icons.calendar_month_sharp,
                        color: HexColor('3957ED')),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null) {
                      return 'Please enter a valid number of months';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _daysController, // New TextFormField for days
                  decoration: InputDecoration(
                    hintText: 'Enter Days',
                    labelText: 'Days',
                    labelStyle:
                    TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                    floatingLabelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18 * ScaleUtils.scaleFactor,
                        color: HexColor('3957ED')),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: HexColor('3957ED'), width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: HexColor('3957ED'), width: 2),
                    ),
                    suffixIcon: Icon(Icons.calendar_today,
                        color: HexColor('3957ED')),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null) {
                      return 'Please enter a valid number of days';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _feeController,
                  decoration: InputDecoration(
                    hintText: 'Enter Fees',
                    labelText: 'Fees',
                    labelStyle:
                        TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                    floatingLabelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18 * ScaleUtils.scaleFactor,
                        color: HexColor('3957ED')),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor('3957ED'), width: 2),
                    ),
                    suffixIcon:
                        Icon(Icons.attach_money, color: HexColor('3957ED')),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.tryParse(value) == null) {
                      return 'Please enter a valid fee';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                SwitchListTile(
                  title: Text('Personal Training'),
                  value: _personalTraining,
                  onChanged: (value) {
                    setState(() {
                      _personalTraining = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: UniversalVariables.appThemeColor),
                  child: Text(
                    'Add Plan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ]),
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final newPlan = GymPlanModel(
        id: '',
        // ID will be generated by Firestore
        name: _nameController.text,
        months: int.parse(_monthsController.text),
        days: int.parse(_daysController.text),
        fee: double.parse(_feeController.text),
        personalTraining: _personalTraining,
      );

      await Provider.of<GymPlanProvider>(context, listen: false)
          .addPlan(newPlan);
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.success,
        showCloseIcon: true,
        //autoHide: Duration(seconds: 6),
        title: 'Added!',
        desc:
            'You have successfully added a Gym Plan.\n Please wait you will be redirected to the Gym Plans Screen.',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        },
      ).show();
      await Future.delayed(Duration(seconds: 4));
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
      Navigator.popAndPushNamed(context, 'gym-plans');
    }
  }
}
