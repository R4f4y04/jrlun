import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<JournalEntry>.from(widget.entries)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (sorted.isEmpty) return const SizedBox.shrink();

    return GlassmorphicCard(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, color: AppTheme.secondary, size: 18),
              const SizedBox(width: 8),
              Text('Mood Trend', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('30 days', style: TextStyle(color: AppTheme.secondary, fontSize: 10, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return GestureDetector(
                  onTapDown: (d) => _onTap(d, sorted),
                  onTapUp: (_) => setState(() => _hoveredIndex = null),
                  child: MouseRegion(
                    onHover: (e) => _onHover(e.localPosition, sorted),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _SentimentPainter(
                        entries: sorted,
                        progress: _animation.value,
                        lineColor: AppTheme.secondary,
                        gridColor: Colors.white.withValues(alpha: 0.05),
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
            _buildTooltip(sorted[_hoveredIndex!]),
          ],
        ],
      ),
    );
  }

  void _onHover(Offset position, List<JournalEntry> entries) {
    final index = _indexFromX(position.dx, entries);
    if (index != _hoveredIndex) setState(() => _hoveredIndex = index);
  }

  void _onTap(TapDownDetails details, List<JournalEntry> entries) {
    final index = _indexFromX(details.localPosition.dx, entries);
    setState(() => _hoveredIndex = index == _hoveredIndex ? null : index);
  }

  int? _indexFromX(double dx, List<JournalEntry> entries) {
    if (entries.length < 2) return null;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final chartW = renderBox.size.width - 36.0;
    final ratio = (dx - 36.0) / chartW;
    final index = (ratio * (entries.length - 1)).round();
    return index.clamp(0, entries.length - 1);
  }

  Widget _buildTooltip(JournalEntry entry) {
    final score = entry.sentimentScore;
    final color = score > 0.2 ? AppTheme.positive : score < -0.2 ? AppTheme.negative : AppTheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            "${DateFormat('MMM d').format(entry.createdAt)}  •  ${score.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SentimentPainter extends CustomPainter {
  final List<JournalEntry> entries;
  final double progress;
  final Color lineColor;
  final Color gridColor;
  final int? hoveredIndex;

  _SentimentPainter({required this.entries, required this.progress, required this.lineColor, required this.gridColor, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final pL = 36.0, pB = 24.0;
    final cW = size.width - pL, cH = size.height - pB;
    final gridPaint = Paint()..color = gridColor..strokeWidth = 1;
    final labelStyle = TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 10);

    for (final val in [-1.0, -0.5, 0.0, 0.5, 1.0]) {
      final y = _yPos(val, cH);
      canvas.drawLine(Offset(pL, y), Offset(size.width, y), gridPaint);
      _drawLabel(canvas, val.toStringAsFixed(1), Offset(0, y - 6), labelStyle);
    }

    // Zero line
    canvas.drawLine(
      Offset(pL, _yPos(0, cH)),
      Offset(size.width, _yPos(0, cH)),
      Paint()..color = lineColor.withValues(alpha: 0.15)..strokeWidth = 1.5,
    );

    if (entries.length < 2) return;
    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      points.add(Offset(pL + (i / (entries.length - 1)) * cW, _yPos(entries[i].sentimentScore, cH)));
    }

    final vis = (progress * (points.length - 1)).clamp(0.0, points.length - 1.0);
    final full = vis.floor();
    final frac = vis - full;

    // Gradient fill
    final fillPath = Path()..moveTo(points[0].dx, _yPos(0, cH));
    for (int i = 0; i <= full && i < points.length; i++) {
      i == 0 ? fillPath.lineTo(points[i].dx, points[i].dy) : _spline(fillPath, points, i);
    }
    if (full < points.length - 1 && frac > 0) {
      final interp = Offset.lerp(points[full], points[full + 1], frac)!;
      fillPath.lineTo(interp.dx, interp.dy);
      fillPath.lineTo(interp.dx, _yPos(0, cH));
    } else if (full == points.length - 1) {
      fillPath.lineTo(points.last.dx, _yPos(0, cH));
    }
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [lineColor.withValues(alpha: 0.25), lineColor.withValues(alpha: 0.0)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Line
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= full && i < points.length; i++) _spline(linePath, points, i);
    if (full < points.length - 1 && frac > 0) {
      linePath.lineTo(Offset.lerp(points[full], points[full + 1], frac)!.dx, Offset.lerp(points[full], points[full + 1], frac)!.dy);
    }
    canvas.drawPath(linePath, Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // Glow line
    canvas.drawPath(linePath, Paint()..color = lineColor.withValues(alpha: 0.3)..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Dots
    for (int i = 0; i < points.length; i++) {
      final h = i == hoveredIndex;
      canvas.drawCircle(points[i], h ? 6 : 3.5, Paint()..color = h ? lineColor : lineColor.withValues(alpha: 0.7));
      canvas.drawCircle(points[i], h ? 3 : 1.5, Paint()..color = const Color(0xFF0A0A0F));
    }
  }

  void _spline(Path p, List<Offset> pts, int i) {
    if (i >= pts.length) return;
    if (i == 1) { p.lineTo(pts[i].dx, pts[i].dy); return; }
    final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
    final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
    p.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
  }

  double _yPos(double score, double cH) => cH * (1 - (score + 1) / 2);

  void _drawLabel(Canvas c, String t, Offset o, TextStyle s) {
    final tp = TextPainter(text: TextSpan(text: t, style: s), textDirection: ui.TextDirection.ltr)..layout();
    tp.paint(c, o);
  }

  @override
  bool shouldRepaint(_SentimentPainter old) => old.progress != progress || old.hoveredIndex != hoveredIndex || old.entries != entries;
}
