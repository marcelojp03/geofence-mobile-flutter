import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/responsive.dart';

/// Card de aplicación con animaciones y sombras modernas
/// Útil para listas, grids y contenido general
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final Duration? animationDelay;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.animationDelay,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(r.wp(4)),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? r.wp(4)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: r.wp(3),
            spreadRadius: r.wp(0.5),
            offset: Offset(0, r.wp(1)),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? r.wp(4)),
          child: cardContent,
        ),
      );
    }

    if (disableAnimations) return cardContent;

    return cardContent
        .animate(
          delay: animationDelay ?? 0.ms,
          target: disableAnimations ? 0 : 1,
        )
        .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.06, duration: 360.ms, curve: Curves.easeOutCubic)
        .shimmer(
          delay: Duration(
            milliseconds: (animationDelay?.inMilliseconds ?? 0) + 600,
          ),
          duration: 900.ms,
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        );
  }
}

/// Widget específico para Quick Actions con patrón unificado
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Duration? animationDelay;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      animationDelay: animationDelay,
      padding: EdgeInsets.all(r.wp(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(r.wp(3)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.wp(3)),
            ),
            child: Icon(icon, size: r.dp(3.5), color: color),
          ),
          SizedBox(height: r.hp(1.5)),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: r.dp(1.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: r.hp(0.5)),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: r.dp(1.3),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Card para mostrar estadísticas
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.wp(3)),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.wp(3)),
            ),
            child: Icon(icon, color: cardColor, size: r.dp(3)),
          ),
          SizedBox(width: r.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: r.dp(2.4),
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: r.dp(1.4),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
