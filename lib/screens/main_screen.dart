import 'package:flutter/material.dart';
import 'package:nova_clock/screens/alarm_screen.dart';
import 'package:nova_clock/screens/clock_screen.dart';
import 'package:nova_clock/screens/focus_screen.dart';
import 'package:nova_clock/screens/settings_screen.dart';
import 'package:nova_clock/screens/stopwatch_screen.dart';
import 'package:nova_clock/screens/timer_screen.dart';
import 'package:nova_clock/screens/world_clock_screen.dart';
import 'package:nova_clock/widgets/glass_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for glass effect behind nav bar
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF16161A), // Deep Space
                  Color(0xFF242629), // Lighter Space
                  Color(0xFF7F5AF0), // Neon Purple accent
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Content
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: const [
              ClockScreen(),
              AlarmScreen(),
              FocusScreen(),
              TimerScreen(),
              StopwatchScreen(),
              WorldClockScreen(),
              SettingsScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 360;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: GlassContainer(
                height: isSmall ? 65 : 75,
                blur: 20,
                color: Theme.of(context).cardTheme.color?.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.watch_later_outlined, Icons.watch_later, 'Clock', 0, isSmall),
                    _buildNavItem(Icons.alarm_outlined, Icons.alarm, 'Alarm', 1, isSmall),
                    _buildNavItem(Icons.rocket_launch_outlined, Icons.rocket_launch, 'Focus', 2, isSmall),
                    _buildNavItem(Icons.timer_outlined, Icons.timer, 'Timer', 3, isSmall),
                    _buildNavItem(Icons.timer_10_outlined, Icons.timer_10, 'Stop', 4, isSmall),
                    _buildNavItem(Icons.public_outlined, Icons.public, 'World', 5, isSmall),
                    _buildNavItem(Icons.settings_outlined, Icons.settings, 'Settings', 6, isSmall),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutlined, IconData iconFilled, String label, int index, bool isSmall) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? iconFilled : iconOutlined,
                key: ValueKey<bool>(isSelected),
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.white.withOpacity(0.6),
                size: isSmall ? 22 : 26,
              ),
            ),
            if (isSelected && !isSmall) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}