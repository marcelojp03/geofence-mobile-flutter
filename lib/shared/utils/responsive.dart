import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class that provides easy access to the current
/// screen dimensions. Instead of using mutable `late` fields,
/// the values are calculated once and exposed as `final`
/// properties, making the class simpler and safer to use.
class Responsive {
  final double width;
  final double height;
  final double diagonal;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isPortrait;
  final bool isLandscape;

  /// Creates a [Responsive] object from the given [BuildContext].
  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );
    final shortestSide = size.shortestSide;

    // Breakpoints
    final isMobile = shortestSide < 600;
    final isTablet = shortestSide >= 600 && shortestSide < 1024;
    final isDesktop = shortestSide >= 1024;

    // Orientation
    final isPortrait = size.height >= size.width;

    return Responsive._(
      width: size.width,
      height: size.height,
      diagonal: diagonal,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      isPortrait: isPortrait,
      isLandscape: !isPortrait,
    );
  }

  const Responsive._({
    required this.width,
    required this.height,
    required this.diagonal,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isPortrait,
    required this.isLandscape,
  });

  /// Width percentage - returns [percent]% of screen width
  double wp(double percent) => width * percent / 100;

  /// Height percentage - returns [percent]% of screen height
  double hp(double percent) => height * percent / 100;

  /// Diagonal percentage - returns [percent]% of screen diagonal
  /// Useful for font sizes, icons, and radius that should scale uniformly
  double dp(double percent) => diagonal * percent / 100;
}

/// Extension on [BuildContext] to access [Responsive] easily
///
/// Usage:
/// ```dart
/// final r = context.responsive;
/// Container(width: r.wp(80), height: r.hp(40));
/// ```
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive.of(this);
}
