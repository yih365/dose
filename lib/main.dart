import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';
import 'screens/log_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/you_screen.dart';
import 'widgets/add_log_sheet.dart';

void main() {
  runApp(const DoseApp());
}

class DoseApp extends StatelessWidget {
  const DoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dose',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  final List<CaffeineEntry> _entries = List.from(sampleEntries);

  void _showAddLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddLogSheet(
          onAdd: (entry) => setState(() => _entries.add(entry)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      LogScreen(entries: _entries),
      CompareScreen(weekData: sampleWeekData),
      const YouScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLog,
        backgroundColor: AppColors.accent,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(84, 0, 16, 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.coffee_maker_outlined,
                activeIcon: Icons.coffee_maker,
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                active: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          active ? activeIcon : icon,
          color: active ? AppColors.accent : AppColors.neutral500,
          size: 24,
        ),
      ),
    );
  }
}
