import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/controllers/user_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';
import 'package:frontend/core/widgets/gradient_button.dart';

/// Journal check-in screen — the primary entry point for writing.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await context.read<JournalProvider>().addEntry(text);
    _controller.clear();
    FocusScope.of(context).unfocus();

    setState(() => _submitted = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _submitted = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Greeting ───────────────────────────────────
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Text(
                    '$_greeting, ${userProvider.name} ✨',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                "What's on your mind today?",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // ── Success Banner ──────────────────────────────
              if (_submitted)
                AnimatedOpacity(
                  opacity: _submitted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.positive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.positive.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppTheme.positive, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Entry saved! Your thoughts are being analyzed.',
                          style: TextStyle(
                            color: AppTheme.positive,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Text Input Card ─────────────────────────────
              GlassmorphicCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Write about your day',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      minLines: 5,
                      maxLines: null,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                      decoration: InputDecoration(
                        hintText:
                            'Write about your day, your thoughts, how you feel…',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Info row ────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.psychology_rounded,
                      color: AppTheme.primary.withValues(alpha: 0.6), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI will extract mood, tags, and triggers from your entry',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Save Button ─────────────────────────────────
              Consumer<JournalProvider>(
                builder: (context, provider, child) {
                  return GradientButton(
                    label: 'Save Entry',
                    icon: Icons.send_rounded,
                    isLoading: provider.isLoading,
                    onPressed: _submit,
                    width: double.infinity,
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Recent entries preview ──────────────────────
              Consumer<JournalProvider>(
                builder: (context, provider, _) {
                  if (provider.entries.isEmpty) return const SizedBox.shrink();
                  final recent = provider.entries.take(3).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Recent Entries',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...recent.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassmorphicCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  _moodIndicator(entry.sentimentScore),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.rawText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moodIndicator(double score) {
    final emoji = score > 0.3
        ? '😊'
        : score > 0
            ? '🙂'
            : score > -0.3
                ? '😐'
                : score > -0.6
                    ? '😔'
                    : '😢';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
