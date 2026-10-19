import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MemberProvider with ChangeNotifier {
  List<MemberModel> _members = [];
  List<MemberModel> _recycleBinMembers = [];

  List<MemberModel> get members => _members;

  List<MemberModel> get recycleBinMembers => _recycleBinMembers;

  // Worked out from the one member list already in memory rather than fetched
  // separately. The dashboard used to read the whole collection three times
  // over on every visit (all, then active, then expired), which with a few
  // hundred members meant paying for three times as many reads as it needed.
  List<MemberModel> get activeMembers =>
      _members.where((m) => !m.isExpired()).toList();

  List<MemberModel> get expiredMembers =>
      _members.where((m) => m.isExpired()).toList();

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
            .orderBy('name')
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

  Future<List<MemberModel>> fetchRecycleBinMembers() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('recyclebin')
            .orderBy('name')
            .get();
        _recycleBinMembers =
            querySnapshot.docs.map((doc) => _memberFromSnapshot(doc)).toList();
        notifyListeners();
        return _recycleBinMembers;
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching recycle bin members: $error');
      return [];
    }
  }

  Future<void> restoreMember(MemberModel member) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);

        // Same batch treatment as deleting: putting the member back and
        // clearing the recycle bin entry must happen together, or a failure
        // halfway through would drop the member from both lists.
        final batch = FirebaseFirestore.instance.batch();
        batch.set(userDoc.collection('members').doc(member.id), member.toMap());
        batch.delete(userDoc.collection('recyclebin').doc(member.id));
        await batch.commit();

        await fetchRecycleBinMembers();
        await getAllMembers();
        notifyListeners();
      }
    } catch (error) {
      print('Error restoring member: $error');
      rethrow;
    }
  }

  MemberModel _memberFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberModel(
        id: doc.id,
        name: data['name'],
        mobileNumber: data['mobileNumber'],
        dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
        height: data['height'],
        weight: data['weight'],
        photoUrl: data['photoUrl'],
        planId: data['planId'],
        dateOfAdmission: (data['dateOfAdmission'] as Timestamp).toDate(),
        renewalDate: (data['renewalDate'] as Timestamp).toDate(),
        expiryDate: (data['expiryDate'] as Timestamp).toDate(),
        address: data['address'],
        gender: data['gender'],
        checkInTime: data['checkInTime'] ?? '',
        checkOutTime: data['checkOutTime'] ?? '',
        trainerId: data['trainerId'] ?? '');
  }

  /// Returns the saved member, which carries the id Firestore handed out.
  /// Callers need it: the invoice screen records which member was billed, and
  /// the member built on the add screen has an empty id until this point.
  Future<MemberModel?> addMember(MemberModel member, XFile photo) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final newPath =
          p.join((await getTemporaryDirectory()).path, '${DateTime.now()}.jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
          photo.path, newPath,
          quality: 40, format: CompressFormat.jpeg);
      final supabase = Supabase.instance.client;
      // Named by a generated id, not the member's name: two members sharing a
      // name would otherwise upload to the same path and overwrite each other.
      final fileName = '${const Uuid().v4()}.jpg';
      final path = 'uploads/member_photos/${currentUser.uid}/$fileName';

      await supabase.storage.from('fitstrong photos').upload(
            path,
            File(result!.path),
          );

      final downloadUrl =
          supabase.storage.from('fitstrong photos').getPublicUrl(path);

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
        'checkInTime': member.checkInTime,
        'checkOutTime': member.checkOutTime,
        'trainerId': member.trainerId
      };

      final docRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('members')
          .add(memberData);
      final newMember = member.copyWith(id: docRef.id, photoUrl: downloadUrl);
      _members.add(newMember);
      notifyListeners();
      return newMember;
    }
    return null;
  }

  /// Kept so existing screens can still ask for active members. It loads the
  /// member list once if it is not already in memory, then filters it.
  Future<List<MemberModel>> fetchActiveMembers() async {
    if (_members.isEmpty) await getAllMembers();
    return activeMembers;
  }

  /// The expired counterpart of [fetchActiveMembers].
  Future<List<MemberModel>> fetchExpiredMembers() async {
    if (_members.isEmpty) await getAllMembers();
    return expiredMembers;
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
          'checkInTime': member.checkInTime,
          'checkOutTime': member.checkOutTime,
          'trainerId': member.trainerId
        });
        int index = _members.indexWhere((m) => m.id == member.id);
        if (index != -1) {
          _members[index] = member;
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error updating member: $error');
      rethrow;
    }
  }

  static const _photoBucket = 'fitstrong photos';

  /// Turns a stored public photo URL back into the path inside the bucket,
  /// which is what the storage API needs in order to remove the file.
  /// Returns null for anything that is not one of our upload URLs.
  static String? storagePathFromUrl(String url) {
    if (url.isEmpty) return null;
    final segments = Uri.tryParse(url)?.pathSegments;
    if (segments == null) return null;

    final bucketIndex = segments.indexOf(_photoBucket);
    if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) return null;

    return segments.sublist(bucketIndex + 1).join('/');
  }

  /// Removes a member's photo from storage. Best effort on purpose: a photo
  /// that cannot be removed must not block the member record from going, and
  /// the same photo may already be gone from an earlier attempt.
  Future<void> _deletePhoto(String photoUrl) async {
    final path = storagePathFromUrl(photoUrl);
    if (path == null) return;
    try {
      await Supabase.instance.client.storage.from(_photoBucket).remove([path]);
    } catch (error) {
      print('Could not remove photo at $path: $error');
    }
  }

  /// Clears a member out of the recycle bin for good, photo included.
  /// Without this the photos stayed in storage forever and kept costing money.
  Future<void> permanentlyDeleteMember(MemberModel member) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('recyclebin')
          .doc(member.id)
          .delete();

      await _deletePhoto(member.photoUrl);

      _recycleBinMembers.removeWhere((m) => m.id == member.id);
      notifyListeners();
    } catch (error) {
      print('Error permanently deleting member: $error');
      rethrow;
    }
  }

  /// Empties the whole recycle bin in one go, photos included.
  Future<int> emptyRecycleBin() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return 0;

      final toRemove = List<MemberModel>.from(_recycleBinMembers);
      if (toRemove.isEmpty) return 0;

      final recycleBin = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('recyclebin');

      // Firestore caps a batch at 500 writes, so the deletes go out in chunks.
      for (var start = 0; start < toRemove.length; start += 450) {
        final end =
            (start + 450 < toRemove.length) ? start + 450 : toRemove.length;
        final batch = FirebaseFirestore.instance.batch();
        for (final member in toRemove.sublist(start, end)) {
          batch.delete(recycleBin.doc(member.id));
        }
        await batch.commit();
      }

      for (final member in toRemove) {
        await _deletePhoto(member.photoUrl);
      }

      _recycleBinMembers.clear();
      notifyListeners();
      return toRemove.length;
    } catch (error) {
      print('Error emptying recycle bin: $error');
      rethrow;
    }
  }

  /// Wipes everything held in memory. Called on sign out so the next owner to
  /// log in on this phone never sees the previous gym's members.
  void clear() {
    _members = [];
    _recycleBinMembers = [];
    notifyListeners();
  }

  Future<void> deleteMember(MemberModel member) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);

        // One batch, so the copy into the recycle bin and the removal from the
        // member list either both happen or neither does. Writing them as two
        // separate calls could lose the member entirely if the second one
        // failed (no network, app killed) after the first had gone through.
        final batch = FirebaseFirestore.instance.batch();
        batch.set(
          userDoc.collection('recyclebin').doc(member.id),
          member.toMap(),
        );
        batch.delete(userDoc.collection('members').doc(member.id));
        await batch.commit();

        _members.removeWhere((m) => m.id == member.id);
        notifyListeners();
      }
    } catch (error) {
      print('Error deleting member: $error');
      rethrow;
    }
  }
}
