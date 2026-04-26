import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';

/// Profile screen with stats and settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Avatar ──────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ahmed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Growing every day 🌱',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // ── Stats Row ───────────────────────────────
              Consumer<JournalProvider>(
                builder: (context, provider, _) {
                  final entryCount = provider.entries.length;
                  return Row(
                    children: [
                      _StatCard(
                        label: 'Journals',
                        value: '$entryCount',
                        icon: Icons.book_rounded,
                      ),
                      const SizedBox(width: 12),
                      const _StatCard(
                        label: 'Streak',
                        value: '7 days',
                        icon: Icons.local_fire_department_rounded,
                      ),
                      const SizedBox(width: 12),
                      const _StatCard(
                        label: 'Insights',
                        value: '12',
                        icon: Icons.auto_awesome,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // ── Settings List ───────────────────────────
              GlassmorphicCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onTap: () {},
                    ),
                    Divider(
                      color: AppTheme.dividerColor,
                      height: 1,
                    ),
                    _SettingsRow(
                      icon: Icons.notifications_rounded,
                      label: 'Reminders',
                      onTap: () {},
                    ),
                    Divider(
                      color: AppTheme.dividerColor,
                      height: 1,
                    ),
                    _SettingsRow(
                      icon: Icons.download_rounded,
                      label: 'Export Data',
                      onTap: () {},
                    ),
                    Divider(
                      color: AppTheme.dividerColor,
                      height: 1,
                    ),
                    _SettingsRow(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Premium',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Go Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── App version ─────────────────────────────
              Text(
                'MindMirror v0.1.0',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}
