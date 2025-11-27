import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/responsive.dart';
import '../providers/theme_notifier.dart';
import '../../config/theme/app_theme.dart';

/// Scaffold base reutilizable para el proyecto GeoKids
/// Incluye AppBar personalizable y manejo responsivo
class GeofenceScaffold extends ConsumerWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showThemeToggle;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const GeofenceScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.actions,
    this.leading,
    this.showThemeToggle = false,
    this.centerTitle = true,
    this.bottom,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              centerTitle: centerTitle,
              leading: leading,
              actions: [
                ...?actions,
                if (showThemeToggle)
                  IconButton(
                    icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                    onPressed: () {
                      ref.read(themeNotifierProvider.notifier).toggleDarkMode();
                    },
                  ),
              ],
              bottom: bottom,
            )
          : null,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Card responsiva para contenido
class GeofenceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const GeofenceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    final cardWidget = Card(
      elevation: elevation ?? 2,
      color: color,
      margin: margin ?? EdgeInsets.all(r.wp(2)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
      ),
      child: Padding(padding: padding ?? EdgeInsets.all(r.wp(4)), child: child),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// Botón primario responsivo
class GeofenceButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final Color? backgroundColor;

  const GeofenceButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? SizedBox(
                    width: r.dp(2),
                    height: r.dp(2),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon),
            label: Text(text, style: TextStyle(fontSize: r.dp(1.8))),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(6),
                vertical: r.hp(2),
              ),
            ),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(6),
                vertical: r.hp(2),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: r.dp(2),
                    height: r.dp(2),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(text, style: TextStyle(fontSize: r.dp(1.8))),
          );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Input field responsivo con estilo consistente
class GeofenceTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;

  const GeofenceTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Status badge para mostrar estado del niño (dentro/fuera)
class StatusBadge extends StatelessWidget {
  final bool isInside;
  final String? text;

  const StatusBadge({super.key, required this.isInside, this.text});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.wp(3), vertical: r.hp(0.5)),
      decoration: BoxDecoration(
        color: isInside ? AppTheme.insideColor : AppTheme.outsideColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInside ? Icons.check_circle : Icons.warning,
            size: r.dp(1.8),
            color: Colors.white,
          ),
          SizedBox(width: r.wp(1)),
          Text(
            text ?? (isInside ? 'Dentro' : 'Fuera'),
            style: TextStyle(
              color: Colors.white,
              fontSize: r.dp(1.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
