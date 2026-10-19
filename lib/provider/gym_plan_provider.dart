import 'package:fitstrong_gym/src/custom_import.dart';

class GymPlanProvider with ChangeNotifier {
  List<GymPlanModel> _plans = [];

  /// Every plan on record, hidden ones included. Lookups by id use this, so
  /// an old invoice can still name the plan it was sold under.
  List<GymPlanModel> get plans => _plans;

  /// The plans a new member can actually be put on. Hidden plans are left
  /// out so they stop appearing in the add and renew pickers.
  List<GymPlanModel> get sellablePlans =>
      _plans.where((plan) => !plan.isHidden).toList();

  /// Plans that were retired but kept for the members still on them.
  List<GymPlanModel> get hiddenPlans =>
      _plans.where((plan) => plan.isHidden).toList();

  /// Drops the cached plans on sign out, so one gym's plans can never show up
  /// under another gym's login on the same phone.
  void clear() {
    _plans = [];
    notifyListeners();
  }

  CollectionReference<Map<String, dynamic>>? _plansRef() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('gymPlans');
  }

  Future<void> fetchPlans() async {
    final ref = _plansRef();
    if (ref == null) return;

    final querySnapshot = await ref.get();
    _plans = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return GymPlanModel(
        id: doc.id,
        name: data['name'],
        months: data['months'],
        days: data['days'],
        fee: (data['fee'] is int)
            ? (data['fee'] as int).toDouble()
            : data['fee'],
        // Plans created before hiding existed have no flag at all, and those
        // are all still on sale.
        isHidden: data['isHidden'] == true,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> addPlan(GymPlanModel plan) async {
    final ref = _plansRef();
    if (ref == null) return;

    final docRef = await ref.add({
      'name': plan.name,
      'months': plan.months,
      'days': plan.days,
      'fee': plan.fee,
      'isHidden': false,
    });

    _plans.add(GymPlanModel(
      id: docRef.id,
      name: plan.name,
      months: plan.months,
      days: plan.days,
      fee: plan.fee,
    ));
    notifyListeners();
  }

  Future<void> updatePlan(
      String id, String name, int months, int days, double fee) async {
    final ref = _plansRef();
    if (ref == null) return;

    await ref.doc(id).update({
      'name': name,
      'months': months,
      'days': days,
      'fee': fee,
    });

    final index = _plans.indexWhere((plan) => plan.id == id);
    if (index != -1) {
      _plans[index] = _plans[index].copyWith(
        name: name,
        months: months,
        days: days,
        fee: fee,
      );
      notifyListeners();
    }
  }

  /// How many member records point at [planId], counting those in the
  /// recycle bin — restoring a deleted member must not land them on a plan
  /// that no longer exists.
  static int membersOnPlan(
    String planId, {
    required List<MemberModel> members,
    required List<MemberModel> recycleBinMembers,
  }) {
    var count = 0;
    for (final member in members) {
      if (member.planId == planId) count++;
    }
    for (final member in recycleBinMembers) {
      if (member.planId == planId) count++;
    }
    return count;
  }

  /// Removes a plan for good. Only safe when nobody is on it — the screen
  /// checks that first and offers hiding instead.
  Future<void> deletePlan(String id) async {
    final ref = _plansRef();
    if (ref == null) return;

    await ref.doc(id).delete();
    _plans.removeWhere((plan) => plan.id == id);
    notifyListeners();
  }

  /// Retires a plan, or puts it back on sale. Nothing about the members on
  /// it changes; it only stops appearing where a plan is chosen.
  Future<void> setPlanHidden(String id, bool hidden) async {
    final ref = _plansRef();
    if (ref == null) return;

    await ref.doc(id).update({'isHidden': hidden});

    final index = _plans.indexWhere((plan) => plan.id == id);
    if (index != -1) {
      _plans[index] = _plans[index].copyWith(isHidden: hidden);
      notifyListeners();
    }
  }
}
