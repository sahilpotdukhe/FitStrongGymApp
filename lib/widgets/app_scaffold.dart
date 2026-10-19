import 'package:fitstrong_gym/src/custom_import.dart';

/// Page skeleton used by every screen: themed background, a [ShadcnAppBar]
/// under the status bar, and the body below it.
///
/// The kit's app bar is a normal widget rather than a `PreferredSizeWidget`,
/// so it can't go in `Scaffold.appBar`. Composing it here once keeps all the
/// screens identical instead of each one rebuilding the same Column.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    required this.body,
    this.floatingActionButton,
    this.bottomBar,
    this.showAppBar = true,
    this.padBody = false,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget body;
  final Widget? floatingActionButton;

  /// Pinned under the body — a save bar, a total, a primary action.
  final Widget? bottomBar;
  final bool showAppBar;

  /// Adds the standard page gutter around [body]. Lists keep this off and
  /// pad their own content so the scrollbar still reaches the screen edge.
  final bool padBody;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return Scaffold(
      backgroundColor: t.background,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        bottom: false,
        child: Column(
          // Stretch, so the app bar, the body and the bottom bar always fill
          // the screen width instead of shrinking to their content and
          // sitting in the middle.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showAppBar)
              ShadcnAppBar(
                title: title,
                titleWidget: titleWidget,
                actions: actions,
                leading: leading,
                automaticallyImplyLeading: automaticallyImplyLeading,
              ),
            Expanded(
              child: padBody
                  ? Padding(
                      padding: const EdgeInsets.all(ShadcnSpacing.lg),
                      child: body,
                    )
                  : body,
            ),
            if (bottomBar != null)
              Container(
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border(top: BorderSide(color: t.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(ShadcnSpacing.lg),
                    child: bottomBar,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
