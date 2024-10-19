import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class Button extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget child;

  final Widget? leading;
  final Widget? trailing;

  final EdgeInsets padding;
  final BorderRadius borderRadius;

  final Color? backgroundColor;
  final Color? foregroundColor;

  const Button({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    late final EdgeInsets padding;

    if (trailing != null || leading != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8.0),
          ],
          this.child,
          if (trailing != null) ...[
            const SizedBox(width: 8.0),
            trailing!,
          ],
        ],
      );
      padding = this.padding.copyWith(
            left: this.padding.left - (leading != null ? 4.0 : 0.0),
            right: this.padding.right - (trailing != null ? 4.0 : 0.0),
          );
    } else {
      child = this.child;
      padding = this.padding;
    }

    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      color: onTap == null && onLongPress == null
          ? context.colorScheme.onSurface.withOpacity(0.38)
          : null,
      builder: (context) => InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
