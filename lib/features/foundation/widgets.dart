import 'package:flutter/material.dart';

import '../../app/charmly_theme.dart';
import '../../core/charmly_models.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CharmlyTokens.primary,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.favorite, size: size * 0.52, color: CharmlyTokens.background),
    );
  }
}

class CharmlyHeader extends StatelessWidget {
  const CharmlyHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: CharmlyTokens.mutedForeground),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: CharmlyTokens.primary,
          foregroundColor: CharmlyTokens.background,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CharmlyTokens.radius),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: CharmlyTokens.foreground,
          side: const BorderSide(color: CharmlyTokens.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CharmlyTokens.radius),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(CharmlyTokens.radius),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CharmlyTokens.muted,
          borderRadius: BorderRadius.circular(CharmlyTokens.radius),
          border: Border.all(color: value ? CharmlyTokens.primary : CharmlyTokens.border),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              color: value ? CharmlyTokens.primary : CharmlyTokens.mutedForeground,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

class ProgressSegments extends StatelessWidget {
  const ProgressSegments({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        total,
        (index) => Expanded(
          child: Container(
            height: 7,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: index <= current ? CharmlyTokens.primary : CharmlyTokens.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class PersonaCard extends StatelessWidget {
  const PersonaCard({
    super.key,
    required this.persona,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final Persona persona;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.65 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CharmlyTokens.radius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CharmlyTokens.card,
            borderRadius: BorderRadius.circular(CharmlyTokens.radius),
            border: Border.all(color: selected ? CharmlyTokens.primary : CharmlyTokens.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Image.asset(
                  persona.assetPath,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 68,
                    height: 68,
                    color: CharmlyTokens.secondary,
                    alignment: Alignment.center,
                    child: const Icon(Icons.person, color: CharmlyTokens.foreground),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tierLabel(persona.tier).toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 11,
                            color: tierColor(persona.tier),
                          ),
                        ),
                        if (locked) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.lock, size: 14, color: CharmlyTokens.mutedForeground),
                        ],
                      ],
                    ),
                    Text(persona.name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      persona.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: CharmlyTokens.mutedForeground),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock : selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? CharmlyTokens.primary : CharmlyTokens.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurriculumModuleRow extends StatelessWidget {
  const CurriculumModuleRow({
    super.key,
    required this.module,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final CurriculumModule module;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CharmlyTokens.radius),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CharmlyTokens.card,
          borderRadius: BorderRadius.circular(CharmlyTokens.radius),
          border: Border.all(color: selected ? CharmlyTokens.primary : CharmlyTokens.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(module.name, style: Theme.of(context).textTheme.titleMedium),
                      if (module.premium) ...[
                        const SizedBox(width: 8),
                        Text(
                          'PREMIUM',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 10,
                            color: CharmlyTokens.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.goal,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: CharmlyTokens.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              locked ? Icons.lock : selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: locked
                  ? CharmlyTokens.mutedForeground
                  : selected
                      ? CharmlyTokens.primary
                      : CharmlyTokens.accent,
            ),
          ],
        ),
      ),
    );
  }
}
