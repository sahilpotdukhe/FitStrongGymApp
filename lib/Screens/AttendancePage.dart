

import 'package:fitstrong_gym/src/custom_import.dart';

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

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final attendanceDates = attendanceProvider.attendanceDates;

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
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: attendanceDates.length,
              itemBuilder: (context, index) {
                String date = attendanceDates[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceDetailPage(date: date),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                            style: TextStyle(fontSize: 16,color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_rounded,color: Colors.white)
                        ],
                      ),
                    )),
                  ),
                );
                //   ListTile(
                //   title: Text(date),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => AttendanceDetailPage(date: date),
                //       ),
                //     );
                //   },
                // );
              },
            ),
    );
  }
}
