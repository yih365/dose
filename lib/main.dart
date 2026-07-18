import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';
import 'screens/log_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/you_screen.dart';
import 'widgets/add_log_sheet.dart';
import 'services/watch_bridge.dart';

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

  @override
  void initState() {
    super.initState();
    // Listen for caffeine logs logged from the Pixel Watch
    WatchBridge.watchLogs.listen(_onWatchLog);
  }

  void _onWatchLog(Map<String, dynamic> event) {
    final type = DrinkType.values.firstWhere(
      (t) => t.name == event['type'],
      orElse: () => DrinkType.custom,
    );
    final entry = CaffeineEntry(
      type: type,
      mg: event['mg'] as int,
      time: DateTime.now(),
      source: 'Watch',
    );
    setState(() => _entries.add(entry));
    _syncWatchTotal();
  }

  void _syncWatchTotal() {
    final total = _entries.fold(0, (s, e) => s + e.mg);
    WatchBridge.pushDailyTotal(totalMg: total, limitMg: 400);
  }

  void _showAddLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddLogSheet(
          onAdd: (entry) {
            setState(() => _entries.add(entry));
            _syncWatchTotal();
          },
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
      bottomNavigationBar: _BottomBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        onAdd: _showAddLog,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;
  const _BottomBar({required this.currentIndex, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
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
          ],
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
