import 'package:flutter/material.dart';
import 'package:shadcn_kit/shadcn_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the user's light/dark choice between launches.
///
/// Without this the app would snap back to following the system theme on
/// every cold start, which reads as a bug to anyone who deliberately picked
/// one mode.
class ThemeModeStore {
  const ThemeModeStore._();

  static const String _key = 'theme_mode';

  /// Reads the saved mode. Falls back to following the system when nothing
  /// is stored yet, or when storage is unavailable — a failed preference
  /// read should never stop the app from starting.
  static Future<ThemeMode> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return switch (prefs.getString(_key)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      return ThemeMode.system;
    }
  }

  static Future<void> save(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // A theme preference that fails to persist is not worth surfacing to
      // the user; the app still honours the choice for this session.
    }
  }
}

/// Toggles light/dark and persists the result. Drop this in an app bar's
/// `actions` or a settings list.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ShadcnThemeController.of(context);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = controller.mode == ThemeMode.system
        ? platformBrightness == Brightness.dark
        : controller.mode == ThemeMode.dark;

    return ShadcnButton(
      variant: ShadcnButtonVariant.ghost,
      size: ShadcnButtonSize.icon,
      onPressed: () {
        controller.toggle(platformBrightness: platformBrightness);
        ThemeModeStore.save(controller.mode);
      },
      child: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        size: 20,
      ),
    );
  }
}
