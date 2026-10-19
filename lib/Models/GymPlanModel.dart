/// One membership plan the gym sells: what it is called, how long it runs
/// and what it costs.
class GymPlanModel {
  final String id;
  final String name;
  final int months;
  final int days;
  final double fee;

  /// A hidden plan is no longer offered to new members, but stays on record
  /// so the members already on it — and their past invoices — keep showing
  /// the right plan name and length.
  ///
  /// This is what a plan still in use becomes instead of being deleted.
  final bool isHidden;

  GymPlanModel({
    required this.id,
    required this.name,
    required this.months,
    required this.days,
    required this.fee,
    this.isHidden = false,
  });

  GymPlanModel copyWith({
    String? name,
    int? months,
    int? days,
    double? fee,
    bool? isHidden,
  }) {
    return GymPlanModel(
      id: id,
      name: name ?? this.name,
      months: months ?? this.months,
      days: days ?? this.days,
      fee: fee ?? this.fee,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  /// Total length of the plan in days, used to compare plans of different
  /// shapes (3 months vs 100 days) against each other.
  int get lengthInDays => months * 30 + days;

  /// Finds a plan by id, including hidden ones: an old invoice must still be
  /// able to name the plan it was sold under.
  static GymPlanModel? findById(List<GymPlanModel> plans, String id) {
    try {
      return plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }
}
