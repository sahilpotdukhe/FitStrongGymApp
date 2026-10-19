import 'package:fitstrong_gym/src/custom_import.dart';

/// Full-surface loading state. Sits on the themed background rather than a
/// hardcoded white box, so it no longer flashes bright in dark mode.
class Loading extends StatelessWidget {
  const Loading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: t.primary,
              ),
            ),
            if (message != null) ...[
              const ShadcnGap(ShadcnSpacing.md),
              ShadcnText(message!, variant: ShadcnTextVariant.muted),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline spinner for buttons, list footers and refresh states, where a
/// full-screen [Loading] would be too heavy.
class InlineLoading extends StatelessWidget {
  const InlineLoading({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.shadcn.primary,
      ),
    );
  }
}

/// Placeholder list used while member/plan data is still loading. Showing the
/// shape of the content that is coming feels faster than a lone spinner.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ListView.separated(
      padding: const EdgeInsets.all(ShadcnSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const ShadcnGap(ShadcnSpacing.md),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(ShadcnSpacing.lg),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(t.radiusXl),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            const ShadcnSkeleton.circle(size: 48),
            const ShadcnGap(ShadcnSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShadcnSkeleton(height: 14, width: 140),
                  ShadcnGap(ShadcnSpacing.sm),
                  ShadcnSkeleton(height: 12, width: 90),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
