import 'package:fitstrong_gym/src/custom_import.dart';

/// Shared chrome for the sign-in and sign-up screens: themed background,
/// brand mark, heading, and a centered column that stays readable on a
/// tablet instead of stretching edge to edge.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: ShadcnSpacing.xl2,
              vertical: ShadcnSpacing.xl3,
            ),
            child: ConstrainedBox(
              // Login forms become hard to scan when the fields run the full
              // width of a tablet, so the column is capped.
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppBrandMark()),
                  const ShadcnGap(ShadcnSpacing.xl2),
                  ShadcnText(title, variant: ShadcnTextVariant.h1),
                  const ShadcnGap(ShadcnSpacing.sm),
                  ShadcnText(subtitle, variant: ShadcnTextVariant.muted),
                  const ShadcnGap(ShadcnSpacing.xl2),
                  child,
                  if (footer != null) ...[
                    const ShadcnGap(ShadcnSpacing.xl2),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The app's logo lockup for themed surfaces.
///
/// The PNG logo has a dark photographic background baked in, so it can only
/// be used on the black splash screen. Everywhere else the brand is drawn
/// from theme tokens, which keeps it crisp and correct in both modes.
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 64, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [t.primary, Color.lerp(t.primary, Colors.black, 0.25)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.32),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: t.primaryForeground,
            size: size * 0.5,
          ),
        ),
        if (showWordmark) ...[
          const ShadcnGap(ShadcnSpacing.md),
          Text(
            'FITSTRONG',
            style: TextStyle(
              color: t.foreground,
              fontSize: size * 0.26,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
        ],
      ],
    );
  }
}
