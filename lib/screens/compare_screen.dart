import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

enum _Metric { caffeine, heartRate, sleep }

class CompareScreen extends StatefulWidget {
  final List<DayData> weekData;
  const CompareScreen({super.key, required this.weekData});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  bool _weekSelected = true;
  final _active = {_Metric.caffeine, _Metric.heartRate, _Metric.sleep};

  @override
  Widget build(BuildContext context) {
    final days = widget.weekData;
    final maxCaff = days.map((d) => d.caffeineMg).reduce((a, b) => a > b ? a : b).toDouble();
    final maxHr = days.map((d) => d.restingHr).reduce((a, b) => a > b ? a : b);
    final maxSleep = days.map((d) => d.sleepHrs).reduce((a, b) => a > b ? a : b);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 56, 22, 0),
            child: Text('Compare', style: headingStyle(32)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: _SegmentedControl(
              weekSelected: _weekSelected,
              onChanged: (v) => setState(() => _weekSelected = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: _MetricChips(
              active: _active,
              onToggle: (m) => setState(() {
                if (_active.contains(m)) {
                  if (_active.length > 1) _active.remove(m);
                } else {
                  _active.add(m);
                }
              }),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: _OverlayChartCard(
              days: days,
              active: _active,
              maxCaff: maxCaff,
              maxHr: maxHr,
              maxSleep: maxSleep,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            child: _InsightCard(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final bool weekSelected;
  final ValueChanged<bool> onChanged;
  const _SegmentedControl({required this.weekSelected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Seg(label: 'Week', selected: weekSelected, onTap: () => onChanged(true)),
          _Seg(label: 'Month', selected: !weekSelected, onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Seg({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.neutral600,
          ),
        ),
      ),
    );
  }
}

class _MetricChips extends StatelessWidget {
  final Set<_Metric> active;
  final ValueChanged<_Metric> onToggle;
  const _MetricChips({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final chips = [
      (_Metric.caffeine, 'Caffeine', Icons.coffee_maker, AppColors.accent),
      (_Metric.heartRate, 'Heart rate', Icons.favorite, AppColors.heartRed),
      (_Metric.sleep, 'Sleep', Icons.nightlight_round, AppColors.sleepBlue),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((c) {
        final (metric, label, icon, color) = c;
        final isOn = active.contains(metric);
        return GestureDetector(
          onTap: () => onToggle(metric),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOn ? color : Colors.transparent,
              border: isOn ? null : Border.all(color: AppColors.neutral400, width: 1.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: isOn ? Colors.white : AppColors.neutral600),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isOn ? Colors.white : AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OverlayChartCard extends StatelessWidget {
  final List<DayData> days;
  final Set<_Metric> active;
  final double maxCaff;
  final double maxHr;
  final double maxSleep;

  const _OverlayChartCard({
    required this.days,
    required this.active,
    required this.maxCaff,
    required this.maxHr,
    required this.maxSleep,
  });

  List<FlSpot> _spots(double Function(DayData) fn, double max) => List.generate(
    days.length,
    (i) => FlSpot(i.toDouble(), fn(days[i]) / max),
  );

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final lines = <LineChartBarData>[];

    if (active.contains(_Metric.caffeine)) {
      lines.add(LineChartBarData(
        spots: _spots((d) => d.caffeineMg.toDouble(), maxCaff),
        color: AppColors.accent,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.accent200.withValues(alpha: 0.7),
        ),
      ));
    }
    if (active.contains(_Metric.heartRate)) {
      lines.add(LineChartBarData(
        spots: _spots((d) => d.restingHr, maxHr),
        color: AppColors.heartRed,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
      ));
    }
    if (active.contains(_Metric.sleep)) {
      lines.add(LineChartBarData(
        spots: _spots((d) => d.sleepHrs, maxSleep),
        color: AppColors.sleepBlue,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
        dashArray: [4, 8],
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      child: SizedBox(
        height: 150,
        child: LineChart(
          LineChartData(
            lineBarsData: lines,
            minY: 0,
            maxY: 1.1,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.5,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: AppColors.neutral300,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (val, _) {
                    final i = val.toInt();
                    if (i < 0 || i >= dayLabels.length) return const SizedBox.shrink();
                    return Text(
                      dayLabels[i],
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral500,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent2_100,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.accent2_700, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: AppColors.accent2_900,
                ),
                children: [
                  TextSpan(text: 'On your '),
                  TextSpan(
                    text: '300 mg+ days',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ', resting heart rate ran '),
                  TextSpan(
                    text: '+7 bpm',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' and sleep dropped '),
                  TextSpan(
                    text: '1.3 hrs',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
