import 'package:fitstrong_gym/Widgets/UniversalVariables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/AttendanceProvider.dart';

class AttendanceDetailPage extends StatelessWidget {
  final String date;
  const AttendanceDetailPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final attendanceList = provider.getByDate(date);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          _formatReadableDate(date),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: attendanceList.isEmpty
          ? const Center(
              child: Text("No records found.",
                  style: TextStyle(color: Colors.white)))
          : ListView.builder(
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final a = attendanceList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 8.0),
                  child: Card(
                    color: Colors.yellow[700],
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Text('${index + 1}.  ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          Text(a.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15)),
                          const Spacer(),
                          Text(a.time),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
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
