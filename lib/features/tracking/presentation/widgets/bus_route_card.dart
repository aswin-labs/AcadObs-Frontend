import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class BusRouteCard extends StatefulWidget {
  final String? studentName;
  final String routeName;
  final String type;
  final VoidCallback onTap;
  final bool isLive;

  const BusRouteCard({
    super.key,
    this.studentName,
    required this.routeName,
    required this.type,
    required this.onTap,
    this.isLive = false,
  });

  @override
  State<BusRouteCard> createState() => _BusRouteCardState();
}

class _BusRouteCardState extends State<BusRouteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isPickup => widget.type == "PICKUP";

  Color get _typeColor =>
      _isPickup ? const Color(0xFF22C55E) : const Color(0xFF3B82F6);

  Color get _typeBg =>
      _isPickup ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE);

  static const _liveGreen = Color(0xFF16A34A);
  // static const _liveGreenBg = Color(0xFFDCFCE7);

  @override
  Widget build(BuildContext context) {
    final cardBorder =
        widget.isLive ? _liveGreen.withAlpha(120) : Colors.grey.withAlpha(30);

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.height * 1.5),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.isLive
                          ? _liveGreen.withAlpha(20)
                          : Colors.black.withAlpha(8),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isLive)
                    Container(
                      width: double.infinity,
                      // color: _liveGreenBg,
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.width * 4,
                        vertical: Responsive.height * 0.8,
                      ),
                      child: Row(
                        children: [
                          _PulseDot(animation: _pulseAnimation),
                          SizedBox(width: Responsive.width * 2),
                          Text(
                            'Live',
                            style: context.textTheme.labelSmall!.copyWith(
                              color: _liveGreen,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.my_location_rounded,
                            size: 14,
                            color: _liveGreen,
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width * 4,
                      vertical: Responsive.height * 1.4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.directions_bus_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        SizedBox(width: Responsive.width * 3.5),

                        // Name + Route
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.studentName != null)
                                Text(
                                  widget.studentName ?? "",
                                  style: context.textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(height: Responsive.height * 0.5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    size: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                  SizedBox(width: Responsive.width * 1),
                                  Expanded(
                                    child: Text(
                                      widget.routeName,
                                      style: context.textTheme.bodySmall!
                                          .copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: Responsive.width * 2),

                        // Type Badge
                        _TypeBadge(
                          isPickup: _isPickup,
                          color: _typeColor,
                          bg: _typeBg,
                        ),

                        SizedBox(width: Responsive.width * 2),

                        // Chevron
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  final Animation<double> animation;
  const _PulseDot({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder:
          (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF16A34A,
                  ).withOpacity(animation.value * 0.3),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isPickup;
  final Color color;
  final Color bg;

  const _TypeBadge({
    required this.isPickup,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPickup
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isPickup ? 'Pickup' : 'Drop',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
