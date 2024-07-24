import 'package:fitstrong_gym/src/custom_import.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Authenticate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return CustomBottomNavigationBar();
    } else {
      return LoginScreen();
    }
  }
}

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    return currentUser;
  }

  Future<UserModel> getUserDetails() async {
    User? currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await firestore.collection("Users").doc(currentUser!.uid).get();
    return UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<UserModel> getUserDetailsById(id) async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection("Users").doc(id).get();
    return UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<User?> createAccountbyEmail(
      String email, String password, BuildContext context) async {
    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user != null) {
        print("User Created Successfully");
        return user;
      } else {
        print("Account creation failed");
        return user;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> logInByEmail(String email, String password) async {
    try {
      User? user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user != null) {
        print("Login Successful");
        return user;
      } else {
        print("Login failed");
        return user;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future logOut(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.signOut().then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    } catch (e) {
      print("error");
    }
  }

  void setUserProfile(
      {String? name,
      String? email,
      var mobilenumber,
      var profilePic,
      String? authType,var qrImageUrl,var address,var signature}) async {
    await firestore.collection("Users").doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "uid": _auth.currentUser!.uid,
      "profile_photo": profilePic,
      "phone_Number": mobilenumber,
      "qrImageUrl" : qrImageUrl,
      "address" : address,
      "signature": signature
    });
  }

  Future<void> updateUser(UserModel user) async {
    await firestore.collection('Users').doc(user.uid).update({
      'name': user.name,
      'phone_Number': user.phoneNumber,
      'profile_photo': user.profilePhoto,
      'qrImageUrl' : user.qrImageUrl,
      'address' : user.address,
      'signature': user.signature
    });
  }

  Future<bool> checkAlreadyRegistered(String email) async {
    QuerySnapshot result = await firestore
        .collection("Users")
        .where("email", isEqualTo: email)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    // If user is already registered means it has entry in the firestore database so the doc length will be equal to or greater than 1
    return docs.isNotEmpty ? true : false;
  }

  Future<List<UserModel>> fetchAllUsers(User currentUser) async {
    List<UserModel> userList = [];
    QuerySnapshot querySnapshot = await firestore.collection("Users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(UserModel.fromMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    return userList;
  }

  Stream<DocumentSnapshot> getUserStream({required String uid}) =>
      firestore.collection("Users").doc(uid).snapshots();
}
