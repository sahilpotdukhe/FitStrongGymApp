import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:uuid/uuid.dart';

class ViewInvoicePage extends StatefulWidget {
  final MemberModel member;
  const ViewInvoicePage({super.key, required this.member});

  @override
  State<ViewInvoicePage> createState() => _ViewInvoicePageState();
}

class _ViewInvoicePageState extends State<ViewInvoicePage> {
  var uuid = Uuid();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    final plans = Provider.of<GymPlanProvider>(context, listen: false).plans;
    final plan = GymPlanModel.findById(plans, widget.member.planId);
    final planName = plan?.name ?? 'Unknown Plan';
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: UniversalVariables.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final date = DateTime.now();
                final dueDate = DateTime.now();
                final invoice = Invoice(
                    owner: Owner(
                        name: userModel!.name,
                        address: userModel.address,
                        mobileNumber: userModel.phoneNumber),
                    customer: Customer(
                        name: widget.member.name,
                        address: widget.member.address,
                        mobileNumber: widget.member.mobileNumber,
                        dateOfAdmission: widget.member.dateOfAdmission,
                        expiryDate: widget.member.expiryDate,
                        gender: widget.member.gender),
                    info: InvoiceInfo(
                        todayDate: date,
                        invoiceDate: dueDate,
                        invoiceNumber: uuid.v4().substring(0, 15),
                        transactionType: 'Cash'),
                    items: [
                      InvoiceItem(
                          description: plan?.name ?? 'Unknown Plan',
                          fees: '${plan!.fee}',
                          days: '${plan.days}',
                          total: '${plan.fee}',
                          months: '${plan.months}'),
                    ]);
                final pdfFile =
                    await PdfInvoiceApi.generate(invoice, userModel);
                print('Opening file: ${pdfFile.path}');
                PdfApi.openFile(pdfFile);
              },
              child: Text('Generate Invoice'),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
              child: Text('Back to Homepage'),
            ),
          ],
        ),
      ),
    );
  }
}
