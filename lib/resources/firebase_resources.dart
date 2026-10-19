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
          // Themed, so the hand-off from splash to home doesn't flash white.
          return const Scaffold(body: Loading());
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

  /// Why the last sign in or sign up attempt failed, in words a gym owner can
  /// act on. Previously every failure looked identical on screen, so a typo in
  /// the password and a dead internet connection gave the same message.
  String? lastErrorMessage;

  /// Turns Firebase's error codes into plain English.
  static String describeAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address does not look right. Please check it and try again.';
        case 'user-not-found':
          return 'No account exists for this email address. Please sign up first.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'The email or password is incorrect. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'email-already-in-use':
          return 'An account already exists for this email address. Try signing in instead.';
        case 'weak-password':
          return 'That password is too weak. Please use at least six characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few minutes and try again.';
        case 'network-request-failed':
          return 'No internet connection. Please check your network and try again.';
        case 'operation-not-allowed':
          return 'Email sign in is turned off for this app. Please contact support.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

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
    lastErrorMessage = null;
    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user == null) {
        lastErrorMessage = 'Account creation failed. Please try again.';
      }
      return user;
    } catch (e) {
      debugPrint(e.toString());
      lastErrorMessage = describeAuthError(e);
      return null;
    }
  }

  Future<User?> logInByEmail(String email, String password) async {
    lastErrorMessage = null;
    try {
      User? user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user == null) {
        lastErrorMessage = 'Login failed. Please try again.';
      }
      return user;
    } catch (e) {
      debugPrint(e.toString());
      lastErrorMessage = describeAuthError(e);
      return null;
    }
  }

  Future logOut(BuildContext context) async {
    // Hold on to the navigator and messenger before awaiting: once sign-out
    // finishes the screen that gave us this context may already be gone.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      lastErrorMessage = describeAuthError(e);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(lastErrorMessage ?? 'Could not sign out.')),
      );
    }
  }

  void setUserProfile(
      {String? name,
      String? email,
      var mobilenumber,
      var profilePic,
      String? authType,
      var address,
      var signatureImageUrl,
      var merchantName,
      var upiId}) async {
    await fireStore.collection("Users").doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "uid": _auth.currentUser!.uid,
      "profile_photo": profilePic,
      "phone_Number": mobilenumber,
      "address": address,
      "signatureImageUrl": signatureImageUrl,
      "merchantName": merchantName,
      "upiId": upiId
    });
  }

  Future<void> updateUser(UserModel user) async {
    await fireStore.collection('Users').doc(user.uid).update({
      'name': user.name,
      'phone_Number': user.phoneNumber,
      'profile_photo': user.profilePhoto,
      'address': user.address,
      'signatureImageUrl': user.signatureImageUrl,
      'merchantName': user.merchantName,
      'upiId': user.upiId,
    });
  }
}
