import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class AddMemberPage extends StatefulWidget {
  @override
  _AddMemberPageState createState() => _AddMemberPageState();
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
  final List<String> _paymentMethods = ['Cash', 'Online'];

  XFile? _photo;
  String? _gender;
  String? _planId;
  double _selectedPlanFee = 0.0;
  DateTime? _dateOfBirth;
  DateTime? _dateOfAdmission;
  bool _isLoading = false;
  String? displayName;
  String? gender = 'Male';
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;

  // XFile? _image;
  String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    final plans = Provider.of<GymPlanProvider>(context).plans;
    ScaleUtils.init(context);
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: Text(
            'Add Member',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: UniversalVariables.appThemeColor,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/home');
            },
            icon: Icon(Icons.arrow_back_outlined),
          ),
          actions: [
            IconButton(onPressed: () async{
              CollectionReference users = FirebaseFirestore.instance.collection('Users');

              // Fetch all users
              QuerySnapshot usersSnapshot = await users.get();

              // Iterate through each user
              for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
                // Reference to the user's members subcollection
                CollectionReference gymplans = users.doc(userDoc.id).collection('gymPlans');

                // Fetch all documents from the user's members subcollection
                QuerySnapshot membersSnapshot = await gymplans.get();

                // Iterate through each document in the members subcollection and update it
                for (QueryDocumentSnapshot memberDoc in membersSnapshot.docs) {
                  await gymplans.doc(memberDoc.id).update({
                    'days': 0
                  }).catchError((error) {
                    print("Failed to update document ${memberDoc.id} for user ${userDoc.id}: $error");
                  });
                }
              }
            }, icon: Icon(Icons.notifications))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _modalBottomSheetMenu(context);
                        },
                        child: Center(
                          child: CircleAvatar(
                            backgroundColor: UniversalVariables.appThemeColor,
                            radius: 52 * ScaleUtils.scaleFactor,
                            child: CircleAvatar(
                              radius: 50 * ScaleUtils.scaleFactor,
                              backgroundColor: Colors.transparent,
                              backgroundImage: _displayChild(),
                              //foregroundImage: NetworkImage(userModel!.profilePhoto),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 70 * ScaleUtils.verticalScale,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: 5 * ScaleUtils.horizontalScale,
                                  top: 12 * ScaleUtils.verticalScale),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: HexColor("3957ED"),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    8.0 * ScaleUtils.scaleFactor),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 26 * ScaleUtils.scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Name',
                      labelText: 'Name',
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
                      suffixIcon: Icon(Icons.person, color: HexColor('3957ED')),
                    ),
                    onSaved: (value) {
                      displayName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _mobileNumberController,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Phone number',
                      labelText: 'Phone number',
                      counterText: "",
                      labelStyle:
                          TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                      floatingLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18 * ScaleUtils.scaleFactor,
                          color: HexColor('3957ED')),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.phone_android_outlined,
                          color: HexColor('3957ED')),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: HexColor('3957ED'), width: 2)),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        phoneNumber = value;
                      });
                    },
                    onSaved: (value) {
                      phoneNumber = value;
                    },
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Phone No';
                      } else if (value.length < 10) {
                        return 'Enter 10 digit Phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: _pickDateOfBirth,
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _dateOfBirth != null
                              ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                              : null,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Select Date of Birth',
                          labelText: 'Date of Birth',
                          labelStyle: TextStyle(
                              fontSize: 16.0 * ScaleUtils.scaleFactor),
                          floatingLabelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18 * ScaleUtils.scaleFactor,
                              color: HexColor('3957ED')),
                          border: OutlineInputBorder(),
                          suffixIcon:
                              Icon(Icons.date_range, color: HexColor('3957ED')),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: HexColor('3957ED'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: HexColor('3957ED'), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (_dateOfBirth == null) {
                            return 'Please select a date of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Height',
                      labelText: 'Height (cm)',
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
                      suffixIcon: Icon(Icons.height, color: HexColor('3957ED')),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a height';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Weight',
                      labelText: 'Weight (kg)',
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
                          Icon(Icons.monitor_weight, color: HexColor('3957ED')),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a weight';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Address',
                      labelText: 'Address',
                      labelStyle:
                          TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                      floatingLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18 * ScaleUtils.scaleFactor,
                          color: HexColor('3957ED')),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.place, color: HexColor('3957ED')),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: HexColor('3957ED'), width: 2)),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: _pickDateOfAdmission,
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _dateOfAdmission != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(_dateOfAdmission!)
                              : null,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Select Date of Admission',
                          labelText: 'Date of Admission',
                          labelStyle: TextStyle(
                              fontSize: 16.0 * ScaleUtils.scaleFactor),
                          floatingLabelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18 * ScaleUtils.scaleFactor,
                              color: HexColor('3957ED')),
                          border: OutlineInputBorder(),
                          suffixIcon:
                              Icon(Icons.date_range, color: HexColor('3957ED')),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: HexColor('3957ED'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: HexColor('3957ED'), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (_dateOfAdmission == null) {
                            return 'Please select a date of admission';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Select Plan',
                      labelText: 'Plan',
                      labelStyle:
                          TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                      floatingLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18 * ScaleUtils.scaleFactor,
                          color: HexColor('3957ED')),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.card_membership,
                          color: HexColor('3957ED')),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: HexColor('3957ED'), width: 2)),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2),
                      ),
                    ),
                    value: _planId,
                    onChanged: (value) {
                      setState(() {
                        _planId = value;
                        // Find the selected plan and set the fee
                        final selectedPlan = GymPlanModel.findById(plans, value!);
                        if (selectedPlan != null) {
                          _selectedPlanFee = selectedPlan.fee;
                        }
                      });
                    },
                    items: plans
                        .map((plan) => DropdownMenuItem(
                              child: Text(plan.name),
                              value: plan
                                  .id, // Using plan.id as the unique identifier
                            ))
                        .toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a plan';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Fees to be paid: \₹$_selectedPlanFee',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: InputDecoration(
                      hintText: 'Select Payment Mode',
                      labelText: 'Payment Mode',
                      labelStyle:
                          TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                      floatingLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18 * ScaleUtils.scaleFactor,
                          color: HexColor('3957ED')),
                      border: OutlineInputBorder(),
                      suffixIcon:
                          Icon(Icons.credit_card, color: HexColor('3957ED')),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: HexColor('3957ED'), width: 2)),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select payment mode';
                      }
                      return null;
                    },
                    items: _paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (String? newMethod) {
                      setState(() {
                        _selectedPaymentMethod = newMethod;
                      });
                    },
                  ),
                  if (_selectedPaymentMethod == 'Online')
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Image.asset(
                          'assets/QRcode.jpg',
                          // Replace with your QR code image URL
                          height: 350,
                          width: 350,
                        ),
                        SizedBox(height: 10),
                        Text('Scan the QR code to pay online'),
                      ],
                    ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0 * ScaleUtils.verticalScale),
                        child: Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 16.0 * ScaleUtils.scaleFactor,
                            color: HexColor('3957ED'),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Radio<String>(
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value!;
                          });
                        },
                      ),
                      const Text('Male'),
                      Radio<String>(
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value!;
                          });
                        },
                      ),
                      const Text('Female'),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickCheckInTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _checkInTime != null
                              ? _checkInTime!.format(context)
                              : null,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Select Check-in Time',
                          labelText: 'Check-in Time',
                          labelStyle:
                          TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                          floatingLabelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18 * ScaleUtils.scaleFactor,
                              color: HexColor('3957ED')),
                          border: OutlineInputBorder(),
                          suffixIcon:
                          Icon(Icons.access_time, color: HexColor('3957ED')),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: HexColor('3957ED'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (_checkInTime == null) {
                            return 'Please select a check-in time';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickCheckOutTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _checkOutTime != null
                              ? _checkOutTime!.format(context)
                              : null,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Select Check-out Time',
                          labelText: 'Check-out Time',
                          labelStyle:
                          TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                          floatingLabelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18 * ScaleUtils.scaleFactor,
                              color: HexColor('3957ED')),
                          border: OutlineInputBorder(),
                          suffixIcon:
                          Icon(Icons.access_time, color: HexColor('3957ED')),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: HexColor('3957ED'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: HexColor('3957ED'), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (_checkOutTime == null) {
                            return 'Please select a check-out time';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _saveForm,
                    child: Text('Save Member',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
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
    ]);
  }

  void _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _photo = pickedFile;
    });
  }

  void _pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateOfBirth = pickedDate;
      });
    }
  }

  void _pickDateOfAdmission() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfAdmission ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateOfAdmission = pickedDate;
      });
    }
  }

  bool _isImageSelected() {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return false;
    }
    return true;
  }

  void _saveForm() async {
    final plans = Provider.of<GymPlanProvider>(context, listen: false).plans;

    if (_formKey.currentState!.validate() && _isImageSelected()) {
      setState(() {
        _isLoading = true;
      });

      // Find the selected plan to get the duration in months
      final selectedPlan = GymPlanModel.findById(plans, _planId!);
      if (selectedPlan == null) {
        // Handle error
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected plan not found')),
        );
        return;
      }

      final expiryDate = DateTime(
        _dateOfAdmission!.year,
        _dateOfAdmission!.month + selectedPlan.months,
        _dateOfAdmission!.day,
      ).add(Duration(days: selectedPlan.days));

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
        renewalDate: expiryDate!,
        expiryDate: expiryDate,
        // Set expiry date
        address: _addressController.text,
        gender: gender ?? 'Male',
        checkInTime: MemberModel.timeOfDayToString(context,_checkInTime),
        checkOutTime: MemberModel.timeOfDayToString(context,_checkOutTime)
      );

      await Provider.of<MemberProvider>(context, listen: false)
          .addMember(newMember, _photo!);
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.success,
        showCloseIcon: true,
        //autoHide: Duration(seconds: 6),
        title: 'Added!',
        desc:
            'You have successfully added a member.\n Please wait you will be redirected to the HomePage.',
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewInvoicePage(
                    member: newMember,
                  )));
    }
  }

  _displayChild() {
    if (_photo == null) {
      return AssetImage('assets/user.jpg');
    } else {
      final File _imagex = File(_photo!.path);
      return FileImage(_imagex);
    }
  }

  void _pickCheckInTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _checkInTime = pickedTime;
      });
    }
  }

  void _pickCheckOutTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _checkOutTime = pickedTime;
      });
    }
  }


  void _modalBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
              height: 150.0,
              color: Colors.transparent,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          _pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white60,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: UniversalVariables.appThemeColor,
                                  ),
                                  Text('Camera')
                                ],
                              ),
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white60,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.photo,
                                    size: 50,
                                    color: UniversalVariables.appThemeColor,
                                  ),
                                  Text('Gallery')
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }
}
