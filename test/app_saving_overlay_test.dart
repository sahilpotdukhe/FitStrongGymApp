import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every form page stacks [AppSavingOverlay] beside its scaffold, not inside
/// it. Text with no Material above it is painted with Flutter's yellow-and-
/// black "missing Material" underline, so the overlay has to carry its own.
void main() {
  Widget wrapAsPagesDo(Widget overlay) {
    final shadcn = AppTheme.light();
    return MaterialApp(
      theme: AppTheme.materialOverrides(ThemeData.light(), shadcn),
      home: Stack(
        children: [
          const Scaffold(body: SizedBox()),
          overlay,
        ],
      ),
    );
  }

  testWidgets('the saving message sits on a Material, so it has no yellow '
      'underline', (tester) async {
    await tester.pumpWidget(
      wrapAsPagesDo(const AppSavingOverlay(message: 'Saving profile…')),
    );

    final messageFinder = find.text('Saving profile…');
    expect(messageFinder, findsOneWidget);

    // The scaffold is a sibling, so the only Material that can be above the
    // message is the one the overlay supplies itself.
    expect(
      find.ancestor(of: messageFinder, matching: find.byType(Material)),
      findsWidgets,
    );
  });

  testWidgets('the overlay swallows taps meant for the form behind it',
      (tester) async {
    var tappedBehind = false;
    final shadcn = AppTheme.light();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.materialOverrides(ThemeData.light(), shadcn),
        home: Stack(
          children: [
            Scaffold(
              body: GestureDetector(
                onTap: () => tappedBehind = true,
                child: const SizedBox.expand(),
              ),
            ),
            const AppSavingOverlay(),
          ],
        ),
      ),
    );

    await tester.tapAt(const Offset(40, 40));
    await tester.pump();

    expect(tappedBehind, isFalse);
  });
}
