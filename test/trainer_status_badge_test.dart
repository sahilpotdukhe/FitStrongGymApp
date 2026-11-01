import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TrainerModel _trainer({required bool isActive}) => TrainerModel(
      id: 't1',
      name: 'Ravi Deshmukh',
      mobileNumber: '7447332096',
      gender: 'Male',
      specialization: 'Strength',
      experienceYears: 4,
      photoUrl: '',
      joiningDate: DateTime(2024, 1, 1),
      shiftStart: '6:00 AM',
      shiftEnd: '2:00 PM',
      workingDays: const ['Mon', 'Tue'],
      salary: 20000,
      address: 'Pune',
      isActive: isActive,
    );

Widget _wrap(Widget child, {required bool dark}) {
  final shadcn = dark ? AppTheme.dark() : AppTheme.light();
  final base = ThemeData(brightness: dark ? Brightness.dark : Brightness.light);
  return MaterialApp(
    theme: AppTheme.materialOverrides(base, shadcn),
    home: Scaffold(body: child),
  );
}

Color _badgeTextColor(WidgetTester tester) {
  final span = tester
      .widget<RichText>(find.descendant(
        of: find.byType(ShadcnBadge),
        matching: find.byType(RichText),
      ))
      .text as TextSpan;
  return span.style!.color!;
}

void main() {
  // The trainer badge sets its own font size and weight. That must not wipe
  // out the status color underneath it, which is what made "Active" render as
  // plain black instead of the green that tells it apart from "Left".
  testWidgets('an active trainer reads in the success color in light mode',
      (tester) async {
    await tester.pumpWidget(_wrap(
      TrainerCard(trainer: _trainer(isActive: true), memberCount: 3),
      dark: false,
    ));
    expect(_badgeTextColor(tester), AppStatus.light.successForeground);
  });

  testWidgets('a trainer who left reads in the danger color in light mode',
      (tester) async {
    await tester.pumpWidget(_wrap(
      TrainerCard(trainer: _trainer(isActive: false), memberCount: 0),
      dark: false,
    ));
    expect(_badgeTextColor(tester), AppStatus.light.dangerForeground);
  });

  testWidgets('the same holds in dark mode', (tester) async {
    await tester.pumpWidget(_wrap(
      TrainerCard(trainer: _trainer(isActive: true), memberCount: 3),
      dark: true,
    ));
    expect(_badgeTextColor(tester), AppStatus.dark.successForeground);
  });
}
