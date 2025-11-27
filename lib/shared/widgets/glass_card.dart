import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/responsive.dart';

/// Card con efecto de vidrio esmerilado (glassmorphism)
/// Ideal para formularios y contenido destacado
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurStrength;
  final List<BoxShadow>? shadows;
  final bool animated;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 18.0,
    this.backgroundColor,
    this.borderColor,
    this.blurStrength = 10.0,
    this.shadows,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;
    final r = context.responsive;

    // Patrón profesional de sombras y bordes
    final modernShadows =
        shadows ??
        [
          if (isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
        ];

    final modernBorder = Border.all(
      color:
          borderColor ??
          (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06)),
      width: 1,
    );

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: modernShadows,
        border: modernBorder,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: blurStrength,
            sigmaY: blurStrength,
          ),
          child: Container(
            padding: padding ?? EdgeInsets.all(r.wp(6)),
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.8)),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );

    // Micro-interacciones profesionales
    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: disableAnimations
            ? card
            : card
                  .animate(target: 1)
                  .scale(
                    duration: 100.ms,
                    curve: Curves.easeOut,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(0.98, 0.98),
                  ),
      );
    }

    // Animaciones de entrada profesionales
    final bool shouldAnimate = animated && !disableAnimations;
    if (shouldAnimate) {
      return card
          .animate(target: 1)
          .fadeIn(duration: 220.ms, curve: Curves.fastOutSlowIn)
          .slideY(
            duration: 220.ms,
            begin: 0.06,
            end: 0,
            curve: Curves.fastOutSlowIn,
          );
    }

    return card;
  }
}

/// Card de información con estructura predefinida
class InfoGlassCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;

  const InfoGlassCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = context.responsive;

    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            Container(
              padding: EdgeInsets.all(r.wp(2)),
              decoration: BoxDecoration(
                color: (accentColor ?? theme.colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(r.wp(2)),
              ),
              child: leading!,
            ),
            SizedBox(width: r.wp(3)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: r.dp(1.8),
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: r.hp(0.3)),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: r.dp(1.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: r.wp(2)), trailing!],
        ],
      ),
    );
  }
}

/// Card con efecto hover para escritorio/tablet
class HoverGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double hoverScale;
  final Color? hoverBorderColor;

  const HoverGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 18.0,
    this.onTap,
    this.hoverScale = 1.02,
    this.hoverBorderColor,
  });

  @override
  State<HoverGlassCard> createState() => _HoverGlassCardState();
}

class _HoverGlassCardState extends State<HoverGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaleValue = _isHovered ? widget.hoverScale : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.diagonal3Values(scaleValue, scaleValue, 1.0),
        child: GlassCard(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          borderColor: _isHovered
              ? (widget.hoverBorderColor ??
                    theme.colorScheme.primary.withValues(alpha: 0.5))
              : null,
          shadows: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    offset: const Offset(0, 12),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ]
              : null,
          child: widget.child,
        ),
      ),
    );
  }
}
