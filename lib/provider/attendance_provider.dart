import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fitstrong_gym/models/attendance_model.dart';

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
      debugPrint("❌ gymId is null. Cannot fetch attendance.");
      return;
    }

    debugPrint("📥 Fetching attendance from: Users/$_gymId/attendance");

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_gymId)
        .collection('attendance')
        .orderBy('timestamp', descending: true)
        .get();

    _allAttendance =
        snapshot.docs.map((doc) => Attendance.fromMap(doc.data())).toList();

    debugPrint("✅ Fetched ${_allAttendance.length} records.");
    notifyListeners();
  }

  /// Writes a check in for [memberName], dated today.
  ///
  /// Nothing in the app used to write to this collection at all, so the
  /// attendance screen could only ever sit empty. Returns false when the
  /// member has already been marked present today, so the same person cannot
  /// be counted twice.
  Future<bool> markAttendance(String memberName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    _gymId ??= currentUser.uid;

    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);

    final attendanceRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('attendance');

    final existing = await attendanceRef
        .where('date', isEqualTo: date)
        .where('name', isEqualTo: memberName)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return false;

    final record = {
      'name': memberName,
      'date': date,
      'time': DateFormat('h:mm a').format(now),
      'month': DateFormat('MMMM').format(now),
      'year': DateFormat('yyyy').format(now),
      'timestamp': now.millisecondsSinceEpoch,
    };

    await attendanceRef.add(record);

    _allAttendance.insert(0, Attendance.fromMap(record));
    notifyListeners();
    return true;
  }

  /// Clears the cached attendance and the gym it belonged to, on sign out.
  void clear() {
    _gymId = null;
    _allAttendance = [];
    notifyListeners();
  }

  List<Attendance> getByDate(String date) {
    return _allAttendance.where((a) => a.date == date).toList();
  }
}
