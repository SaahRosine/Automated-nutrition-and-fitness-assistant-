import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _navItems = [
    _NavItem(label: 'Sessions', icon: Icons.fitness_center, route: '/home'),
    _NavItem(label: 'Stats', icon: Icons.show_chart, route: '/stats'),
    _NavItem(label: 'Profile', icon: Icons.person, route: '/profile'),
  ];

  int _activeIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).location;
    _activeIndex = _navItems.indexWhere((item) => item.route == location);
    if (_activeIndex == -1) _activeIndex = 0;
  }

  void _onTap(int index) {
    if (_activeIndex == index) return;
    setState(() => _activeIndex = index);
    context.go(_navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Sessions'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem({required this.label, required this.icon, required this.route});
}