import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Input field personalizado con animaciones y estilo consistente
/// Reemplaza a GeofenceTextField con más funcionalidades
class CustomInputField extends StatefulWidget {
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? errorMessage;
  final bool isFormPosted;
  final bool enabled;
  final int maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const CustomInputField({
    super.key,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onChanged,
    this.errorMessage,
    this.isFormPosted = false,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determinar si hay error
    final hasError = widget.isFormPosted && widget.errorMessage != null;

    // Colores adaptativos
    final borderColor = hasError
        ? theme.colorScheme.error
        : _isFocused
        ? theme.colorScheme.primary
        : (isDark ? Colors.white24 : Colors.black12);

    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.05);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label animado
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: r.dp(1.4), // Reduced from 1.6
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
            color: hasError
                ? theme.colorScheme.error
                : _isFocused
                ? theme.colorScheme.primary
                : (isDark ? Colors.white70 : Colors.black54),
          ),
          child: Text(widget.label),
        ),

        SizedBox(height: r.hp(1)),

        // Input con animación de borde
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: _isFocused ? 2 : 1),
            color: fillColor,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize: r.dp(1.6), // Reduced from 1.8
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white54 : Colors.black45),
                      size: r.dp(2.2), // Reduced from 2.5
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: r.wp(3.5), // Reduced from 4
                vertical: r.hp(1.6), // Reduced from 2
              ),
              isDense: true,
            ),
          ),
        ),

        // Mensaje de error animado
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  padding: EdgeInsets.only(top: r.hp(0.5), left: r.wp(1)),
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: r.dp(1.2), // Reduced from 1.4
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
