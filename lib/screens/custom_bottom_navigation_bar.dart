import 'package:fitstrong_gym/src/custom_import.dart';

/// The app shell: five destinations with a flat, token-driven bottom bar.
///
/// Replaces `curved_navigation_bar`, whose notch forced a fixed white bar and
/// gave the selected tab no label — you had to recognise the icon. Each
/// destination now shows its name, and the bar follows the theme.
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  /// The dashboard's slot in [_destinations] — where the app opens, and the
  /// only tab where back means "close FitStrong".
  static const int _homeIndex = 2;

  int page = _homeIndex;

  /// Which tabs have been opened at least once.
  ///
  /// The five destinations live in an [IndexedStack] so that leaving a tab
  /// and coming back keeps it exactly as it was. The previous `body:
  /// getPage(page)` threw the old tab away and built the new one from
  /// scratch on every tap, so returning to the dashboard re-ran its four
  /// Firestore queries and rebuilt the whole page -- which is what made the
  /// home screen visibly blink and lose its scroll position.
  ///
  /// Only visited tabs are built, so opening the app still costs one page
  /// rather than five.
  final Set<int> _visited = {_homeIndex};

  /// What the back gesture does from the app shell.
  ///
  /// This only runs while the shell is the top route: a pushed page such as
  /// member details handles its own back, so the question is never asked over
  /// a nested screen.
  ///
  /// From another tab, back means "take me home" — the familiar Android
  /// behaviour, and the reason the question is not asked there. From home
  /// there is nowhere left to go, so it asks before closing.
  Future<void> _handleBack(bool didPop, Object? result) async {
    if (didPop) return;

    if (page != _homeIndex) {
      setState(() => page = _homeIndex);
      return;
    }

    final leave = await confirmExitApp(context);
    if (leave && mounted) await SystemNavigator.pop();
  }

  static const List<_Destination> _destinations = [
    _Destination(
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
      label: 'Attendance',
    ),
    _Destination(
      icon: Icons.person_add_alt_outlined,
      activeIcon: Icons.person_add_alt_1_rounded,
      label: 'Add',
    ),
    _Destination(
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      label: 'Home',
    ),
    _Destination(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      label: 'Members',
    ),
    _Destination(
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      label: 'Menu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return PopScope(
      // Back is never let through untouched: it either returns to the home
      // tab or asks before closing the app.
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: Scaffold(
        backgroundColor: t.background,
        body: IndexedStack(
          index: page,
          sizing: StackFit.expand,
          children: [
            for (var i = 0; i < _destinations.length; i++)
              if (_visited.contains(i))
                getPage(i)
              else
                const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: t.card,
            border: Border(top: BorderSide(color: t.border)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  for (var i = 0; i < _destinations.length; i++)
                    Expanded(
                      child: _NavItem(
                        destination: _destinations[i],
                        selected: page == i,
                        onTap: () => setState(() {
                          page = i;
                          _visited.add(i);
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    final color = selected ? t.primary : t.mutedForeground;

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        // The whole column is the tap target, so the bar stays easy to hit
        // one-handed even though the icon itself is small.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? t.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                selected ? destination.activeIcon : destination.icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 11,
                height: 1,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getPage(int page) {
  switch (page) {
    case 0:
      return AttendancePage();
    case 1:
      return AddMemberPage();
    case 3:
      return DisplayAllMembers();
    case 4:
      return MenuPage();
    case 2:
    default:
      // Anything unexpected lands on the dashboard rather than a blank screen,
      // which is what the old `switch` with no default returned.
      return DashBoard();
  }
}
