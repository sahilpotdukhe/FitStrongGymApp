
import 'package:fitstrong_gym/src/custom_import.dart';

class GymPlanProvider with ChangeNotifier {
  List<GymPlanModel> _plans = [];

  List<GymPlanModel> get plans => _plans;

  Future<void> fetchPlans() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('gymPlans')
          .get();
      _plans = querySnapshot.docs
          .map((doc) => GymPlanModel(
                id: doc.id,
                name: doc['name'],
                months: doc['months'],
                days: doc['days'],
                fee: doc['fee'],
              ))
          .toList();
      notifyListeners();
    }
  }

  Future<void> addPlan(GymPlanModel plan) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final docRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('gymPlans')
          .add({
        'name': plan.name,
        'months': plan.months,
        'days': plan.days,
        'fee': plan.fee,
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
  }

  Future<void> updatePlan(String id, String name, int months,int days, double fee) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('gymPlans')
          .doc(id)
          .update({
        'name': name,
        'months': months,
        'days' : days,
        'fee': fee,
      });

      int index = _plans.indexWhere((plan) => plan.id == id);
      if (index != -1) {
        _plans[index] = GymPlanModel(
          id: id,
          name: name,
          months: months,
          days: days,
          fee: fee,
        );
        notifyListeners();
      }
    }
  }
}
