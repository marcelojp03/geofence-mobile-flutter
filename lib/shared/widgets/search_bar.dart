import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'glass_card.dart';

/// Barra de búsqueda con efecto glass
class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final IconData prefixIcon;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onTap;
  final bool readOnly;

  const GlassSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.prefixIcon = Icons.search_rounded,
    this.iconSize,
    this.padding,
    this.suffix,
    this.onSuffixTap,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = context.responsive;
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: r.wp(4), vertical: r.hp(0.5)),
      borderRadius: r.wp(3),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          fontSize: r.dp(1.7),
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: r.dp(1.7),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: theme.colorScheme.primary,
            size: iconSize ?? r.dp(2.5),
          ),
          suffixIcon: suffix != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: EdgeInsets.all(r.wp(2)),
                    child: suffix,
                  ),
                )
              : (controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: r.dp(2),
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged?.call('');
                        },
                      )
                    : null),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: r.wp(2),
            vertical: r.hp(1.5),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// Barra de búsqueda simple (sin efecto glass)
class SimpleSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? trailing;

  const SimpleSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = context.responsive;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(r.wp(3)),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(fontSize: r.dp(1.7)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: r.dp(1.7),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: r.dp(2.5),
          ),
          suffixIcon:
              trailing ??
              (controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: r.dp(2)),
                      onPressed: () {
                        controller.clear();
                        onChanged?.call('');
                      },
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: r.wp(4),
            vertical: r.hp(1.5),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
