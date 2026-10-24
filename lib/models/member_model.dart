import 'package:fitstrong_gym/src/custom_import.dart';

class MemberModel {
  final String id;
  final String name;
  final String mobileNumber;
  final DateTime dateOfBirth;
  final double height;
  final double weight;
  final String photoUrl;
  final String planId;
  final DateTime dateOfAdmission;
  final DateTime renewalDate;
  final DateTime expiryDate; // Add this field
  final String address;
  final String gender;
  final String checkInTime; // Changed to String
  final String checkOutTime; // Changed to String

  /// The trainer assigned to this member, or '' when nobody is. Optional on
  /// purpose: a gym can run without trainers, and records written before
  /// trainers existed have no value here.
  final String trainerId;

  /// The random token behind this member's QR code. Empty for older
  /// members, who are given one the first time their code is opened.
  final String checkinToken;

  MemberModel(
      {required this.id,
      required this.name,
      required this.mobileNumber,
      required this.dateOfBirth,
      required this.height,
      required this.weight,
      required this.photoUrl,
      required this.planId,
      required this.dateOfAdmission,
      required this.renewalDate,
      required this.expiryDate, // Add this field
      required this.address,
      required this.gender,
      required this.checkInTime,
      required this.checkOutTime,
      this.trainerId = '',
      this.checkinToken = ''});

  MemberModel copyWith(
      {String? id, String? photoUrl, String? trainerId, String? checkinToken}) {
    return MemberModel(
        id: id ?? this.id,
        name: name,
        mobileNumber: mobileNumber,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
        photoUrl: photoUrl ?? this.photoUrl,
        planId: planId,
        dateOfAdmission: dateOfAdmission,
        renewalDate: renewalDate,
        expiryDate: expiryDate,
        address: address,
        gender: gender,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        trainerId: trainerId ?? this.trainerId,
        checkinToken: checkinToken ?? this.checkinToken);
  }

  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  /// Moves [from] forward by [months] calendar months, keeping the same day of
  /// the month where that day exists and falling back to the last day of the
  /// target month where it does not.
  ///
  /// Written out by hand because `DateTime(year, month + months, day)` rolls a
  /// day that the target month is too short for into the following month: a
  /// renewal taken on 31 January for a one month plan landed on 3 March and
  /// quietly handed the member two free days.
  static DateTime addMonths(DateTime from, int months) {
    final totalMonths = from.month - 1 + months;
    final year = from.year + (totalMonths ~/ 12);
    final month = totalMonths % 12 + 1;

    // Day 0 of the next month is the last day of this one, which gives the
    // length of the target month without a lookup table or a leap year rule.
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = from.day < lastDayOfMonth ? from.day : lastDayOfMonth;

    return DateTime(year, month, day);
  }

  MemberModel renewMembership(
      GymPlanModel newPlan, DateTime newDateOfAdmission) {
    final newExpiryDate = addMonths(newDateOfAdmission, newPlan.months)
        .add(Duration(days: newPlan.days));

    return MemberModel(
        id: id,
        name: name,
        mobileNumber: mobileNumber,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
        photoUrl: photoUrl,
        planId: newPlan.id,
        dateOfAdmission: dateOfAdmission,
        renewalDate: newExpiryDate,
        expiryDate: newExpiryDate,
        address: address,
        gender: gender,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        trainerId: trainerId,
        checkinToken: checkinToken);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'dateOfBirth': dateOfBirth,
      'height': height,
      'weight': weight,
      'photoUrl': photoUrl,
      'planId': planId,
      'dateOfAdmission': dateOfAdmission,
      'renewalDate': renewalDate,
      'expiryDate': expiryDate,
      'address': address,
      'gender': gender,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'trainerId': trainerId,
      'checkinToken': checkinToken,
    };
  }

}
