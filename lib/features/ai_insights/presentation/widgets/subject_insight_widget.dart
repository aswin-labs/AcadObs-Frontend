import 'package:flutter/material.dart';

enum SubjectStatus {
  needsSupport,
  onTrack,
  excellent,
}
 
extension SubjectStatusStyle on SubjectStatus {
  String get label {
    switch (this) {
      case SubjectStatus.needsSupport:
        return 'Needs Support';
      case SubjectStatus.onTrack:
        return 'On Track';
      case SubjectStatus.excellent:
        return 'Excellent';
    }
  }
 
  Color get badgeTextColor {
    switch (this) {
      case SubjectStatus.needsSupport:
        return const Color(0xFFB91C1C);
      case SubjectStatus.onTrack:
        return const Color(0xFF92400E);
      case SubjectStatus.excellent:
        return const Color(0xFF166534);
    }
  }
 
  Color get badgeBgColor {
    switch (this) {
      case SubjectStatus.needsSupport:
        return const Color(0xFFFFE4E4);
      case SubjectStatus.onTrack:
        return const Color(0xFFFEF3C7);
      case SubjectStatus.excellent:
        return const Color(0xFFDCFCE7);
    }
  }
 
  Color get progressColor {
    switch (this) {
      case SubjectStatus.needsSupport:
        return const Color(0xFFEF4444);
      case SubjectStatus.onTrack:
        return const Color(0xFFF59E0B);
      case SubjectStatus.excellent:
        return const Color(0xFF22C55E);
    }
  }
 
  Color get iconBgColor {
    switch (this) {
      case SubjectStatus.needsSupport:
        return const Color(0xFFFFE4E4);
      case SubjectStatus.onTrack:
        return const Color(0xFFFEF3C7);
      case SubjectStatus.excellent:
        return const Color(0xFFDCFCE7);
    }
  }
 
  Color get iconColor {
    switch (this) {
      case SubjectStatus.needsSupport:
        return const Color(0xFFEF4444);
      case SubjectStatus.onTrack:
        return const Color(0xFFF59E0B);
      case SubjectStatus.excellent:
        return const Color(0xFF22C55E);
    }
  }
 
  Color get cardBorderColor {
    switch (this) {
      case SubjectStatus.needsSupport:
        return const Color(0xFFFECACA);
      case SubjectStatus.onTrack:
        return const Color(0xFFFDE68A);
      case SubjectStatus.excellent:
        return const Color(0xFFBBF7D0);
    }
  }
}
 
// ── Subject Insights Widget ────────────────────────────────────────────────────
 
class SubjectInsightsWidget extends StatelessWidget {
  /// Subject name e.g. "Maths", "Science"
  final String subject;
 
  /// Icon representing the subject
  final IconData icon;
 
  /// Predicted score as a percentage (0–100)
  final int predictedScore;
 
  /// Status level driving all colors
  final SubjectStatus status;
 
  /// Recommendation text shown at the bottom
  final String recommendation;
 
  /// Optional tap callback
  final VoidCallback? onTap;
 
  const SubjectInsightsWidget({
    super.key,
    required this.subject,
    required this.icon,
    required this.predictedScore,
    required this.status,
    required this.recommendation,
    this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status.cardBorderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: status.iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: status.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
 
                  // Subject name + badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _StatusBadge(status: status),
                      ],
                    ),
                  ),
 
                  // Predicted score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$predictedScore%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: status.progressColor,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Predicted',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280).withAlpha(200),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
 
            // ── Progress Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _AnimatedProgressBar(
                value: predictedScore / 100,
                color: status.progressColor,
              ),
            ),
 
            // ── Recommendation ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Text(
                recommendation,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF374151).withAlpha(210),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ── Status Badge ───────────────────────────────────────────────────────────────
 
class _StatusBadge extends StatelessWidget {
  final SubjectStatus status;
  const _StatusBadge({required this.status});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: status.badgeBgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.badgeTextColor,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
 
// ── Animated Progress Bar ──────────────────────────────────────────────────────
 
class _AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color color;
 
  const _AnimatedProgressBar({required this.value, required this.color});
 
  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}
 
class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }
 
  @override
  void didUpdateWidget(_AnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _animation = Tween<double>(begin: old.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          value: _animation.value,
          minHeight: 6,
          backgroundColor: widget.color.withAlpha(30),
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        ),
      ),
    );
  }
}