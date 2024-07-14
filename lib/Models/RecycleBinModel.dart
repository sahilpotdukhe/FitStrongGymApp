class RecycleBinModel {
  final String id;
  final String name;
  final String mobileNumber;
  final DateTime dateOfBirth;
  final int height;
  final int weight;
  final String? photoUrl;
  final String planId;
  final DateTime dateOfAdmission;
  final DateTime expiryDate;
  final String address;
  final String gender;

  RecycleBinModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
    this.photoUrl,
    required this.planId,
    required this.dateOfAdmission,
    required this.expiryDate,
    required this.address,
    required this.gender,
  });

  // Factory method to create RecycleBinMember from a map
  factory RecycleBinModel.fromMap(Map<String, dynamic> map, String id) {
    return RecycleBinModel(
      id: id,
      name: map['name'],
      mobileNumber: map['mobileNumber'],
      dateOfBirth: map['dateOfBirth'],
      height: map['height'],
      weight: map['weight'],
      photoUrl: map['photoUrl'],
      planId: map['planId'],
      dateOfAdmission: map['dateOfAdmission'],
      expiryDate: map['expiryDate'],
      address: map['address'],
      gender: map['gender'],
    );
  }
}
