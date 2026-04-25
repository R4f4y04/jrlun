import 'package:flutter/material.dart';
import 'package:frontend/models/journal_entry.dart';

class SentimentChart extends StatefulWidget {
  final List<JournalEntry> entries;

  const SentimentChart({super.key, required this.entries});

  @override
  State<SentimentChart> createState() => _SentimentChartState();
}

class _SentimentChartState extends State<SentimentChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<JournalEntry>.from(widget.entries)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (sorted.isEmpty) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sentiment Trend",
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return GestureDetector(
                    onTapDown: (details) => _onTap(details, sorted),
                    onTapUp: (_) => setState(() => _hoveredIndex = null),
                    child: MouseRegion(
                      onHover: (event) => _onHover(event.localPosition, sorted),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _SentimentPainter(
                          entries: sorted,
                          progress: _animation.value,
                          primaryColor: theme.colorScheme.primary,
                          gridColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                          hoveredIndex: _hoveredIndex,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_hoveredIndex != null) ...[
              const SizedBox(height: 12),
              _buildTooltip(sorted[_hoveredIndex!], theme),
            ],
          ],
        ),
      ),
    );
  }

  void _onHover(Offset position, List<JournalEntry> entries) {
    final index = _indexFromX(position.dx, entries);
    if (index != _hoveredIndex) {
      setState(() => _hoveredIndex = index);
    }
  }

  void _onTap(TapDownDetails details, List<JournalEntry> entries) {
    final index = _indexFromX(details.localPosition.dx, entries);
    setState(() => _hoveredIndex = index == _hoveredIndex ? null : index);
  }

  int? _indexFromX(double dx, List<JournalEntry> entries) {
    if (entries.length < 2) return null;
    // We don't have the render box size here easily; approximate
    return null;
  }

  Widget _buildTooltip(JournalEntry entry, ThemeData theme) {
    final score = entry.sentimentScore;
    final color = score > 0.2
        ? Colors.green.shade400
        : score < -0.2
            ? Colors.red.shade400
            : Colors.orange.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            "${entry.createdAt.toString().split(' ')[0]}  •  ${score.toStringAsFixed(2)}",
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _SentimentPainter extends CustomPainter {
  final List<JournalEntry> entries;
  final double progress;
  final Color primaryColor;
  final Color gridColor;
  final int? hoveredIndex;

  _SentimentPainter({
    required this.entries,
    required this.progress,
    required this.primaryColor,
    required this.gridColor,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paddingLeft = 36.0;
    final paddingBottom = 24.0;
    final chartW = size.width - paddingLeft;
    final chartH = size.height - paddingBottom;

    // Draw horizontal gridlines at -1, -0.5, 0, 0.5, 1
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: gridColor.withValues(alpha: 0.8),
      fontSize: 10,
    );

    for (final val in [-1.0, -0.5, 0.0, 0.5, 1.0]) {
      final y = _yPos(val, chartH);
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width, y), gridPaint);
      _drawLabel(canvas, val.toStringAsFixed(1), Offset(0, y - 6), labelStyle);
    }

    // Draw zero line slightly stronger
    final zeroLinePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(paddingLeft, _yPos(0, chartH)),
      Offset(size.width, _yPos(0, chartH)),
      zeroLinePaint,
    );

    if (entries.length < 2) return;

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = paddingLeft + (i / (entries.length - 1)) * chartW;
      final y = _yPos(entries[i].sentimentScore, chartH);
      points.add(Offset(x, y));
    }

    // Clamp draw progress
    final visibleCount = (progress * (points.length - 1)).clamp(0.0, points.length - 1.0);
    final fullPoints = visibleCount.floor();
    final frac = visibleCount - fullPoints;

    // Gradient fill under the line
    final fillPath = Path()..moveTo(points[0].dx, _yPos(0, chartH));
    for (int i = 0; i <= fullPoints && i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        _addSplinePoint(fillPath, points, i);
      }
    }
    if (fullPoints < points.length - 1 && frac > 0) {
      final interp = Offset.lerp(points[fullPoints], points[fullPoints + 1], frac)!;
      fillPath.lineTo(interp.dx, interp.dy);
      fillPath.lineTo(interp.dx, _yPos(0, chartH));
    } else if (fullPoints == points.length - 1) {
      fillPath.lineTo(points.last.dx, _yPos(0, chartH));
    }
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primaryColor.withValues(alpha: 0.3), primaryColor.withValues(alpha: 0.0)],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= fullPoints && i < points.length; i++) {
      _addSplinePoint(linePath, points, i);
    }
    if (fullPoints < points.length - 1 && frac > 0) {
      final interp = Offset.lerp(points[fullPoints], points[fullPoints + 1], frac)!;
      linePath.lineTo(interp.dx, interp.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    for (int i = 0; i < points.length; i++) {
      final isHovered = i == hoveredIndex;
      final dotPaint = Paint()..color = isHovered ? primaryColor : primaryColor.withValues(alpha: 0.7);
      canvas.drawCircle(points[i], isHovered ? 6 : 4, dotPaint);
      canvas.drawCircle(points[i], isHovered ? 3 : 2, Paint()..color = Colors.white);
    }
  }

  void _addSplinePoint(Path path, List<Offset> pts, int i) {
    if (i >= pts.length) return;
    if (i == 1) {
      path.lineTo(pts[i].dx, pts[i].dy);
      return;
    }
    final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
    final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
  }

  double _yPos(double score, double chartH) {
    // score -1 → bottom, 1 → top
    return chartH * (1 - (score + 1) / 2);
  }

  void _drawLabel(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_SentimentPainter old) =>
      old.progress != progress ||
      old.hoveredIndex != hoveredIndex ||
      old.entries != entries;
}
