import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderOpacity;
  final double backgroundOpacity;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadow;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.borderOpacity = 0.15,
    this.backgroundOpacity = 0.05,
    this.color,
    this.borderColor,
    this.padding,
    this.width,
    this.height,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // In dark mode: semi-transparent white. In light mode: pure white.
    final actualColor = color ?? (isDark ? Colors.white.withOpacity(backgroundOpacity) : Colors.white);
    
    final baseBorderColor = borderColor ?? (isDark ? Colors.white : const Color(0xFFE2E8F0));

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: actualColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: baseBorderColor.withOpacity(borderOpacity),
          width: 1.5,
        ),
        boxShadow: shadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

extension WidgetMargin on Widget {
  Widget marginOnly({double bottom = 0.0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: this,
    );
  }
}

