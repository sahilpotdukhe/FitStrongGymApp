import 'package:flutter/material.dart';
import 'package:shadcn_kit/shadcn_kit.dart';

/// Brand colors and semantic status colors for FitStrong, expressed in
/// shadcn_kit's token model.
///
/// Every screen reads colors from here (via `ShadcnTheme.of(context)` or
/// `AppStatus.of(context)`) instead of hardcoding hex values, which is what
/// makes a single light/dark switch work app-wide.
class AppTheme {
  const AppTheme._();

  /// The FitStrong brand blue, carried over from the previous design.
  static const Color brand = Color(0xFF3957ED);

  /// Brand blue lifted for dark surfaces — the original is too dark to read
  /// as an accent against a near-black background.
  static const Color brandDark = Color(0xFF6B82F5);

  /// Corner radius for the whole app. Larger than shadcn's web default (8)
  /// because touch UIs read better with softer corners.
  static const double radius = 12;

  static ShadcnTheme light() => ShadcnTheme(
        background: const Color(0xFFFFFFFF),
        foreground: const Color(0xFF12152B),
        card: const Color(0xFFFFFFFF),
        cardForeground: const Color(0xFF12152B),
        popover: const Color(0xFFFFFFFF),
        popoverForeground: const Color(0xFF12152B),
        primary: brand,
        primaryForeground: const Color(0xFFFFFFFF),
        secondary: const Color(0xFFEDEFFE),
        secondaryForeground: const Color(0xFF22318F),
        muted: const Color(0xFFF4F5FB),
        mutedForeground: const Color(0xFF6B7190),
        // The old app's page background, kept as the accent tint so the redesign
        // still feels like the same product.
        accent: const Color(0xFFE9EAFC),
        accentForeground: const Color(0xFF2A3FB0),
        destructive: const Color(0xFFDC2626),
        destructiveForeground: const Color(0xFFFFFFFF),
        border: const Color(0xFFE3E5F0),
        input: const Color(0xFFE3E5F0),
        ring: brand,
        radius: radius,
      ).copyWith(appBar: _appBar, text: _text, toast: _toast);

  static ShadcnTheme dark() => ShadcnTheme(
        background: const Color(0xFF0B0D16),
        foreground: const Color(0xFFEDEFF7),
        card: const Color(0xFF141726),
        cardForeground: const Color(0xFFEDEFF7),
        popover: const Color(0xFF141726),
        popoverForeground: const Color(0xFFEDEFF7),
        primary: brandDark,
        primaryForeground: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF232845),
        secondaryForeground: const Color(0xFFE7EAF8),
        muted: const Color(0xFF1B1F31),
        mutedForeground: const Color(0xFF9BA2BF),
        accent: const Color(0xFF232845),
        accentForeground: const Color(0xFFE7EAF8),
        destructive: const Color(0xFFEF4444),
        destructiveForeground: const Color(0xFFFFFFFF),
        border: const Color(0xFF272C42),
        input: const Color(0xFF272C42),
        ring: brandDark,
        radius: radius,
      ).copyWith(appBar: _appBar, text: _text, toast: _toast);

  /// Flat app bars with a hairline divider — no Material elevation shadow,
  /// which is what gives the app its "web app" calmness.
  static const ShadcnAppBarStyle _appBar = ShadcnAppBarStyle(
    showDivider: true,
    titleStyle: ShadcnTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );

  static const ShadcnTextTheme _text = ShadcnTextTheme(
    h1: ShadcnTextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
    h2: ShadcnTextStyle(
        fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
    h3: ShadcnTextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
    h4: ShadcnTextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, height: 1.35),
  );

  static const ShadcnToastStyle _toast = ShadcnToastStyle(
    duration: Duration(seconds: 3),
  );

  /// Material-level fallbacks for the Flutter widgets the app still uses
  /// directly (pickers, snackbars, scrollbars), so they match the tokens
  /// rather than Material's default purple.
  static ThemeData materialOverrides(ThemeData base, ShadcnTheme s) {
    final isDark = base.brightness == Brightness.dark;
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        brightness: base.brightness,
      ).copyWith(
        primary: s.primary,
        onPrimary: s.primaryForeground,
        surface: s.card,
        onSurface: s.cardForeground,
        error: s.destructive,
        onError: s.destructiveForeground,
      ),
      scaffoldBackgroundColor: s.background,
      dividerColor: s.border,
      splashFactory: InkRipple.splashFactory,
      progressIndicatorTheme: ProgressIndicatorThemeData(color: s.primary),
      iconTheme: IconThemeData(color: s.foreground),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: s.primary,
        selectionColor: s.primary.withValues(alpha: 0.25),
        selectionHandleColor: s.primary,
      ),
      extensions: [s, isDark ? AppStatus.dark : AppStatus.light],
    );
  }
}

