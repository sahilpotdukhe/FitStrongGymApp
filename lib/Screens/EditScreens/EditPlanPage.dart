import 'package:fitstrong_gym/src/custom_import.dart';

class EditPlanPage extends StatefulWidget {
  final GymPlanModel plan;

  EditPlanPage({required this.plan});

  @override
  _EditPlanPageState createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _months;
  late int _days;
  late double _fee;

  @override
  void initState() {
    super.initState();
    _name = widget.plan.name;
    _months = widget.plan.months;
    _days = widget.plan.days;
    _fee = widget.plan.fee;
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: UniversalVariables.appThemeColor,
        title: Text(
          'Edit Plan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Plan name',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  hintText: 'Update Plan Name',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                  suffixIcon: Icon(Icons.drive_file_rename_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the plan name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Months',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              TextFormField(
                initialValue: _months.toString(),
                decoration: InputDecoration(
                  hintText: 'Update Months',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                  suffixIcon: Icon(Icons.calendar_month_sharp),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  return null;
                },
                onSaved: (value) => _months = int.parse(value!),
              ),
              SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Days',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              TextFormField(
                initialValue: _days.toString(), // New TextFormField for days
                decoration: InputDecoration(
                  hintText: 'Update Days',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration in days';
                  }
                  return null;
                },
                onSaved: (value) => _days = int.parse(value!),
              ),
              SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Fees',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              TextFormField(
                initialValue: _fee.toString(),
                decoration: InputDecoration(
                  hintText: 'Update Fee',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                  suffixIcon: Icon(
                    Icons.money,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the fee';
                  }
                  return null;
                },
                onSaved: (value) => _fee = double.parse(value!),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Provider.of<GymPlanProvider>(context, listen: false)
                          .updatePlan(
                              widget.plan.id, _name, _months, _days, _fee);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Update Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
