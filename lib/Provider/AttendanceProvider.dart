
import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:intl/intl.dart';

class AttendanceProvider with ChangeNotifier {
  List<String> _attendanceDates = [];
  List<Attendance> _attendanceList = [];

  List<String> get attendanceDates => _attendanceDates;
  List<Attendance> get attendanceList => _attendanceList;

  Future<void> fetchAttendanceDates() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('attendance')
            .get();

        // Use a temporary list to store DateTime objects
        List<DateTime> dateTimes = querySnapshot.docs
            .map((doc) => doc['date'] as String)
            .toSet()
            .map((dateString) => DateFormat('d MMMM, yyyy').parse(dateString))
            .toList();

        // Sort the DateTime objects in descending order
        dateTimes.sort((a, b) => b.compareTo(a));

        // Convert DateTime objects back to strings
        _attendanceDates = dateTimes
            .map((date) => DateFormat('d MMMM, yyyy').format(date))
            .toList();

        print(_attendanceDates);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching attendance dates: $e");
      throw e;
    }
  }

  Future<void> fetchAttendanceByDate(String date) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('attendance')
            .where('date', isEqualTo: date)
            .get();

        _attendanceList = querySnapshot.docs
            .map((doc) => Attendance.fromMap(doc.data()))
            .toList();

        // Parse the time strings to DateTime and sort
        _attendanceList.sort((a, b) {
          DateTime timeA = DateFormat('h:mm a').parse(a.time);
          DateTime timeB = DateFormat('h:mm a').parse(b.time);
          return timeA.compareTo(timeB);
        });

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching attendance data: $e");
      throw e;
    }
  }
}
