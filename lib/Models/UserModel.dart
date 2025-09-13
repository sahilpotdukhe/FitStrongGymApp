class UserModel {
  String uid;
  String name;
  String email;
  String profilePhoto;
  String phoneNumber;
  String address;
  String signatureImageUrl;
  String merchantName;
  String upiId;

  UserModel(
      {required this.uid,
      required this.name,
      required this.email,
      required this.profilePhoto,
      required this.phoneNumber,
      required this.address,
      required this.signatureImageUrl,
      required this.merchantName,
      required this.upiId});

  /// Convert object to Map for Firestore or local storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profile_photo': profilePhoto,
      'phone_Number': phoneNumber,
      'address': address,
      'signatureImageUrl': signatureImageUrl,
      'merchantName': merchantName,
      'upiId': upiId
    };
  }

  /// Create a `UserModel` from a Firestore document or API response
  factory UserModel.fromMap(Map<String, dynamic> mapData) {
    return UserModel(
        uid: mapData['uid'],
        name: mapData['name'],
        email: mapData['email'],
        profilePhoto: mapData['profile_photo'],
        phoneNumber: mapData['phone_Number'],
        address: mapData['address'] ?? '',
        signatureImageUrl: mapData['signatureImageUrl'] ?? '',
        merchantName: mapData['merchantName'] ?? '',
        upiId: mapData['upiId'] ?? '');
  }
}
