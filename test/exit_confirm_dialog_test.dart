import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter_test/flutter_test.dart';

/// Back on the home screen used to close FitStrong outright, which is easy to
/// hit by accident one-handed. The question only counts if "Stay" really does
/// keep the app open, so both answers are checked here.
void main() {
  Widget wrap(void Function(bool) record) {
    final shadcn = AppTheme.light();
    return MaterialApp(
      theme: AppTheme.materialOverrides(ThemeData.light(), shadcn),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => record(await confirmExitApp(context)),
            child: const Text('press back'),
          ),
        ),
      ),
    );
  }

  testWidgets('asks before closing the app', (tester) async {
    await tester.pumpWidget(wrap((_) {}));

    await tester.tap(find.text('press back'));
    await tester.pumpAndSettle();

    expect(find.text('Do you really want to exit?'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
    expect(find.text('Stay'), findsOneWidget);
  });

  testWidgets('choosing Exit says yes, and closes the question',
      (tester) async {
    bool? answer;
    await tester.pumpWidget(wrap((value) => answer = value));

    await tester.tap(find.text('press back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(answer, isTrue);
    expect(find.text('Do you really want to exit?'), findsNothing);
  });

  testWidgets('choosing Stay keeps the app open', (tester) async {
    bool? answer;
    await tester.pumpWidget(wrap((value) => answer = value));

    await tester.tap(find.text('press back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();

    expect(answer, isFalse);
    expect(find.text('Do you really want to exit?'), findsNothing);
  });
}
