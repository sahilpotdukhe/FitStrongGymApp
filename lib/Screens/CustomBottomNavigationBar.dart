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
  int page = 2;

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
    return Scaffold(
      backgroundColor: t.background,
      body: getPage(page),
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
                      onTap: () => setState(() => page = i),
                    ),
                  ),
              ],
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
