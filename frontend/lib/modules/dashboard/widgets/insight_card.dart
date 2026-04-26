import 'package:flutter/material.dart';
import 'package:frontend/models/insight_model.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';

class InsightCard extends StatelessWidget {
  final InsightModel? insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: insight == null
          ? const SizedBox.shrink()
          : GlassmorphicCard(
              key: ValueKey(insight!.id),
              glowBorder: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 16),
                  _buildHighlightedSummary(insight!),
                  if (insight!.correlations.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _correlationChips(),
                  ],
                  if (insight!.suggestedAction.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _suggestedAction(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.auto_awesome, color: AppTheme.primary, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          'AI Insight',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Auto-generated',
            style: TextStyle(
              color: AppTheme.primary.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _correlationChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: insight!.correlations.map((c) {
        final isPositive = c.impact.toLowerCase() == 'positive';
        final color = isPositive ? AppTheme.positive : AppTheme.negative;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(c.trigger, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _suggestedAction() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppTheme.tertiary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight!.suggestedAction,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedSummary(InsightModel insight) {
    final textStyle = TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.5);
    final boldStyle = textStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.white);
    String summary = insight.summary;
    List<String> triggers = insight.correlations.map((c) => c.trigger).toList();
    List<TextSpan> spans = [];
    String remaining = summary;
    for (String trigger in triggers) {
      if (trigger.isEmpty) continue;
      int index = remaining.toLowerCase().indexOf(trigger.toLowerCase());
      if (index != -1) {
        if (index > 0) spans.add(TextSpan(text: remaining.substring(0, index)));
        spans.add(TextSpan(text: remaining.substring(index, index + trigger.length), style: boldStyle));
        remaining = remaining.substring(index + trigger.length);
      }
    }
    if (remaining.isNotEmpty) spans.add(TextSpan(text: remaining));
    return RichText(text: TextSpan(style: textStyle, children: spans.isEmpty ? [TextSpan(text: summary)] : spans));
  }
}
