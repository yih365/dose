import 'package:flutter/material.dart';
import '../theme.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 56, 22, 0),
            child: Text('You', style: headingStyle(32)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: _ProfileRow(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: _StreakBanner(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            child: _StatsGrid(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: _SettingsSection(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.accent2_500,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('MR', style: headingStyle(24, color: Colors.white)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Maya Rivera',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            const Text(
              '@maya.brews',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neutral600),
            ),
            const SizedBox(height: 3),
            Row(
              children: const [
                Icon(Icons.email_outlined, size: 12, color: AppColors.neutral600),
                SizedBox(width: 5),
                Text(
                  'maya.rivera@gmail.com',
                  style: TextStyle(fontSize: 11.5, color: AppColors.neutral600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFFFE1D0), size: 30),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('12-day streak', style: headingStyle(26, color: Colors.white)),
              const SizedBox(height: 3),
              const Text(
                'Logged every day since Jul 6',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFFE1D0)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _StatTile(value: '214', unit: 'mg', label: 'Avg daily caffeine'),
        _StatTile(value: '2.8', unit: 'cups', label: 'Avg daily drinks'),
        _StatTile(value: '7.1', unit: 'hrs', label: 'Avg sleep this week'),
        _StatTile(value: '61', unit: 'bpm', label: 'Avg resting HR'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const _StatTile({required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: headingStyle(24, color: AppColors.accent800),
              text: value,
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.08 * 11,
            color: AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 10),
        _SettingRow(icon: Icons.tune, label: 'Daily caffeine limit', value: '400 mg'),
        _SettingRow(icon: Icons.bedtime_outlined, label: 'Sleep cutoff time', value: '2 PM'),
        _SettingRow(icon: Icons.watch_outlined, label: 'Pixel Watch', value: 'Connected'),
        _SettingRow(icon: Icons.notifications_outlined, label: 'Notifications', value: 'On'),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SettingRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(icon, color: AppColors.accent700, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neutral600),
        ),
      ),
    );
  }
}
