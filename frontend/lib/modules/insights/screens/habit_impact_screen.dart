import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';
import 'package:frontend/core/widgets/premium_lock_overlay.dart';

/// Habit Impact screen — premium locked with blurred preview.
class HabitImpactScreen extends StatelessWidget {
  const HabitImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Impact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PremiumLockOverlay(
        title: 'Unlock Habit Analytics',
        subtitle: 'See how your daily habits affect your mood, energy, and productivity.',
        child: _HabitPreviewContent(),
      ),
    );
  }
}

class _HabitPreviewContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habits = [
      _Habit('Exercise', '+40% better mood', Icons.fitness_center_rounded, true),
      _Habit('Good Sleep', '+35% more productive', Icons.bedtime_rounded, true),
      _Habit('Social Time', '+30% happier', Icons.people_rounded, true),
      _Habit('Junk Food', '-20% energy', Icons.fastfood_rounded, false),
      _Habit('Late Scrolling', '-25% next day mood', Icons.phone_android_rounded, false),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: habits
            .map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassmorphicCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (h.positive ? AppTheme.positive : AppTheme.negative)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(h.icon,
                              color: h.positive ? AppTheme.positive : AppTheme.negative,
                              size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(h.impact,
                                  style: TextStyle(
                                      color: h.positive
                                          ? AppTheme.positive
                                          : AppTheme.negative,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(
                          h.positive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: h.positive ? AppTheme.positive : AppTheme.negative,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _Habit {
  final String name, impact;
  final IconData icon;
  final bool positive;
  _Habit(this.name, this.impact, this.icon, this.positive);
}
