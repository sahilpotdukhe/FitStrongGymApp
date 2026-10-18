import 'package:fitstrong_gym/src/custom_import.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userModel;
  final bool _isLoading = false;
  AuthMethods authMethods = AuthMethods();

  bool get isLoading => _isLoading;
  UserModel? get getUser => _userModel;

  Future<void> refreshUser() async {
    UserModel user = await authMethods.getUserDetails();
    _userModel = user;
    print(_userModel);
    notifyListeners();
  }

  void setUser(UserModel user) {
    _userModel = user;
    notifyListeners();
  }

  /// Forgets the signed in gym owner. Called on sign out so the next person
  /// to log in on this phone does not briefly see the previous owner's name.
  void clear() {
    _userModel = null;
    notifyListeners();
  }
}
