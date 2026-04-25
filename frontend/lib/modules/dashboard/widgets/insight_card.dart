import 'package:flutter/material.dart';
import 'package:frontend/models/insight_model.dart';

class InsightCard extends StatelessWidget {
  final InsightModel? insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: insight == null
          ? const SizedBox.shrink()
          : Card(
              key: ValueKey(insight!.id),
              color: theme.colorScheme.primaryContainer,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "AI Insight",
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHighlightedSummary(context, insight!),
                    const SizedBox(height: 12),
                    if (insight!.suggestedAction.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight!.suggestedAction,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHighlightedSummary(BuildContext context, InsightModel insight) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
    final boldStyle = textStyle?.copyWith(fontWeight: FontWeight.w700);

    // Bolding triggers in the summary if they exist
    String summary = insight.summary;
    List<String> triggers = insight.correlations.map((c) => c.trigger).toList();

    List<TextSpan> spans = [];
    String remaining = summary;

    for (String trigger in triggers) {
      if (trigger.isEmpty) continue;
      int index = remaining.toLowerCase().indexOf(trigger.toLowerCase());
      if (index != -1) {
        if (index > 0) {
          spans.add(TextSpan(text: remaining.substring(0, index)));
        }
        spans.add(TextSpan(
          text: remaining.substring(index, index + trigger.length),
          style: boldStyle,
        ));
        remaining = remaining.substring(index + trigger.length);
      }
    }

    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining));
    }

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: spans.isEmpty ? [TextSpan(text: summary)] : spans,
      ),
    );
  }
}
