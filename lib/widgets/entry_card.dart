import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../theme.dart';

class EntryCard extends StatelessWidget {
  final CaffeineEntry entry;
  const EntryCard({super.key, required this.entry});

  Color get _iconBg {
    switch (entry.type) {
      case DrinkType.tea: return AppColors.accent2_200;
      default: return AppColors.accent200;
    }
  }

  Color get _iconColor {
    switch (entry.type) {
      case DrinkType.tea: return AppColors.accent2_700;
      default: return AppColors.accent700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(entry.type.icon, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type.label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('h:mm a').format(entry.time)} · from ${entry.source}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: headingStyle(19, color: AppColors.accent800),
              text: '${entry.mg}',
              children: const [
                TextSpan(
                  text: ' mg',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
