// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'dashboard_home.dart';
import 'profile_screen.dart';
import 'setting_page.dart';
import 'add_expense_screen.dart';
import 'transactions_screen.dart';
import 'set_budget_screen.dart';
import 'savings_feature_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const AddExpenseScreen(),
    const TransactionsScreen(),
    const SetBudgetScreen(),
    const SavingsFeatureScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  void navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  index: 0,
                  isSelected: _currentIndex == 0,
                  onTap: () => navigateToScreen(0),
                ),
                _buildNavItem(
                  icon: Icons.analytics_rounded,
                  label: 'Analytics',
                  index: 5,
                  isSelected: _currentIndex == 5,
                  onTap: () => navigateToScreen(5),
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 6,
                  isSelected: _currentIndex == 6,
                  onTap: () => navigateToScreen(6),
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  index: 7,
                  isSelected: _currentIndex == 7,
                  onTap: () => navigateToScreen(7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: _HoverableNavItem(
        icon: icon,
        label: label,
        isSelected: isSelected,
        onTap: onTap,
      ),
    );
  }
}

class _HoverableNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverableNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<_HoverableNavItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hover background effect
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isHovered || widget.isSelected ? 45 : 0,
                    height: _isHovered || widget.isSelected ? 45 : 0,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? Colors.white.withOpacity(0.2)
                          : widget.isSelected
                              ? Colors.white.withOpacity(0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: _isHovered
                          ? Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            )
                          : null,
                    ),
                  ),

                  // Icon and label
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          size: widget.isSelected ? 24 : 22,
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontSize: widget.isSelected ? 11 : 10,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          child: Text(widget.label),
                        ),
                      ],
                    ),
                  ),

                  // Ripple effect on tap
                  if (_isHovered)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _opacityAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(
                                      0.1 * _opacityAnimation.value),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
