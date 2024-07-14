
import 'package:fitstrong_gym/src/custom_import.dart';

class AttendanceDetailPage extends StatefulWidget {
  final String date;

  AttendanceDetailPage({required this.date});

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch attendance data for the specific date when the page is initialized
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.fetchAttendanceByDate(widget.date).then((_) {
      setState(() {}); // Rebuild the widget after fetching data
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final attendanceList = attendanceProvider.attendanceList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          widget.date,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: attendanceList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                Attendance attendance = attendanceList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: HexColor('FFDE03'),
                    elevation: 20,
                    shadowColor: Colors.black,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            Text('${(index + 1)}.  ',style: TextStyle(fontWeight: FontWeight.w500),),
                            Text(attendance.name,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                            Spacer(),
                            Text(attendance.time),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                //   ListTile(
                //   title: Text(attendance.name),
                //   subtitle: Text('Time: ${attendance.time}'),
                // );
              },
            ),
    );
  }
}
