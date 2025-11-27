import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Botón personalizado con loading state y animaciones
/// Reemplaza a GeofenceButton con más funcionalidades
class CustomFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? buttonColor;
  final Color? textColor;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const CustomFilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.buttonColor,
    this.textColor,
    this.width,
    this.padding,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Color del botón
    final bgColor = buttonColor ?? theme.colorScheme.primary;
    final fgColor = textColor ?? Colors.white;

    // Color cuando está deshabilitado
    final disabledBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width ?? double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading || onPressed == null ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: onPressed == null ? disabledBgColor : bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: onPressed != null && !isLoading
                  ? [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              padding:
                  padding ??
                  EdgeInsets.symmetric(horizontal: r.wp(6), vertical: r.hp(2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading indicator
                  if (isLoading) ...[
                    SizedBox(
                      width: r.dp(2.2),
                      height: r.dp(2.2),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: fgColor,
                      ),
                    ),
                    SizedBox(width: r.wp(3)),
                  ],

                  // Icono opcional
                  if (icon != null && !isLoading) ...[
                    Icon(icon, color: fgColor, size: r.dp(2.2)),
                    SizedBox(width: r.wp(2)),
                  ],

                  // Texto
                  Text(
                    isLoading ? 'Cargando...' : text,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: r.dp(1.8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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

/// Botón outline (secundario)
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double borderRadius;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.borderColor,
    this.textColor,
    this.width,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);

    final color = borderColor ?? theme.colorScheme.primary;

    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: r.wp(6), vertical: r.hp(2)),
        ),
        child: isLoading
            ? SizedBox(
                width: r.dp(2),
                height: r.dp(2),
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor ?? color, size: r.dp(2.2)),
                    SizedBox(width: r.wp(2)),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? color,
                      fontSize: r.dp(1.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón de texto (terciario)
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.primary;

    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: r.dp(2)),
            SizedBox(width: r.wp(1)),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: r.dp(1.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
