import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/responsive.dart';

/// Widget de shimmer loading con flutter_animate
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isLoading) return child;

    final baseCol =
        baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightCol =
        highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: duration, colors: [baseCol, highlightCol, baseCol]);
  }
}

/// Caja de shimmer para placeholders
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Texto shimmer placeholder
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({super.key, this.width = 100, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: width, height: height, borderRadius: height / 2);
  }
}

/// Círculo shimmer placeholder
class ShimmerCircle extends StatelessWidget {
  final double diameter;

  const ShimmerCircle({super.key, this.diameter = 40});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: diameter,
      height: diameter,
      borderRadius: diameter / 2,
    );
  }
}

/// Card de shimmer genérica para listas
class ShimmerCard extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;

  const ShimmerCard({super.key, this.height, this.margin});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ShimmerLoading(
      isLoading: true,
      child: Container(
        height: height ?? r.hp(12),
        margin: margin ?? EdgeInsets.symmetric(vertical: r.hp(1)),
        padding: EdgeInsets.all(r.wp(4)),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(r.wp(3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            ShimmerCircle(diameter: r.dp(5)),
            SizedBox(width: r.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerText(width: r.wp(40), height: r.dp(1.8)),
                  SizedBox(height: r.hp(1)),
                  ShimmerText(width: r.wp(25), height: r.dp(1.4)),
                ],
              ),
            ),
            ShimmerBox(
              width: r.wp(15),
              height: r.dp(2.5),
              borderRadius: r.wp(2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de shimmer cards
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double? itemHeight;
  final EdgeInsetsGeometry? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return ListView.builder(
      padding: padding ?? EdgeInsets.all(r.wp(4)),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => ShimmerCard(height: itemHeight),
    );
  }
}

/// Shimmer específico para card de hijo (child tracking)
class ChildCardShimmer extends StatelessWidget {
  const ChildCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(1)),
        padding: EdgeInsets.all(r.wp(4)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.wp(4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerCircle(diameter: r.dp(6)),
                SizedBox(width: r.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: r.wp(35), height: r.dp(2)),
                      SizedBox(height: r.hp(0.5)),
                      ShimmerText(width: r.wp(25), height: r.dp(1.5)),
                    ],
                  ),
                ),
                ShimmerBox(
                  width: r.wp(18),
                  height: r.dp(3),
                  borderRadius: r.wp(2),
                ),
              ],
            ),
            SizedBox(height: r.hp(2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerText(width: r.wp(30), height: r.dp(1.5)),
                ShimmerText(width: r.wp(20), height: r.dp(1.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
