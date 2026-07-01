import 'package:flutter/material.dart';
import 'dart:math' as math;

enum HoverEffectType { lift, glow, sweep }

class AdvancedHoverCard extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final VoidCallback? onTap;
  final Color effectColor;
  final Color backgroundColor;
  final HoverEffectType effectType;

  const AdvancedHoverCard({
    Key? key,
    required this.builder,
    this.onTap,
    required this.effectColor,
    required this.backgroundColor,
    required this.effectType,
  }) : super(key: key);

  @override
  State<AdvancedHoverCard> createState() => _AdvancedHoverCardState();
}

class _AdvancedHoverCardState extends State<AdvancedHoverCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _onHover(bool hovered) {
    setState(() {
      _isHovered = hovered;
      if (widget.effectType == HoverEffectType.sweep) {
        if (hovered) {
          _sweepController.repeat();
        } else {
          _sweepController.stop();
          _sweepController.value = 0;
        }
      }
    });
  }

  void _onTap() {
    if (widget.onTap == null) return;
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) widget.onTap!();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap != null ? _onTap : null,
        child: _buildEffectWidget(),
      ),
    );
  }

  Widget _buildEffectWidget() {
    final innerContent = widget.builder(context, _isHovered);

    switch (widget.effectType) {
      case HoverEffectType.lift:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -8.0 : 0, 0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.effectColor.withOpacity(0.6) : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.effectColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
                : [],
          ),
          child: innerContent,
        );

      case HoverEffectType.glow:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.effectColor : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.effectColor.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: innerContent,
        );

      case HoverEffectType.sweep:
        return Stack(
          children: [
            // Base layer
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                  color: widget.backgroundColor,
                ),
              ),
            ),
            // Sweep layer
            if (_isHovered)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedBuilder(
                    animation: _sweepController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _sweepController.value * 2 * math.pi,
                        child: Transform.scale(
                          scale: 3.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: SweepGradient(
                                colors: [
                                  Colors.transparent,
                                  widget.effectColor.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                                stops: const [0.45, 0.5, 0.55],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // Inner mask layer to hide the center of the sweep gradient
            if (_isHovered)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(14.5),
                    ),
                  ),
                ),
              ),
            // Content layer
            Padding(
              padding: const EdgeInsets.all(1.5),
              child: innerContent,
            ),
          ],
        );
    }
  }
}
