import 'package:fitstrong_gym/src/custom_import.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), //Listens to Firebase Auth changes in real-time (e.g., user logs in or out).
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Show loading spinner
        } else if (snapshot.hasData) {
          return CustomBottomNavigationBar(); // User logged in
        } else {
          return LoginScreen(); // User not logged in
        }
      },
    );
  }
}

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    return currentUser;
  }

  Future<UserModel> getUserDetails() async {
    User? currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await fireStore.collection("Users").doc(currentUser!.uid).get();
    return UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<User?> createAccountByEmail(
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
      String? authType,
      var qrImageUrl,
      var address,
      var signature}) async {
    await fireStore.collection("Users").doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "uid": _auth.currentUser!.uid,
      "profile_photo": profilePic,
      "phone_Number": mobilenumber,
      "qrImageUrl": qrImageUrl,
      "address": address,
      "signature": signature
    });
  }

  Future<void> updateUser(UserModel user) async {
    await fireStore.collection('Users').doc(user.uid).update({
      'name': user.name,
      'phone_Number': user.phoneNumber,
      'profile_photo': user.profilePhoto,
      'qrImageUrl': user.qrImageUrl,
      'address': user.address,
      'signature': user.signature
    });
  }

  Future<bool> checkAlreadyRegistered(String email) async {
    QuerySnapshot result = await fireStore
        .collection("Users")
        .where("email", isEqualTo: email)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    // If user is already registered means it has entry in the firestore database so the doc length will be equal to or greater than 1
    return docs.isNotEmpty ? true : false;
  }

  Future<List<UserModel>> fetchAllUsers(User currentUser) async {
    List<UserModel> userList = [];
    QuerySnapshot querySnapshot = await fireStore.collection("Users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(UserModel.fromMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    return userList;
  }

  Stream<DocumentSnapshot> getUserStream({required String uid}) =>
      fireStore.collection("Users").doc(uid).snapshots();
}
