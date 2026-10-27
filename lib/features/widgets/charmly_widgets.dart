import 'package:flutter/material.dart';

import '../../core/theme/charmly_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.14,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: CharmlyColors.primary,
          borderRadius: BorderRadius.circular(size / 3),
        ),
        child: Center(
          child: Transform.rotate(
            angle: 0.14,
            child: Container(
              width: size * 0.46,
              height: size * 0.34,
              decoration: BoxDecoration(
                color: CharmlyColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _Dot(),
                  SizedBox(width: 3),
                  _Dot(),
                  SizedBox(width: 3),
                  _Dot(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: CharmlyColors.background,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: icon == null ? const SizedBox.shrink() : Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: CharmlyColors.primary,
            foregroundColor: CharmlyColors.primaryForeground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: CharmlyColors.secondary,
          foregroundColor: CharmlyColors.foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
