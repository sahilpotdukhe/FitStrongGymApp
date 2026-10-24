import 'package:fitstrong_gym/src/custom_import.dart';

/// Empty state for a day with no check-ins recorded.
class AttendanceQuietBox extends StatelessWidget {
  const AttendanceQuietBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.qr_code_scanner_rounded,
      title: 'No check-ins yet',
      description:
          'Nobody has checked in yet. Members appear here as soon as they '
          'show their code at the front desk.',
    );
  }
}
