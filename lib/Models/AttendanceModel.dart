class Attendance {
  final String name;
  final String date;
  final String time;
  final String month;
  final String year;
  final int timestamp;

  Attendance({
    required this.name,
    required this.date,
    required this.time,
    required this.month,
    required this.year,
    required this.timestamp,
  });

  factory Attendance.fromMap(Map<String, dynamic> data) {
    return Attendance(
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      month: data['month'] ?? '',
      year: data['year'] ?? '',
      timestamp: data['timestamp'] ?? 0,
    );
  }
}
