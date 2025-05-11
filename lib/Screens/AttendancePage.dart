import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitstrong_gym/Provider/AttendanceProvider.dart';
import 'package:fitstrong_gym/Screens/AttendanceDetailsPage.dart';
import 'package:fitstrong_gym/Widgets/AttendanceQuietPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSetGymId();
  }

  Future<void> _fetchAndSetGymId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Provider.of<AttendanceProvider>(context, listen: false)
          .setGymId(user.uid);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final allAttendance = provider.allAttendance;

    // Group by year > month > date
    final grouped = <String, Map<String, List<String>>>{};

    for (var record in allAttendance) {
      final year = record.year;
      final month = "${record.month} $year";
      grouped.putIfAbsent(year, () => {});
      grouped[year]!.putIfAbsent(month, () => []);
      if (!grouped[year]![month]!.contains(record.date)) {
        grouped[year]![month]!.add(record.date);
      }
    }

    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFEDEAFF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : allAttendance.isEmpty
              ? AttendanceQuietBox()
              : ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, yearIndex) {
                    final year = years[yearIndex];
                    final months = grouped[year]!.keys.toList()
                      ..sort((a, b) =>
                          _monthSortValue(b).compareTo(_monthSortValue(a)));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...months.map((month) {
                          final dates = grouped[year]![month]!
                            ..sort((a, b) => b.compareTo(a));
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                child: Text(
                                  month,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              ...dates.map((date) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AttendanceDetailPage(
                                                    date: date),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 18, horizontal: 20),
                                          child: Row(
                                            children: [
                                              Text(
                                                _formatReadableDate(date),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          );
                        }),
                      ],
                    );
                  },
                ),
    );
  }

  /// Sort months by value for descending order (January = 1, December = 12)
  int _monthSortValue(String monthYear) {
    final parts = monthYear.split(' ');
    const monthOrder = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12
    };
    return int.parse(parts[1]) * 100 + (monthOrder[parts[0]] ?? 0);
  }

  String _formatReadableDate(String date) {
    try {
      final parts = date.split('-'); // "2024-11-25"
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      final year = parts[0];
      const monthNames = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '$day ${monthNames[month]}, $year';
    } catch (_) {
      return date;
    }
  }
}
