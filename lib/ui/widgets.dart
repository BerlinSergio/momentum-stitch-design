// ============================================================================
// MOMENTUM DESIGN SYSTEM — SHARED COMPONENT ATOMS
// Pills, chips, icon bubbles, metric columns, progress bars, search fields,
// grouped settings rows, gradient buttons — the Stitch component library.
// ============================================================================

import 'package:flutter/material.dart';

import 'glass.dart';
import 'symbols.dart';
import 'tokens.dart';

/// Circular tinted icon chip (Stitch: `w-8/9/10/11 h-* rounded-full bg-x/10`).
class IconBubble extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? background;
  final double? iconSize;
  final double fill;
  final Gradient? gradient;

  const IconBubble(
    this.icon, {
    super.key,
    this.size = 32,
    this.color,
    this.background,
    this.iconSize,
    this.fill = 0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final c = color ?? p.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradient == null ? (background ?? c.withValues(alpha: p.dark ? .18 : .10)) : null,
        gradient: gradient,
      ),
      child: Icon(icon, size: iconSize ?? size * .56, color: gradient == null ? c : Colors.white, fill: fill),
    );
  }
}

/// Small rounded status pill (Stitch: `px-2.5 py-1 rounded-full`).
class StatusPill extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? background;
  final IconData? icon;
  final bool solid;

  const StatusPill(this.label, {super.key, this.color, this.background, this.icon, this.solid = false});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final c = color ?? p.accentText;
    final bg = solid ? (color ?? p.primary) : (background ?? (color ?? p.primary).withValues(alpha: p.dark ? .22 : .12));
    final fg = solid ? Colors.white : c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: bg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg, fill: 1), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600, letterSpacing: .3, color: fg)),
        ],
      ),
    );
  }
}

/// Uppercase overline label (Stitch: `label-sm uppercase tracking-wider text-primary`).
class Overline extends StatelessWidget {
  final String text;
  final Color? color;
  const Overline(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Text(
      text.toUpperCase(),
      style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: color ?? p.accentText),
    );
  }
}

/// Inset linear progress track with tri-color gradient fill.
/// (The only approved progress visual — never rings or charts.)
class GradientProgressBar extends StatelessWidget {
  final double value;
  final double height;
  const GradientProgressBar({super.key, required this.value, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(1.5),
        color: p.textPrimary.withValues(alpha: p.dark ? .10 : .07),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), gradient: p.triGradient),
            ),
          ),
        ),
      ),
    );
  }
}

/// One column of the Financial Health bento (label / value / trend footer).
class MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData footerIcon;
  final String footerText;
  final Color? valueColor;
  final Color? footerColor;

  const MetricColumn({
    super.key,
    required this.label,
    required this.value,
    required this.footerIcon,
    required this.footerText,
    this.valueColor,
    this.footerColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: p.textSecondary)),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -.3, color: valueColor ?? p.textPrimary)),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(footerIcon, size: 14, color: footerColor ?? p.textSecondary),
            const SizedBox(width: 3),
            Flexible(
              child: Text(footerText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: footerColor ?? p.textSecondary)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Vertical hairline between metric columns.
class MetricDivider extends StatelessWidget {
  const MetricDivider({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(width: 1, height: 52, margin: const EdgeInsets.symmetric(horizontal: 10), color: p.textPrimary.withValues(alpha: .10));
  }
}

/// Frosted rounded search input (Stitch search bars).
class MSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  const MSearchField({super.key, required this.hint, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: p.cardBase,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.hairline),
        boxShadow: p.cardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: p.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(MSym.search, size: 20, color: p.textTertiary),
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

/// Selectable category / filter pill.
class MChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const MChoicePill({super.key, required this.label, required this.selected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? p.primary : p.cardBase,
          border: Border.all(color: selected ? Colors.transparent : p.hairline),
          boxShadow: selected
              ? [BoxShadow(color: p.primary.withValues(alpha: .35), blurRadius: 14, spreadRadius: -2, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? Colors.white : p.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : p.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

/// Small gradient action pill (Stitch: inline "Add Task" trigger).
class ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const ActionPill({super.key, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: p.primaryGradient,
          boxShadow: [BoxShadow(color: p.primary.withValues(alpha: .35), blurRadius: 14, spreadRadius: -2, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Full-width primary CTA with brand gradient + glow (Stitch save buttons).
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  const GradientButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 50});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MomentumTokens.radiusMd),
          gradient: p.primaryGradient,
          boxShadow: enabled ? p.fabGlow : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(MomentumTokens.radiusMd),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 19, color: Colors.white), const SizedBox(width: 7)],
                  Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Section header row above a card group.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  const SectionHeader(this.title, {super.key, this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(trailing!, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: p.accentText)),
            ),
        ],
      ),
    );
  }
}

/// One row inside a grouped settings / list card.
class MomentumRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final double fill;

  const MomentumRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.fill = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final c = destructive ? p.danger : (iconColor ?? p.primary);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
      child: Row(
        children: [
          if (icon != null) ...[
            IconBubble(icon!, size: 40, color: c, fill: fill),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: destructive ? p.danger : p.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing! else if (onTap != null) Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
        ],
      ),
    );
    if (onTap == null) return row;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(borderRadius: BorderRadius.circular(MomentumTokens.radiusSm), onTap: onTap, child: row),
    );
  }
}

/// Grouped settings card: rows separated by hairline dividers.
class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  const SettingsGroup({super.key, required this.children, this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4)});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) rows.add(Divider(color: p.divider, height: 1));
    }
    return GlassCard(padding: padding, child: Column(children: rows));
  }
}

/// Inset subtle row container (Stitch: `bg-surface-container-low/50 rounded-DEFAULT`).
class InsetRow extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius radius;
  const InsetRow({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    this.color,
    this.radius = const BorderRadius.all(Radius.circular(MomentumTokens.radiusMd)),
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(color: color ?? p.cardSubtle, borderRadius: radius),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(borderRadius: radius, onTap: onTap, child: box),
    );
  }
}
