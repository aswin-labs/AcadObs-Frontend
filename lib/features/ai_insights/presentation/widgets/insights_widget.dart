import 'package:flutter/material.dart';

class InsightsWidget extends StatefulWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final Color iconColor;
  final String? bannerImagePath;
  final VoidCallback? onExplore;
 
  const InsightsWidget({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.icon = Icons.menu_book_rounded,
    this.iconColor = const Color(0xFFC07D2B),
    this.bannerImagePath,
    this.onExplore,
  });
 
  @override
  State<InsightsWidget> createState() => _InsightsWidgetState();
}
 
class _InsightsWidgetState extends State<InsightsWidget>
    with SingleTickerProviderStateMixin {
  bool isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  void _onTapDown(_) {
    setState(() => isPressed = true);
    _controller.forward();
  }
 
  void _onTapUp(_) {
    setState(() => isPressed = false);
    _controller.reverse();
  }
 
  void _onTapCancel() {
    setState(() => isPressed = false);
    _controller.reverse();
  }
 
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onExplore,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner Image ──────────────────────────────────────────
              _BannerSection(imageUrl: widget.bannerImagePath),
 
              // ── Content ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
 
                    // Description
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111827).withAlpha(153),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 16),
 
                    // Explore Button
                    _ExploreButton(
                      label: widget.buttonLabel,
                      onTap: widget.onExplore,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
// ── Banner Section ─────────────────────────────────────────────────────────────
 
class _BannerSection extends StatelessWidget {
  final String? imageUrl;
 
  const _BannerSection({this.imageUrl});
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image or fallback gradient
          if (imageUrl != null)
            Image.asset(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _FallbackBanner(),
            )
          else
            const _FallbackBanner(),
 
          // Bottom fade overlay so it blends into white card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white.withAlpha(230),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner();
 
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            Color(0xFFD1D5DB),
            Color(0xFF374151),
          ],
        ),
      ),
    );
  }
}
 
// ── Explore Button ─────────────────────────────────────────────────────────────
 
class _ExploreButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
 
  const _ExploreButton({required this.label, this.onTap});
 
  @override
  State<_ExploreButton> createState() => _ExploreButtonState();
}
 
class _ExploreButtonState extends State<_ExploreButton> {
  bool _hovered = false;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFFF3F4F6)
              : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.explore_outlined,
                size: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}