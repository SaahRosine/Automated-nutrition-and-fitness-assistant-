import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_styles.dart';

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
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(child: widget.child),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/plan'),
        elevation: 12,
        backgroundColor: AppColors.secondary,
        label: const Text('Start run', style: TextStyle(fontWeight: FontWeight.w700)),
        icon: const Icon(Icons.play_arrow_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: PhysicalModel(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(28),
          elevation: 18,
          shadowColor: Colors.black54,
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: AppColors.darkSurface,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = index == _activeIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(index),
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 20, color: isActive ? AppColors.secondary : AppColors.white38),
                          const SizedBox(height: 1),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isActive ? AppColors.secondary : AppColors.white38,
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
