class UserModel {
  String uid;
  String name;
  String email;
  String profilePhoto;
  String phoneNumber;
  String qrImageUrl;
  String address;
  String signature;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePhoto,
    required this.phoneNumber,
    required this.qrImageUrl,
    required this.address,
    required this.signature
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profile_photo': profilePhoto,
      'phone_Number': phoneNumber,
      'qrImageUrl': qrImageUrl,
      'address' : address,
      'signature': signature
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> mapData) {
    return UserModel(
      uid: mapData['uid'],
      name: mapData['name'],
      email: mapData['email'],
      profilePhoto: mapData['profile_photo'],
      phoneNumber: mapData['phone_Number'],
      qrImageUrl: mapData['qrImageUrl'] ?? '',
      address: mapData['address'] ?? '',
      signature: mapData['signature']?? ''
    );
  }
}
