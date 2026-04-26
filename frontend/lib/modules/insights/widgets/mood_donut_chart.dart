import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Donut chart showing mood distribution computed from real entries.
class MoodDonutChart extends StatelessWidget {
  final List<JournalEntry> entries;
  const MoodDonutChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // Compute mood distribution
    int great = 0, good = 0, okay = 0, bad = 0, veryBad = 0;
    for (final e in entries) {
      final s = e.sentimentScore;
      if (s > 0.5) {
        great++;
      } else if (s > 0.1) {
        good++;
      } else if (s > -0.2) {
        okay++;
      } else if (s > -0.5) {
        bad++;
      } else {
        veryBad++;
      }
    }
    final total = entries.isEmpty ? 1 : entries.length;
    final data = [
      _MoodSlice('Great', great, AppTheme.positive),
      _MoodSlice('Good', good, AppTheme.secondary),
      _MoodSlice('Okay', okay, AppTheme.tertiary),
      _MoodSlice('Bad', bad, const Color(0xFFFF6B6B)),
      _MoodSlice('Very Bad', veryBad, AppTheme.negative),
    ].where((s) => s.count > 0).toList();

    if (data.isEmpty) {
      data.add(_MoodSlice('No data', 1, AppTheme.textMuted));
    }

    return Row(
      children: [
        // Chart
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _DonutPainter(data, total),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entries.isEmpty ? '😶' : _dominantEmoji(data),
                    style: const TextStyle(fontSize: 28),
                  ),
                  Text(
                    '$total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: s.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.label,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(s.count / total * 100).round()}%',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  String _dominantEmoji(List<_MoodSlice> data) {
    final top = data.reduce((a, b) => a.count >= b.count ? a : b);
    switch (top.label) {
      case 'Great':
        return '😄';
      case 'Good':
        return '😊';
      case 'Okay':
        return '😐';
      case 'Bad':
        return '😔';
      case 'Very Bad':
        return '😢';
      default:
        return '😶';
    }
  }
}

class _MoodSlice {
  final String label;
  final int count;
  final Color color;
  _MoodSlice(this.label, this.count, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_MoodSlice> slices;
  final int total;
  _DonutPainter(this.slices, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final strokeWidth = 14.0;
    double startAngle = -pi / 2;

    for (final s in slices) {
      final sweep = (s.count / total) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = s.color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweep + 0.03; // tiny gap
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
