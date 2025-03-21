class GymPlanModel {
  final String id;
  final String name;
  final int months;
  final int days;
  final double fee;

  GymPlanModel({
    required this.id,
    required this.name,
    required this.months,
    required this.days,
    required this.fee,
  });

  // Add this method
  static GymPlanModel? findById(List<GymPlanModel> plans, String id) {
    try {
      return plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }
}
