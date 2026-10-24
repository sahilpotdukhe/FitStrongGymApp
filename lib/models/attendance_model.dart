import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Which way through the door a scan was.
enum CheckinType {
  checkIn('in'),
  checkOut('out');

  const CheckinType(this.code);

  /// What goes into Firestore. Stored as a short string rather than the enum
  /// name so renaming the Dart value never rewrites the database.
  final String code;

  static CheckinType fromCode(Object? code) =>
      code == 'out' ? CheckinType.checkOut : CheckinType.checkIn;
}

/// Where a record came from, kept so a disputed entry can be traced back to
/// the front desk scanner or to a member the owner marked present by hand.
class AttendanceSource {
  const AttendanceSource._();

  static const String scanner = 'scanner';
  static const String manual = 'manual';
}

/// One scan: a member, a moment, and which direction they were going.
///
/// The moment is the only time this record carries. The day, the month and
/// the clock time shown on screen are all worked out from it, so there is no
/// way for them to disagree with each other — which is exactly what happened
/// when each was stored as its own string.
class Attendance {
  const Attendance({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.at,
    required this.type,
    required this.source,
  });

  final String id;

  /// The member's record id. The stable label: a member can be renamed and
  /// their history still points at the right person.
  final String memberId;

  /// Copied in at the time of the scan so the attendance list can be shown
  /// without loading every member, and so a deleted member's history still
  /// says who it was.
  final String memberName;

  /// Stamped by Firestore's servers, never by the scanning device. A tablet
  /// with a wrong clock can no longer quietly corrupt the history.
  final DateTime at;

  final CheckinType type;
  final String source;

  /// The day this scan belongs to, in the gym's own timezone.
  String get dateKey => DateFormat('yyyy-MM-dd').format(at);

  String get timeLabel => DateFormat('h:mm a').format(at);

  String get monthLabel => DateFormat('MMMM yyyy').format(at);

  /// Reads a record back, or null when it cannot be trusted.
  ///
  /// A write using a server timestamp reaches the local cache before the
  /// server has stamped it, so `at` is briefly null. Such a record is skipped
  /// rather than guessed at — it reappears a moment later with a real time.
  static Attendance? fromDoc(String id, Map<String, dynamic>? data) {
    if (data == null) return null;
    final at = data['at'];
    if (at is! Timestamp) return null;

    return Attendance(
      id: id,
      memberId: (data['memberId'] ?? '').toString(),
      memberName: (data['memberName'] ?? '').toString(),
      at: at.toDate(),
      type: CheckinType.fromCode(data['type']),
      source: (data['source'] ?? AttendanceSource.scanner).toString(),
    );
  }
}
