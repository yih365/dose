import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

class AddLogSheet extends StatefulWidget {
  final void Function(CaffeineEntry) onAdd;
  const AddLogSheet({super.key, required this.onAdd});

  @override
  State<AddLogSheet> createState() => _AddLogSheetState();
}

class _AddLogSheetState extends State<AddLogSheet> {
  DrinkType? _selected;
  int _customMg = 75;

  static const _presets = [
    DrinkType.espresso,
    DrinkType.coffee,
    DrinkType.tea,
    DrinkType.energyDrink,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral400,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Log caffeine', style: headingStyle(24)),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _presets.map((type) {
              final isSelected = _selected == type;
              return GestureDetector(
                onTap: () => setState(() => _selected = isSelected ? null : type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        type.icon,
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.accent700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.text,
                              ),
                            ),
                            Text(
                              '${type.defaultMg} mg',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white70 : AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _selected = DrinkType.custom),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: _selected == DrinkType.custom ? AppColors.accent : AppColors.neutral200,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Custom amount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selected == DrinkType.custom ? Colors.white : AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                  if (_selected == DrinkType.custom) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepBtn(
                          icon: Icons.remove,
                          onTap: () => setState(() => _customMg = (_customMg - 5).clamp(5, 999)),
                        ),
                        const SizedBox(width: 20),
                        RichText(
                          text: TextSpan(
                            style: headingStyle(40, color: Colors.white),
                            text: '$_customMg',
                            children: const [
                              TextSpan(
                                text: ' mg',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        _StepBtn(
                          icon: Icons.add,
                          onTap: () => setState(() => _customMg = (_customMg + 5).clamp(5, 999)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                elevation: 0,
              ),
              onPressed: _selected == null
                  ? null
                  : () {
                      final mg = _selected == DrinkType.custom
                          ? _customMg
                          : _selected!.defaultMg;
                      widget.onAdd(CaffeineEntry(
                        type: _selected!,
                        mg: mg,
                        time: DateTime.now(),
                        source: 'Phone',
                      ));
                      Navigator.pop(context);
                    },
              child: const Text(
                'Log',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0x33FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
