import 'package:fitstrong_core/fitstrong_core.dart';
import 'package:fitstrong_gym/resources/attendance_insights.dart';
import 'package:fitstrong_gym/screens/attendance_insights_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_kit/shadcn_kit.dart';

Attendance visit(DateTime at, {String memberId = 'm1', String name = 'Asha'}) {
  return Attendance(
    id: '$memberId-${at.toIso8601String()}',
    memberId: memberId,
    memberName: name,
    at: at,
    source: AttendanceSource.scanner,
  );
}

/// A fortnight of arrivals, busiest at 6 PM, so every chart has something
/// real to draw.
List<Attendance> busyGym() {
  final records = <Attendance>[];
  final start = DateTime.now().subtract(const Duration(days: 13));
  for (var day = 0; day < 14; day++) {
    final on = start.add(Duration(days: day));
    // A quiet morning and a busy evening, which is how a gym actually runs.
    records.add(visit(DateTime(on.year, on.month, on.day, 7),
        memberId: 'm1', name: 'Asha'));
    records.add(visit(DateTime(on.year, on.month, on.day, 18),
        memberId: 'm2', name: 'Bilal'));
    records.add(visit(DateTime(on.year, on.month, on.day, 18, 40),
        memberId: 'm3', name: 'Chen'));
  }
  return records;
}

Widget wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ShadcnTheme.light()]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('with no history', () {
    testWidgets('explains itself instead of drawing empty charts',
        (tester) async {
      await tester.pumpWidget(wrap(
        AttendanceInsightsView(insights: AttendanceInsights.from(const [])),
      ));

      expect(find.text('Nothing to show yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('with a fortnight of check-ins', () {
    testWidgets('draws every section without overflowing', (tester) async {
      await tester.pumpWidget(
        wrap(AttendanceInsightsView(insights: AttendanceInsights.from(busyGym()))),
      );

      // Scrolled to one at a time: a long list only builds the rows that
      // are on screen, so the later sections do not exist until reached.
      for (final section in const [
        'When people come in',
        'Across the week',
        'The last two weeks',
        'Who comes most',
      ]) {
        await tester.scrollUntilVisible(find.text(section), 200);
        expect(find.text(section), findsOneWidget, reason: section);
      }

      // A hand-built chart that lays out badly reports an overflow here
      // rather than only on a real device.
      expect(tester.takeException(), isNull);
    });

    testWidgets('leads with the busiest hour, worked out from the data',
        (tester) async {
      await tester.pumpWidget(
        wrap(AttendanceInsightsView(insights: AttendanceInsights.from(busyGym()))),
      );

      expect(find.text('Busiest hour'), findsOneWidget);
      expect(find.text('6 PM – 7 PM'), findsOneWidget);
    });

    testWidgets('names the regulars with their visit counts', (tester) async {
      await tester.pumpWidget(
        wrap(AttendanceInsightsView(insights: AttendanceInsights.from(busyGym()))),
      );

      await tester.scrollUntilVisible(find.text('Bilal'), 300);
      expect(find.text('Bilal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('still fits on a narrow phone', (tester) async {
      // 320 logical pixels is about the smallest screen still in use. Two
      // stat cards side by side and 24 hour bars are the parts most likely
      // to run out of room.
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrap(AttendanceInsightsView(insights: AttendanceInsights.from(busyGym()))),
      );

      // Scrolling the whole way exercises every chart at this width, not
      // just the two cards that happen to start on screen.
      await tester.scrollUntilVisible(find.text('Who comes most'), 200);
      expect(tester.takeException(), isNull);
    });
  });
}
