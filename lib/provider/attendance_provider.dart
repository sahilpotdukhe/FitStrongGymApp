import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/models/member_model.dart';

/// What happened when a code was presented at the desk.
enum CheckinOutcome {
  checkedIn,
  checkedOut,

  /// Their plan has run out, so nothing was recorded.
  expired,

  /// Scanned again moments later: almost always the camera repeating.
  tooSoon,

  /// The write did not go through.
  failed,
}

/// One scan's outcome, with enough detail for the desk to show a name and a
/// face without another lookup.
class CheckinResult {
  const CheckinResult({
    required this.outcome,
    required this.member,
    this.record,
  });

  final CheckinOutcome outcome;
  final MemberModel member;
  final Attendance? record;

  bool get recorded =>
      outcome == CheckinOutcome.checkedIn || outcome == CheckinOutcome.checkedOut;
}

class AttendanceProvider with ChangeNotifier {
  String? _gymId;
  List<Attendance> _allAttendance = [];

  List<Attendance> get allAttendance => _allAttendance;

  /// A continuous camera reads the same code many times a second. Without
  /// this gap the next frame would check the member straight back out.
  static const Duration scanCooldown = Duration(seconds: 60);

  Future<void> setGymId(String gymId) async {
    _gymId = gymId;
    await fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    final gymId = _gymId;
    if (gymId == null) {
      debugPrint('gymId is null. Cannot fetch attendance.');
      return;
    }

    final snapshot = await _collection(gymId)
        .orderBy('at', descending: true)
        .get();

    _allAttendance = snapshot.docs
        .map((doc) => Attendance.fromDoc(doc.id, doc.data()))
        .whereType<Attendance>()
        .toList();

    notifyListeners();
  }

  /// Records a scan, working out by itself whether the member is arriving or
  /// leaving, so the desk never has to pick a mode.
  Future<CheckinResult> recordScan(
    MemberModel member, {
    String source = AttendanceSource.scanner,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return CheckinResult(outcome: CheckinOutcome.failed, member: member);
    }
    _gymId ??= uid;

    // Before any write: a visit they were not allowed to make leaves no trace.
    if (member.isExpired()) {
      return CheckinResult(outcome: CheckinOutcome.expired, member: member);
    }

    try {
      final collection = _collection(uid);
      final last = await _lastScanToday(collection, member.id);

      if (isRepeatScan(last, DateTime.now())) {
        return CheckinResult(
          outcome: CheckinOutcome.tooSoon,
          member: member,
          record: last,
        );
      }

      final type = nextType(last);

      final docRef = await collection.add({
        'memberId': member.id,
        'memberName': member.name,
        'at': FieldValue.serverTimestamp(),
        'type': type.code,
        'source': source,
      });

      final record = await _readBack(docRef, member, type);
      if (record != null) {
        _allAttendance.insert(0, record);
        notifyListeners();
      }

      return CheckinResult(
        outcome: type == CheckinType.checkIn
            ? CheckinOutcome.checkedIn
            : CheckinOutcome.checkedOut,
        member: member,
        record: record,
      );
    } catch (error) {
      debugPrint('Could not record a scan for ${member.id}: $error');
      return CheckinResult(outcome: CheckinOutcome.failed, member: member);
    }
  }

  /// Nobody in yet today means arriving; after that it alternates. Kept
  /// out of the database call so the rule can be tested.
  @visibleForTesting
  static CheckinType nextType(Attendance? last) =>
      (last == null || last.type == CheckinType.checkOut)
          ? CheckinType.checkIn
          : CheckinType.checkOut;

  /// Whether this is the camera repeating [last] rather than a real visit.
  @visibleForTesting
  static bool isRepeatScan(Attendance? last, DateTime now) {
    if (last == null) return false;
    return now.difference(last.at).abs() < scanCooldown;
  }

  /// The member's last scan since midnight. Only today counts, so somebody
  /// who forgot to scan out last night starts the day checked in.
  Future<Attendance?> _lastScanToday(
    CollectionReference<Map<String, dynamic>> collection,
    String memberId,
  ) async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);

    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .orderBy('at', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Attendance.fromDoc(doc.id, doc.data());
  }

  /// Reads the record back from the server so the time shown is the one
  /// stored. Offline, the write stays queued and the device clock stands in
  /// until the next refresh corrects it.
  Future<Attendance?> _readBack(
    DocumentReference<Map<String, dynamic>> docRef,
    MemberModel member,
    CheckinType type,
  ) async {
    try {
      final saved = await docRef.get(const GetOptions(source: Source.server));
      return Attendance.fromDoc(saved.id, saved.data());
    } catch (error) {
      debugPrint('Scan saved but could not be read back: $error');
      return Attendance(
        id: docRef.id,
        memberId: member.id,
        memberName: member.name,
        at: DateTime.now(),
        type: type,
        source: AttendanceSource.scanner,
      );
    }
  }

  CollectionReference<Map<String, dynamic>> _collection(String gymId) =>
      FirebaseFirestore.instance
          .collection('Users')
          .doc(gymId)
          .collection('attendance');

  /// Clears the cached attendance and the gym it belonged to, on sign out.
  void clear() {
    _gymId = null;
    _allAttendance = [];
    notifyListeners();
  }

  /// Every scan on one day, newest first.
  List<Attendance> getByDate(String dateKey) =>
      _allAttendance.where((a) => a.dateKey == dateKey).toList();

  /// How many different members were seen: in and out again is one person.
  int distinctMembersOn(String dateKey) =>
      getByDate(dateKey).map((a) => a.memberId).toSet().length;
}
