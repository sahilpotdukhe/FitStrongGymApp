import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tapping a date or time field must put the keyboard away.
///
/// The field cannot hold focus itself, so without this the text field the
/// owner was typing in keeps focus behind the picker dialog and takes it
/// back when the dialog closes — the keyboard springs up and the form jumps
/// back to the old field.
void main() {
  Widget wrap(Widget child) {
    final shadcn = AppTheme.light();
    return MaterialApp(
      theme: AppTheme.materialOverrides(ThemeData.light(), shadcn),
      home: Scaffold(
        body: Column(
          children: [
            const TextField(key: Key('name')),
            child,
          ],
        ),
      ),
    );
  }

  testWidgets('tapping a picker field drops focus from the text field',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrap(
        AppPickerField(
          label: 'Date of birth',
          value: null,
          onTap: () => tapped = true,
        ),
      ),
    );

    // The owner is typing in the field above the picker.
    await tester.tap(find.byKey(const Key('name')));
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.hasFocus,
      isTrue,
      reason: 'the text field should hold focus before the picker is opened',
    );

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue, reason: 'the picker should still open');
    final textFieldFocused = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;
    expect(
      textFieldFocused,
      isFalse,
      reason: 'the text field must not keep focus behind the picker',
    );
  });

  testWidgets('tapping a dropdown drops focus from the text field',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        AppSelect<String>(
          label: 'Plan',
          placeholder: 'Pick a plan',
          value: null,
          items: const [
            ShadcnSelectItem(value: 'monthly', label: 'Monthly'),
          ],
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('name')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pick a plan'));
    await tester.pumpAndSettle();

    final textFieldFocused = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;
    expect(
      textFieldFocused,
      isFalse,
      reason: 'the dropdown floats over the page, so the text field would '
          'otherwise keep focus and the keyboard would stay up',
    );
  });

  testWidgets('focus does not come back after a dialog closes',
      (tester) async {
    final shadcn = AppTheme.light();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.materialOverrides(ThemeData.light(), shadcn),
        home: Scaffold(
          body: Column(
            children: [
              const TextField(key: Key('address')),
              Builder(
                builder: (context) => AppPickerField(
                  label: 'Joining date',
                  value: null,
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      content: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Pick'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Typing in the address field.
    await tester.tap(find.byKey(const Key('address')));
    await tester.pumpAndSettle();

    // Open the picker and choose something.
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();

    final addressFocused = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;
    expect(
      addressFocused,
      isFalse,
      reason: 'closing the picker must not hand focus back to the address '
          'field, or the keyboard springs up again',
    );
  });
}
