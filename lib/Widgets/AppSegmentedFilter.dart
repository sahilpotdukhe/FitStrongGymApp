import 'package:fitstrong_gym/src/custom_import.dart';

/// One choice in an [AppSegmentedFilter].
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.count});

  final T value;
  final String label;

  /// Optional number shown beside the label, e.g. how many members match.
  final int? count;
}

/// A segmented switch styled like the kit's tab list, for pages whose body is
/// a full-height scrolling list.
///
/// The kit's own [ShadcnTabs] keeps its content inline and unbounded, which a
/// page-filling `ListView` can't live in — so the list screens use this for
/// the control and own their scroll view.
class AppSegmentedFilter<T> extends StatelessWidget {
  const AppSegmentedFilter({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<AppSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.muted,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: _Segment(
                segment: segment,
                selected: segment.value == value,
                onTap: () => onChanged(segment.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final AppSegment<T> segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? t.background : Colors.transparent,
            borderRadius: BorderRadius.circular(t.radiusSm),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  segment.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? t.foreground : t.mutedForeground,
                  ),
                ),
              ),
              if (segment.count != null) ...[
                const SizedBox(width: 6),
                Text(
                  '${segment.count}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? t.primary : t.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The shared body of every member list: pull to refresh, consistent padding,
/// and one empty state.
class MemberListView extends StatelessWidget {
  const MemberListView({
    super.key,
    required this.members,
    required this.empty,
    this.onRefresh,
    this.header,
  });

  final List<MemberModel> members;
  final Widget empty;
  final Future<void> Function()? onRefresh;

  /// Pinned above the list and scrolled with it — filters, counts, hints.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    final Widget body = members.isEmpty
        ? empty
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              ShadcnSpacing.lg,
              ShadcnSpacing.md,
              ShadcnSpacing.lg,
              ShadcnSpacing.xl4,
            ),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return MemberCard(
                member: member,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemberDetailsPage(member: member),
                  ),
                ),
              );
            },
          );

    final Widget content = header == null
        ? body
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ShadcnSpacing.lg,
                  ShadcnSpacing.md,
                  ShadcnSpacing.lg,
                  0,
                ),
                child: header!,
              ),
              Expanded(child: body),
            ],
          );

    if (onRefresh == null) return content;
    return RefreshIndicator(
      color: t.primary,
      backgroundColor: t.card,
      onRefresh: onRefresh!,
      child: content,
    );
  }
}
