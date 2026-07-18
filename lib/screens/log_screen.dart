import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/entry_card.dart';

class LogScreen extends StatelessWidget {
  final List<CaffeineEntry> entries;
  const LogScreen({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final totalMg = entries.fold(0, (sum, e) => sum + e.mg);
    const limitMg = 400;
    final progress = (totalMg / limitMg).clamp(0.0, 1.0);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 56, 22, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today', style: headingStyle(34)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _Avatar(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: _RingCard(
              totalMg: totalMg,
              limitMg: limitMg,
              progress: progress,
              entries: entries,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 22, 26, 10),
            child: Text(
              'TODAY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.08 * 11,
                color: AppColors.neutral500,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
              child: EntryCard(entry: entries[i]),
            ),
            childCount: entries.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accent2_500,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'MR',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _RingCard extends StatelessWidget {
  final int totalMg;
  final int limitMg;
  final double progress;
  final List<CaffeineEntry> entries;

  const _RingCard({
    required this.totalMg,
    required this.limitMg,
    required this.progress,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = limitMg - totalMg;
    final lastEntry = entries.isNotEmpty ? entries.last : null;
    final lastTime = lastEntry != null ? DateFormat('h:mm a').format(lastEntry.time) : '--';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: AppColors.accent200,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$totalMg', style: headingStyle(28, color: AppColors.accent800)),
                    Text(
                      'of $limitMg mg',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remaining > 100 ? 'Nicely paced' : remaining > 0 ? 'Almost at limit' : 'Limit reached',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$remaining mg under your limit. Last dose $lastTime.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Stat(value: '${entries.length}', label: 'drinks'),
                    Container(
                      width: 1,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: AppColors.divider,
                    ),
                    _Stat(
                      value: entries.isNotEmpty
                          ? DateFormat('H:mm').format(entries.first.time)
                          : '--',
                      label: 'first cup',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: headingStyle(19)),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}
