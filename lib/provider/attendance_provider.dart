import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/models/member_model.dart';

/// What happened when a code was presented at the desk.
enum CheckinOutcome {
  recorded,

  /// Their plan has run out for good — the days they had to pay have gone
  /// too — so nothing was recorded.
  expired,

  /// Recorded, but their plan has run out and they are inside the days the
  /// gym gives them to settle up.
  paymentDue,

  /// Already recorded today, so nothing was written.
  alreadyIn,

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

  /// A member inside their days to pay was let in and written down like
  /// anybody else, so they count here too.
  bool get wasWritten =>
      outcome == CheckinOutcome.recorded ||
      outcome == CheckinOutcome.paymentDue;
}

class AttendanceProvider with ChangeNotifier {
  String? _gymId;
  List<Attendance> _allAttendance = [];

  List<Attendance> get allAttendance => _allAttendance;

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
        .orderBy(AttendanceFields.at, descending: true)
        .get();

    _allAttendance = snapshot.docs
        .map((doc) => Attendance.fromDoc(doc.id, doc.data()))
        .whereType<Attendance>()
        .toList();

    notifyListeners();
  }

  /// Records today's arrival for [member], once per day.
  Future<CheckinResult> recordScan(
    MemberModel member, {
    String source = AttendanceSource.scanner,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return CheckinResult(outcome: CheckinOutcome.failed, member: member);
    }
    _gymId ??= uid;

    // Before any write: a visit they were not allowed to make leaves no
    // trace. A member only a few days past their expiry is still let in and
    // chased for the money — the rule lives in the shared package, so this
    // app and the front desk scanner can never disagree about who gets in.
    final now = DateTime.now();
    final access = CheckinRules.accessOn(member.expiryDate, now);
    if (access == MembershipAccess.locked) {
      return CheckinResult(outcome: CheckinOutcome.expired, member: member);
    }

    try {
      final collection = _collection(uid);
      final last = await _lastScanToday(collection, member.id);

      if (CheckinRules.alreadyRecordedToday(last)) {
        return CheckinResult(
          outcome: CheckinOutcome.alreadyIn,
          member: member,
          record: last,
        );
      }

      final docRef = await collection.add(Attendance.newRecord(
        memberId: member.id,
        memberName: member.name,
        source: source,
        now: now,
      ));

      final record = await _readBack(docRef, member);
      if (record != null) {
        _allAttendance.insert(0, record);
        notifyListeners();
      }

      return CheckinResult(
        outcome: access == MembershipAccess.paymentDue
            ? CheckinOutcome.paymentDue
            : CheckinOutcome.recorded,
        member: member,
        record: record,
      );
    } catch (error) {
      debugPrint('Could not record a scan for ${member.id}: $error');
      return CheckinResult(outcome: CheckinOutcome.failed, member: member);
    }
  }

  /// The member's record for today, if they have been in.
  ///
  /// Keyed on the device clock rather than the server stamp, matching the
  /// scanner: a record still queued on an offline device has no server
  /// stamp yet, and a server-keyed query would miss it and let the same
  /// person be recorded twice.
  Future<Attendance?> _lastScanToday(
    CollectionReference<Map<String, dynamic>> collection,
    String memberId,
  ) async {
    final dayStart = CheckinRules.startOfDay(DateTime.now());

    final snapshot = await collection
        .where(AttendanceFields.memberId, isEqualTo: memberId)
        .where(AttendanceFields.deviceAt,
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .orderBy(AttendanceFields.deviceAt, descending: true)
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
        source: AttendanceSource.scanner,
      );
    }
  }

  CollectionReference<Map<String, dynamic>> _collection(String gymId) =>
      FirebaseFirestore.instance
          .collection(MemberFields.gyms)
          .doc(gymId)
          .collection(MemberFields.attendance);

  /// Clears the cached attendance and the gym it belonged to, on sign out.
  void clear() {
    _gymId = null;
    _allAttendance = [];
    notifyListeners();
  }

  /// Every arrival on one day, newest first.
  List<Attendance> getByDate(String dateKey) =>
      _allAttendance.where((a) => a.dateKey == dateKey).toList();

  /// How many different members were seen on [dateKey].
  int distinctMembersOn(String dateKey) =>
      getByDate(dateKey).map((a) => a.memberId).toSet().length;
}
