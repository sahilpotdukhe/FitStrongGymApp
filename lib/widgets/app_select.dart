import 'package:fitstrong_gym/src/custom_import.dart';

/// The kit's dropdown, with one addition: tapping it puts the keyboard away.
///
/// The dropdown opens in a layer floating above the page rather than as a
/// new screen, so the text field the owner was typing in never loses focus
/// on its own — the keyboard stays up behind the list and is still there
/// (with the old field selected) once a choice is made. Dropping focus on
/// the way in fixes that, and doing it here means every dropdown in the app
/// behaves the same without touching the pinned kit.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
  });

  final List<ShadcnSelectItem<T>> items;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? placeholder;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool enabled;

  /// Forwarded so a dropdown inside a [Form] is still validated on save.
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;
  final FormFieldSetter<T>? onSaved;

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Pointer down reaches this wrapper before the dropdown handles the
      // tap, so the keyboard is already on its way out when the list opens.
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: ShadcnSelect<T>(
        items: items,
        value: value,
        onChanged: onChanged,
        placeholder: placeholder,
        label: label,
        helperText: helperText,
        errorText: errorText,
        enabled: enabled,
        validator: validator,
        autovalidateMode: autovalidateMode,
        onSaved: onSaved,
      ),
    );
  }
}
