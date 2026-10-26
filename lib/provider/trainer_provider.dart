import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:uuid/uuid.dart';

/// Loads and stores the gym's trainers under `Users/{uid}/trainers`.
///
/// Follows the same shape as [MemberProvider]: one cached list, every write
/// mirrored into it so screens update without a refetch.
class TrainerProvider with ChangeNotifier {
  List<TrainerModel> _trainers = [];

  List<TrainerModel> get trainers => _trainers;

  List<TrainerModel> get activeTrainers =>
      _trainers.where((t) => t.isActive).toList();

  /// Drops the cached trainers on sign out, so one gym's staff can never
  /// show up under another gym's login on the same phone.
  void clear() {
    _trainers = [];
    notifyListeners();
  }

  TrainerModel? byId(String id) => TrainerModel.findById(_trainers, id);

  Future<List<TrainerModel>> fetchTrainers() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('trainers')
          .orderBy('name')
          .get();

      _trainers = querySnapshot.docs
          .map((doc) => TrainerModel.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
      return _trainers;
    } catch (error) {
      debugPrint('Error fetching trainers: $error');
      return [];
    }
  }

  /// Saves a trainer. [photo] is optional — a gym may not have a picture of
  /// every coach, and the record is worth keeping either way.
  Future<TrainerModel?> addTrainer(TrainerModel trainer, {XFile? photo}) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    String photoUrl = '';
    if (photo != null) {
      photoUrl = await _uploadPhoto(currentUser.uid, photo);
    }

    final docRef = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('trainers')
        .add(trainer.copyWith(photoUrl: photoUrl).toMap());

    final saved = trainer.copyWith(id: docRef.id, photoUrl: photoUrl);
    _trainers = [..._trainers, saved]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    notifyListeners();
    return saved;
  }

  Future<void> updateTrainer(TrainerModel trainer, {XFile? photo}) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String photoUrl = trainer.photoUrl;
    if (photo != null) {
      photoUrl = await _uploadPhoto(currentUser.uid, photo);
    }

    final updated = trainer.copyWith(photoUrl: photoUrl);
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('trainers')
        .doc(trainer.id)
        .update(updated.toMap());

    final index = _trainers.indexWhere((t) => t.id == trainer.id);
    if (index != -1) {
      _trainers[index] = updated;
      _trainers
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      notifyListeners();
    }
  }

  /// Marks a trainer as having left without removing them, so the members
  /// they trained still show a name rather than a blank.
  Future<void> setActive(TrainerModel trainer, bool isActive) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('trainers')
        .doc(trainer.id)
        .update({'isActive': isActive});

    final index = _trainers.indexWhere((t) => t.id == trainer.id);
    if (index != -1) {
      _trainers[index] = trainer.copyWith(isActive: isActive);
      notifyListeners();
    }
  }

  /// Removes a trainer for good, and unassigns them from every member in the
  /// same batch — otherwise those members would point at a trainer that no
  /// longer exists.
  Future<void> deleteTrainer(TrainerModel trainer) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final firestore = FirebaseFirestore.instance;
    final gymDoc = firestore.collection('Users').doc(currentUser.uid);

    final assigned = await gymDoc
        .collection('members')
        .where('trainerId', isEqualTo: trainer.id)
        .get();

    final batch = firestore.batch();
    for (final doc in assigned.docs) {
      batch.update(doc.reference, {'trainerId': ''});
    }
    batch.delete(gymDoc.collection('trainers').doc(trainer.id));
    await batch.commit();

    _trainers.removeWhere((t) => t.id == trainer.id);
    notifyListeners();
  }

  Future<String> _uploadPhoto(String uid, XFile photo) async {
    final prepared = await preparePersonPhoto(photo);

    final supabase = Supabase.instance.client;
    // Named by a generated id, like member photos: two trainers sharing a
    // name would otherwise upload to the same path and overwrite each other.
    final path = 'uploads/trainer_photos/$uid/${const Uuid().v4()}.jpg';
    await supabase.storage.from('fitstrong photos').upload(
          path,
          prepared,
        );
    return supabase.storage.from('fitstrong photos').getPublicUrl(path);
  }
}

/// Members assigned to a trainer, worked out from the member list already in
/// memory rather than a second Firestore query.
List<MemberModel> membersOfTrainer(
  List<MemberModel> members,
  String trainerId,
) {
  if (trainerId.isEmpty) return const [];
  return members.where((m) => m.trainerId == trainerId).toList();
}
