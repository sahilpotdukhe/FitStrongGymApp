import 'package:fitstrong_gym/Widgets/CachedImage.dart';
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class RenewMembershipPage extends StatefulWidget {
  final MemberModel member;

  const RenewMembershipPage({required this.member});

  @override
  _RenewMembershipPageState createState() => _RenewMembershipPageState();
}

class _RenewMembershipPageState extends State<RenewMembershipPage> {
  late TextEditingController _renewalDateController;
  late TextEditingController _cashAmountController;
  GymPlanModel? _selectedPlan;
  String? _planId;

  double _selectedPlanFee = 0.0;

  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Cash', 'Online'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _renewalDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(widget.member.renewalDate));
    _cashAmountController = TextEditingController();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    final plans = Provider.of<GymPlanProvider>(context).plans;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.getUser;
    ScaleUtils.init(context);
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: UniversalVariables.appThemeColor,
          title: Text(
            'Renew Membership',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Name: ${widget.member.name}',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Renewal Date',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              TextFormField(
                controller: _renewalDateController,
                decoration: InputDecoration(
                  hintText: 'Renewal Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.date_range),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  try {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: widget.member.renewalDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _renewalDateController.text =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                      });
                    }
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "The plan is not expired yet so you can't renew the membership!"),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Plan',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Select Plan',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.card_membership,
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
                  ),
                ),
                value: _planId,
                onChanged: (value) {
                  setState(() {
                    _planId = value;
                    // Find the selected plan and set the fee
                    _selectedPlan = GymPlanModel.findById(plans, value!);
                    if (_selectedPlan != null) {
                      _selectedPlanFee = _selectedPlan!.fee;
                    }
                  });
                },
                items: plans
                    .map((plan) => DropdownMenuItem(
                          child: Text(plan.name),
                          value:
                              plan.id, // Using plan.id as the unique identifier
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
              Center(
                child: Text(
                  'Fees to be paid: \₹$_selectedPlanFee',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Payment Mode ',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  hintText: 'Select Payment Mode',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.credit_card,
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: HexColor('E5E7EB'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: HexColor('E5E7EB'), width: 2),
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
                    CachedImage(
                        imageUrl: userModel!.qrImageUrl,
                        isRound: false,
                        radius: 0,
                        height: 350,
                        width: 350,
                        fit: BoxFit.cover),
                    SizedBox(height: 10),
                    Text('Scan the QR code to pay online'),
                  ],
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _renewMembership,
                  child: Text(
                    'Renew Membership',
                    style: TextStyle(color: Colors.white),
                  ),
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
    ]);
  }

  Future<void> _renewMembership() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a plan')),
      );
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newDateOfRenewal =
          DateFormat('dd-MM-yyyy').parse(_renewalDateController.text);
      final renewedMember =
          widget.member.renewMembership(_selectedPlan!, newDateOfRenewal);
      await Provider.of<MemberProvider>(context, listen: false)
          .updateMember(renewedMember);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Membership renewed successfully')),
      );
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.success,
        showCloseIcon: true,
        //autoHide: Duration(seconds: 6),
        title: 'Renewed!',
        desc:
            'You have successfully Renewed Membership.\n Please wait you will be redirected to the MembersList Screen.',
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
                    member: renewedMember,
                  )));
    } catch (error) {
      print('Error renewing membership: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to renew membership')),
      );
    }
  }
}
