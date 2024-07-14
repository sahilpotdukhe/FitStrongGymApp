
import 'package:fitstrong_gym/src/custom_import.dart';

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


        _attendanceDates = querySnapshot.docs
            .map((doc) => doc['date'] as String)
            .toSet()
            .toList();
        _attendanceDates.sort((a, b) => b.compareTo(a));
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
        _attendanceList.sort((a, b) => a.time.compareTo(b.time));
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching attendance data: $e");
      throw e;
    }
  }
}
