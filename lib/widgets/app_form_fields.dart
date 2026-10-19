import 'package:fitstrong_gym/src/custom_import.dart';

/// A tappable field that looks like a [ShadcnInput] but opens a picker
/// instead of a keyboard — dates, times, anything chosen from a sheet.
///
/// Date and time used to be plain buttons whose label changed, so an unset
/// date and a set one looked like different controls. This keeps the shape
/// of a form field either way.
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = 'Select',
    this.icon = Icons.calendar_today_rounded,
    this.errorText,
  });

  final String label;

  /// The chosen value, already formatted. Null shows [placeholder].
  final String? value;
  final VoidCallback onTap;
  final String placeholder;
  final IconData icon;
  final String? errorText;

  /// Closes the keyboard before the picker opens.
  ///
  /// Tapping a date or time field is not text entry, and this field cannot
  /// hold focus itself. Without this the text field the owner was typing in
  /// keeps focus underneath the dialog and gets it back when the dialog
  /// closes, so the keyboard springs up again and the form jumps back to
  /// the old field.
  ///
  /// It has to be the focused field's own node. Unfocusing the surrounding
  /// scope instead leaves the scope still remembering that field as its
  /// last focused child, and closing the dialog hands focus straight back
  /// to it — which looks exactly like no fix at all.
  void _openPicker(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final hasValue = value != null && value!.isNotEmpty;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: t.foreground,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _openPicker(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.md),
            decoration: BoxDecoration(
              color: t.background,
              borderRadius: BorderRadius.circular(t.radiusMd),
              border: Border.all(
                color: hasError ? t.destructive : t.input,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 17, color: t.mutedForeground),
                const ShadcnGap(ShadcnSpacing.sm),
                Expanded(
                  child: Text(
                    hasValue ? value! : placeholder,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasValue ? t.foreground : t.mutedForeground,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: t.mutedForeground,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(fontSize: 12.5, color: t.destructive),
          ),
        ],
      ],
    );
  }
}

/// Circular photo picker with a camera badge, used on the member and profile
/// forms. Tapping it opens a sheet to choose camera or gallery.
class AppPhotoPicker extends StatelessWidget {
  const AppPhotoPicker({
    super.key,
    required this.onPicked,
    this.localFile,
    this.imageUrl,
    this.size = 104,
    this.errorText,
  });

  /// Called with the chosen source once the sheet closes.
  final ValueChanged<ImageSource> onPicked;

  /// A freshly picked file, shown in preference to [imageUrl].
  final XFile? localFile;
  final String? imageUrl;
  final double size;
  final String? errorText;

  Future<void> _openSheet(BuildContext context) async {
    // Same reason as the picker field: the camera sheet is not text entry,
    // so the keyboard should not come back when it closes.
    FocusManager.instance.primaryFocus?.unfocus();
    final source = await showShadcnSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => ShadcnSheet(
        title: 'Add a photo',
        description: 'Take a new picture or choose one from this device.',
        content: Column(
          children: [
            ShadcnListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              subtitle: const Text('Use the camera'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ShadcnListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              subtitle: const Text('Pick an existing picture'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) onPicked(source);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final hasError = errorText != null;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _openSheet(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.muted,
                  border: Border.all(
                    color: hasError ? t.destructive : t.border,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: localFile != null
                    ? Image.file(File(localFile!.path), fit: BoxFit.cover)
                    : AppAvatar(
                        imageUrl,
                        size: size,
                        backgroundColor: t.muted,
                      ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.primary,
                    border: Border.all(color: t.background, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: t.primaryForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const ShadcnGap(ShadcnSpacing.sm),
          Text(
            errorText!,
            style: TextStyle(fontSize: 12.5, color: t.destructive),
          ),
        ],
      ],
    );
  }
}

/// Full-screen translucent blocker shown while a form is saving, so nothing
/// is tapped twice mid-upload.
///
/// Every page stacks this *beside* its scaffold rather than inside it, so
/// there is no Material above it in the tree. Without one, Flutter paints
/// its text with the yellow-and-black "missing Material" underline, so the
/// overlay supplies its own.
class AppSavingOverlay extends StatelessWidget {
  const AppSavingOverlay({super.key, this.message = 'Saving…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.45),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ShadcnSpacing.xl2,
                vertical: ShadcnSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: BorderRadius.circular(t.radiusXl),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: t.primary,
                    ),
                  ),
                  const ShadcnGap(ShadcnSpacing.md),
                  ShadcnText(message, variant: ShadcnTextVariant.small),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
