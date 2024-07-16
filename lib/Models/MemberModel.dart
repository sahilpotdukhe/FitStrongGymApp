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

  MemberModel({
    required this.id,
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
    required this.checkOutTime
  });

  MemberModel copyWith({String? id}) {
    return MemberModel(
      id: id ?? this.id,
      name: name,
      mobileNumber: mobileNumber,
      dateOfBirth: dateOfBirth,
      height: height,
      weight: weight,
      photoUrl: photoUrl,
      planId: planId,
      dateOfAdmission: dateOfAdmission,
      renewalDate: renewalDate,
      expiryDate: expiryDate,
      // Add this field
      address: address,
      gender: gender,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime
    );
  }

  bool isExpired(List<GymPlanModel> plans) {
    return DateTime.now().isAfter(expiryDate);
  }

  MemberModel renewMembership(GymPlanModel newPlan, DateTime newDateOfAdmission) {
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
      renewalDate: newDateOfAdmission,
      expiryDate: DateTime(newDateOfAdmission.year,
          newDateOfAdmission.month + newPlan.months, newDateOfAdmission.day).add(Duration(days: newPlan.days)),
      address: address,
      gender: gender,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime
    );
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
      'checkInTime' : checkInTime,
      'checkOutTime' : checkOutTime,
    };
  }

  static String timeOfDayToString(BuildContext context, TimeOfDay? time) {
    return time!.format(context);
  }

  static TimeOfDay? stringToTimeOfDay(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
