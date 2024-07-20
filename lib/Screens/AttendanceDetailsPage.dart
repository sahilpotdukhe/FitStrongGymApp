import 'package:fitstrong_gym/Widgets/AttendanceQuietPage.dart';
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

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

    // Separate morning and evening attendances
    final morningAttendances = attendanceList
        .where((attendance) => DateFormat('h:mm a').parse(attendance.time).hour < 12)
        .toList();
    final eveningAttendances = attendanceList
        .where((attendance) => DateFormat('h:mm a').parse(attendance.time).hour >= 12)
        .toList();

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
          ? AttendanceQuietBox()
          : ListView(
        children: [
          if (morningAttendances.isNotEmpty)
            _buildSection('Morning', morningAttendances),
          if (eveningAttendances.isNotEmpty)
            _buildSection('Evening', eveningAttendances),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Attendance> attendances) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          ...attendances.asMap().entries.map((entry) {
            int index = entry.key;
            Attendance attendance = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Card(
                color: HexColor('FFDE03'),
                elevation: 20,
                shadowColor: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}.  ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        attendance.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      Spacer(),
                      Text(attendance.time),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
