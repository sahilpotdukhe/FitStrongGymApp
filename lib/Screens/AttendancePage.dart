import 'package:fitstrong_gym/Widgets/AttendanceQuietPage.dart';
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  void initState() {
    super.initState();
    // Fetch attendance dates when the page is initialized
    final attendanceProvider =
    Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.fetchAttendanceDates().then((_) {
      setState(() {}); // Rebuild the widget after fetching dates
    });
  }

  Map<String, List<String>> _groupDatesByMonth(List<String> dates) {
    Map<String, List<String>> groupedDates = {};
    for (String date in dates) {
      DateTime dateTime = DateFormat('d MMMM, yyyy').parse(date);
      String month = DateFormat('MMMM yyyy').format(dateTime);

      if (groupedDates[month] == null) {
        groupedDates[month] = [];
      }
      groupedDates[month]!.add(date);
    }
    return groupedDates;
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final attendanceDates = attendanceProvider.attendanceDates;

    Map<String, List<String>> groupedDates = _groupDatesByMonth(attendanceDates);
    List<String> months = groupedDates.keys.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        title: Text('Attendance',style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: UniversalVariables.bgColor,
      body: attendanceDates.isEmpty
          ? AttendanceQuietBox()
          : ListView.builder(
        itemCount: months.length,
        itemBuilder: (context, index) {
          String month = months[index];
          List<String> datesInMonth = groupedDates[month]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  month,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              ...datesInMonth.map((date) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceDetailPage(date: date),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Text(
                            date,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ],
          );
        },
      ),
    );
  }
}
