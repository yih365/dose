import 'package:flutter/material.dart';

enum DrinkType { espresso, coffee, tea, energyDrink, custom }

extension DrinkTypeExt on DrinkType {
  String get label {
    switch (this) {
      case DrinkType.espresso: return 'Espresso';
      case DrinkType.coffee: return 'Drip coffee';
      case DrinkType.tea: return 'Green tea';
      case DrinkType.energyDrink: return 'Energy drink';
      case DrinkType.custom: return 'Custom';
    }
  }

  int get defaultMg {
    switch (this) {
      case DrinkType.espresso: return 63;
      case DrinkType.coffee: return 96;
      case DrinkType.tea: return 28;
      case DrinkType.energyDrink: return 160;
      case DrinkType.custom: return 0;
    }
  }

  IconData get icon {
    switch (this) {
      case DrinkType.espresso: return Icons.coffee;
      case DrinkType.coffee: return Icons.coffee_maker;
      case DrinkType.tea: return Icons.eco;
      case DrinkType.energyDrink: return Icons.bolt;
      case DrinkType.custom: return Icons.add_circle_outline;
    }
  }
}

class CaffeineEntry {
  final DrinkType type;
  final int mg;
  final DateTime time;
  final String source;

  const CaffeineEntry({
    required this.type,
    required this.mg,
    required this.time,
    this.source = 'Phone',
  });
}

class DayData {
  final DateTime date;
  final int caffeineMg;
  final double restingHr;
  final double sleepHrs;

  const DayData({
    required this.date,
    required this.caffeineMg,
    required this.restingHr,
    required this.sleepHrs,
  });
}

// Sample data
final sampleEntries = [
  CaffeineEntry(type: DrinkType.espresso, mg: 63, time: DateTime(2026, 7, 18, 7, 10), source: 'Watch'),
  CaffeineEntry(type: DrinkType.coffee, mg: 96, time: DateTime(2026, 7, 18, 9, 30), source: 'Phone'),
  CaffeineEntry(type: DrinkType.tea, mg: 28, time: DateTime(2026, 7, 18, 13, 15), source: 'Phone'),
];

final sampleWeekData = [
  DayData(date: DateTime(2026, 7, 12), caffeineMg: 220, restingHr: 62, sleepHrs: 7.2),
  DayData(date: DateTime(2026, 7, 13), caffeineMg: 190, restingHr: 61, sleepHrs: 7.8),
  DayData(date: DateTime(2026, 7, 14), caffeineMg: 340, restingHr: 68, sleepHrs: 6.2),
  DayData(date: DateTime(2026, 7, 15), caffeineMg: 150, restingHr: 59, sleepHrs: 8.1),
  DayData(date: DateTime(2026, 7, 16), caffeineMg: 310, restingHr: 65, sleepHrs: 6.8),
  DayData(date: DateTime(2026, 7, 17), caffeineMg: 130, restingHr: 58, sleepHrs: 8.4),
  DayData(date: DateTime(2026, 7, 18), caffeineMg: 187, restingHr: 61, sleepHrs: 7.5),
];
