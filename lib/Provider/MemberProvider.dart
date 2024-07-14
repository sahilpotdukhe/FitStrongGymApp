
import 'package:fitstrong_gym/src/custom_import.dart';

class MemberProvider with ChangeNotifier {
  List<MemberModel> _members = [];
  List<MemberModel> _recycleBinMembers = [];
  List<MemberModel> _activeMembers = [];
  List<MemberModel> _expiredMembers = [];

  List<MemberModel> get members => _members;

  List<MemberModel> get recycleBinMembers => _recycleBinMembers;

  List<MemberModel> get activeMembers => _activeMembers;

  List<MemberModel> get expiredMembers => _expiredMembers;

  MemberProvider() {
    // Fetch members when the provider is initialized
    getAllMembers();
  }

  Future<List<MemberModel>> getAllMembers() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('members')
            .get();
        _members =
            querySnapshot.docs.map((doc) => _memberFromSnapshot(doc)).toList();
        notifyListeners();
        return _members;
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching members: $error');
      return [];
    }
  }

  Future<void> fetchRecycleBinMembers() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('recyclebin')
            .get();
        _recycleBinMembers =
            querySnapshot.docs.map((doc) => _memberFromSnapshot(doc)).toList();
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching recycle bin members: $error');
    }
  }

  Future<void> restoreMember(MemberModel member) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('recyclebin')
            .doc(member.id)
            .delete();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('members')
            .doc(member.id)
            .set(member.toMap());
        await fetchRecycleBinMembers();
        await getAllMembers();
        notifyListeners();
      }
    } catch (error) {
      print('Error restoring member: $error');
    }
  }

  MemberModel _memberFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberModel(
      id: doc.id,
      name: data['name'],
      mobileNumber: data['mobileNumber'],
      dateOfBirth:
          (data['dateOfBirth'] as Timestamp)?.toDate() ?? DateTime.now(),
      height: data['height'],
      weight: data['weight'],
      photoUrl: data['photoUrl'],
      planId: data['planId'],
      dateOfAdmission:
          (data['dateOfAdmission'] as Timestamp)?.toDate() ?? DateTime.now(),
      renewalDate:
          (data['renewalDate'] as Timestamp)?.toDate() ?? DateTime.now(),
      expiryDate: (data['expiryDate'] as Timestamp)?.toDate() ?? DateTime.now(),
      address: data['address'],
      gender: data['gender'],
    );
  }

  Future<void> addMember(MemberModel member, XFile photo) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('member_photos/${member.name}.jpg');
      final uploadTask = storageRef.putFile(File(photo.path));
      final downloadUrl = await (await uploadTask).ref.getDownloadURL();

      final memberData = {
        'name': member.name,
        'mobileNumber': member.mobileNumber,
        'dateOfBirth': member.dateOfBirth,
        'height': member.height,
        'weight': member.weight,
        'photoUrl': downloadUrl,
        'planId': member.planId,
        'dateOfAdmission': member.dateOfAdmission,
        'renewalDate': member.renewalDate,
        'expiryDate': member.expiryDate,
        'address': member.address,
        'gender': member.gender,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('members')
          .add(memberData);
      final newMember = member.copyWith(id: docRef.id);
      _members.add(newMember);
      notifyListeners();
    }
  }

  Future<List<MemberModel>> fetchActiveMembers() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('members')
            .where('expiryDate', isGreaterThan: Timestamp.now())
            .get();
        _activeMembers =
            querySnapshot.docs.map((doc) => _memberFromSnapshot(doc)).toList();
        notifyListeners();
        return _activeMembers;
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching active members: $error');
      return [];
    }
  }

  Future<List<MemberModel>> fetchExpiredMembers() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('members')
            .where('expiryDate', isLessThanOrEqualTo: Timestamp.now())
            .get();
        _expiredMembers =
            querySnapshot.docs.map((doc) => _memberFromSnapshot(doc)).toList();
        notifyListeners();
        return _expiredMembers;
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching expired members: $error');
      return [];
    }
  }

  Future<void> updateMember(MemberModel member) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('members')
            .doc(member.id)
            .update({
          'name': member.name,
          'mobileNumber': member.mobileNumber,
          'dateOfBirth': member.dateOfBirth,
          'height': member.height,
          'weight': member.weight,
          'photoUrl': member.photoUrl,
          'planId': member.planId,
          'dateOfAdmission': member.dateOfAdmission,
          'renewalDate': member.renewalDate,
          'expiryDate': member.expiryDate,
          'address': member.address,
          'gender': member.gender,
        });
        int index = _members.indexWhere((m) => m.id == member.id);
        if (index != -1) {
          _members[index] = member;
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error updating member: $error');
      throw error;
    }
  }

  Future<void> deleteMember(MemberModel member) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('recyclebin')
            .doc(member.id)
            .set(member.toMap());
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('members')
            .doc(member.id)
            .delete();

        _members.removeWhere((m) => m.id == member.id);
        notifyListeners();
      }
    } catch (error) {
      print('Error deleting member: $error');
    }
  }
}
