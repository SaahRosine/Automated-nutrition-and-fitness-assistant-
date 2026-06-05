import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _navItems = [
    _NavItem(label: 'Dashboard', icon: Icons.home_rounded, route: '/home'),
    _NavItem(label: 'Programs', icon: Icons.fitness_center_rounded, route: '/programs'),
    _NavItem(label: 'Stats', icon: Icons.show_chart_rounded, route: '/stats'),
    _NavItem(label: 'Profile', icon: Icons.person_rounded, route: '/profile'),
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(child: widget.child),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/plan'),
        elevation: 8,
        label: const Text('Start run', style: TextStyle(fontWeight: FontWeight.w700)),
        icon: const Icon(Icons.play_arrow_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: PhysicalModel(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          elevation: 8,
          shadowColor: Colors.black26,
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: theme.colorScheme.surface,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = index == _activeIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: isActive
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onBackground.withOpacity(0.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isActive
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.onBackground.withOpacity(0.4),
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
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
