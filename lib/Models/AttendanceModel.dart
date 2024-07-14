class Attendance {
  final String name;
  final String date; // Storing date as a string
  final String time;

  Attendance({
    required this.name,
    required this.date,
    required this.time,
  });

  factory Attendance.fromMap(Map<String, dynamic> data) {
    return Attendance(
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date,
      'time': time,
    };
  }
}