/// Status colors that shadcn's token set has no slot for, but a gym app needs
/// constantly: a membership is active, expiring soon, or expired.
///
/// Kept as a [ThemeExtension] so it flips with light/dark exactly like the
/// shadcn tokens do.
@immutable
class AppStatus extends ThemeExtension<AppStatus> {
  const AppStatus({
    required this.success,
    required this.successSurface,
    required this.successForeground,
    required this.warning,
    required this.warningSurface,
    required this.warningForeground,
    required this.danger,
    required this.dangerSurface,
    required this.dangerForeground,
    required this.info,
    required this.infoSurface,
    required this.infoForeground,
  });

  /// Active membership, paid invoice, present attendance.
  final Color success;
  final Color successSurface;
  final Color successForeground;

  /// Membership expiring soon, payment due.
  final Color warning;
  final Color warningSurface;
  final Color warningForeground;

  /// Expired membership, overdue payment, deleted record.
  final Color danger;
  final Color dangerSurface;
  final Color dangerForeground;

  /// Neutral highlights — counts, totals, informational chips.
  final Color info;
  final Color infoSurface;
  final Color infoForeground;

  static const AppStatus light = AppStatus(
    success: Color(0xFF16A34A),
    successSurface: Color(0xFFE8F7EE),
    successForeground: Color(0xFF14532D),
    warning: Color(0xFFD97706),
    warningSurface: Color(0xFFFEF3E2),
    warningForeground: Color(0xFF7C2D12),
    danger: Color(0xFFDC2626),
    dangerSurface: Color(0xFFFDECEC),
    dangerForeground: Color(0xFF7F1D1D),
    info: AppTheme.brand,
    infoSurface: Color(0xFFEDEFFE),
    infoForeground: Color(0xFF22318F),
  );

  static const AppStatus dark = AppStatus(
    success: Color(0xFF4ADE80),
    successSurface: Color(0xFF14321F),
    successForeground: Color(0xFFBBF7D0),
    warning: Color(0xFFFBBF24),
    warningSurface: Color(0xFF3A2A10),
    warningForeground: Color(0xFFFDE68A),
    danger: Color(0xFFF87171),
    dangerSurface: Color(0xFF3B1A1A),
    dangerForeground: Color(0xFFFECACA),
    info: AppTheme.brandDark,
    infoSurface: Color(0xFF232845),
    infoForeground: Color(0xFFC7D0FA),
  );

  static AppStatus of(BuildContext context) =>
      Theme.of(context).extension<AppStatus>() ?? light;

  @override
  AppStatus copyWith({
    Color? success,
    Color? successSurface,
    Color? successForeground,
    Color? warning,
    Color? warningSurface,
    Color? warningForeground,
    Color? danger,
    Color? dangerSurface,
    Color? dangerForeground,
    Color? info,
    Color? infoSurface,
    Color? infoForeground,
  }) =>
      AppStatus(
        success: success ?? this.success,
        successSurface: successSurface ?? this.successSurface,
        successForeground: successForeground ?? this.successForeground,
        warning: warning ?? this.warning,
        warningSurface: warningSurface ?? this.warningSurface,
        warningForeground: warningForeground ?? this.warningForeground,
        danger: danger ?? this.danger,
        dangerSurface: dangerSurface ?? this.dangerSurface,
        dangerForeground: dangerForeground ?? this.dangerForeground,
        info: info ?? this.info,
        infoSurface: infoSurface ?? this.infoSurface,
        infoForeground: infoForeground ?? this.infoForeground,
      );

  @override
  AppStatus lerp(ThemeExtension<AppStatus>? other, double t) {
    if (other is! AppStatus) return this;
    return AppStatus(
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      successForeground:
          Color.lerp(successForeground, other.successForeground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      warningForeground:
          Color.lerp(warningForeground, other.warningForeground, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      dangerForeground:
          Color.lerp(dangerForeground, other.dangerForeground, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
    );
  }
}

/// Shorthand so screens can write `context.status.success` next to the kit's
/// own `context.shadcn.primary`.
extension AppStatusContext on BuildContext {
  AppStatus get status => AppStatus.of(this);
}
