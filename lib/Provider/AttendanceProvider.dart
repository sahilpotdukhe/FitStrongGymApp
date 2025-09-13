import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/AttendanceModel.dart';

class AttendanceProvider with ChangeNotifier {
  String? _gymId;
  List<Attendance> _allAttendance = [];

  List<Attendance> get allAttendance => _allAttendance;

  Future<void> setGymId(String gymId) async {
    _gymId = gymId;
    await fetchAttendance(); // now awaitable
  }

  Future<void> fetchAttendance() async {
    if (_gymId == null) {
      print("❌ gymId is null. Cannot fetch attendance.");
      return;
    }

    print("📥 Fetching attendance from: Users/$_gymId/attendance");

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_gymId)
        .collection('attendance')
        .orderBy('timestamp', descending: true)
        .get();

    _allAttendance =
        snapshot.docs.map((doc) => Attendance.fromMap(doc.data())).toList();

    print("✅ Fetched ${_allAttendance.length} records.");
    notifyListeners();
  }

  List<Attendance> getByDate(String date) {
    return _allAttendance.where((a) => a.date == date).toList();
  }
}
