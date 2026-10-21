import 'package:fitstrong_gym/src/custom_import.dart';

/// A trainer who works at the gym.
///
/// Members point at a trainer through [MemberModel.trainerId], which is what
/// answers "who trains them". Shift times are stored as the same formatted
/// strings member check-in times use, so the two read identically on screen.
class TrainerModel {
  TrainerModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.gender,
    required this.specialization,
    required this.experienceYears,
    required this.photoUrl,
    required this.joiningDate,
    required this.shiftStart,
    required this.shiftEnd,
    required this.workingDays,
    required this.salary,
    required this.address,
    required this.isActive,
  });

  final String id;
  final String name;
  final String mobileNumber;
  final String gender;

  /// What they coach — strength, cardio, yoga and so on.
  final String specialization;
  final int experienceYears;
  final String photoUrl;
  final DateTime joiningDate;

  /// Start and end of their daily shift, e.g. "6:00 AM". Empty when not set.
  final String shiftStart;
  final String shiftEnd;

  /// Weekday names they work, from [TrainerModel.allWorkingDays].
  final List<String> workingDays;

  /// Monthly pay. Zero means "not recorded" rather than unpaid.
  final double salary;
  final String address;

  /// A trainer who has left is marked inactive rather than deleted, so the
  /// members they used to train keep a readable history.
  final bool isActive;

  static const List<String> allWorkingDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> specializations = [
    'General Fitness',
    'Strength Training',
    'Weight Loss',
    'Cardio',
    'Yoga',
    'CrossFit',
    'Bodybuilding',
    'Rehabilitation',
  ];

  /// The shift as one readable line, e.g. "6:00 AM – 11:00 AM".
  ///
  /// Shifts are stored on a 24 hour clock, so each end is written back out
  /// for people here. Records saved by older versions already hold text like
  /// "6:00 AM" and come through unchanged.
  String get shiftLabel {
    if (shiftStart.isEmpty && shiftEnd.isEmpty) return 'Shift not set';
    final start = ClockTime.label(shiftStart);
    final end = ClockTime.label(shiftEnd);
    if (shiftStart.isEmpty) return 'Until $end';
    if (shiftEnd.isEmpty) return 'From $start';
    return '$start – $end';
  }

  /// Working days as one line, collapsing the common runs so a full week
  /// does not print as seven separate chips worth of text.
  String get workingDaysLabel {
    if (workingDays.isEmpty) return 'Days not set';
    if (workingDays.length == allWorkingDays.length) return 'Every day';
    // Keeps the stored order predictable regardless of the order they were
    // ticked in.
    final ordered = allWorkingDays.where(workingDays.contains).toList();
    if (ordered.length == 6 && !ordered.contains('Sun')) {
      return 'Mon – Sat';
    }
    if (ordered.length == 5 &&
        !ordered.contains('Sat') &&
        !ordered.contains('Sun')) {
      return 'Mon – Fri';
    }
    return ordered.join(', ');
  }

  TrainerModel copyWith({String? id, String? photoUrl, bool? isActive}) {
    return TrainerModel(
      id: id ?? this.id,
      name: name,
      mobileNumber: mobileNumber,
      gender: gender,
      specialization: specialization,
      experienceYears: experienceYears,
      photoUrl: photoUrl ?? this.photoUrl,
      joiningDate: joiningDate,
      shiftStart: shiftStart,
      shiftEnd: shiftEnd,
      workingDays: workingDays,
      salary: salary,
      address: address,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobileNumber': mobileNumber,
      'gender': gender,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'photoUrl': photoUrl,
      'joiningDate': joiningDate,
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
      'workingDays': workingDays,
      'salary': salary,
      'address': address,
      'isActive': isActive,
    };
  }

  /// Reads a stored trainer. Every field falls back to a sane default, so a
  /// document written by an older version of the app still loads.
  factory TrainerModel.fromMap(String id, Map<String, dynamic> data) {
    final rawSalary = data['salary'];
    final rawDays = data['workingDays'];
    return TrainerModel(
      id: id,
      name: data['name'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      gender: data['gender'] ?? '',
      specialization: data['specialization'] ?? '',
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      photoUrl: data['photoUrl'] ?? '',
      joiningDate: data['joiningDate'] is Timestamp
          ? (data['joiningDate'] as Timestamp).toDate()
          : DateTime.now(),
      shiftStart: data['shiftStart'] ?? '',
      shiftEnd: data['shiftEnd'] ?? '',
      workingDays: rawDays is List
          ? rawDays.map((day) => day.toString()).toList()
          : <String>[],
      salary: rawSalary is num ? rawSalary.toDouble() : 0.0,
      address: data['address'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  static TrainerModel? findById(List<TrainerModel> trainers, String id) {
    if (id.isEmpty) return null;
    try {
      return trainers.firstWhere((trainer) => trainer.id == id);
    } catch (_) {
      return null;
    }
  }
}
