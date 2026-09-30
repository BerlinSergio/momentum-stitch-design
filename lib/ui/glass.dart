// ============================================================================
// MOMENTUM DESIGN SYSTEM — GLASS SURFACES & ATMOSPHERIC BACKDROP
// Reproduces the Stitch card treatment: translucent fill + backdrop blur +
// hairline border + inset top rim highlight + diffuse ambient shadow +
// optional internal glow orbs and mosque watermark.
// ============================================================================

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Visual tier of a glass surface (Stitch surface-card hierarchy).
enum GlassTier { base, elevated, subtle, hero }

/// Optional decorative glow orb rendered inside a glass card
/// (Stitch: "ambient card glow backdrop").
class GlassGlow {
  final Alignment alignment;
  final double size;
  final Color? color;
  const GlassGlow({this.alignment = Alignment.topRight, this.size = 176, this.color});
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GlassTier tier;
  final double? blur;
  final GlassGlow? glow;
  final bool mosqueWatermark;
  final Color? borderColor;
  final Gradient? overlayGradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(MomentumTokens.radiusMd)),
    this.onTap,
    this.onLongPress,
    this.tier = GlassTier.base,
    this.blur,
    this.glow,
    this.mosqueWatermark = false,
    this.borderColor,
    this.overlayGradient,
  });

  /// Hero bento card: 32px radius, 20px padding, deep 40px blur, glow orb.
  const GlassCard.hero({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(MomentumTokens.radiusHero)),
    this.onTap,
    this.onLongPress,
    this.blur,
    this.glow = const GlassGlow(),
    this.mosqueWatermark = false,
    this.borderColor,
    this.overlayGradient,
  }) : tier = GlassTier.hero;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final Color fill = switch (tier) {
      GlassTier.base => p.cardBase,
      GlassTier.elevated || GlassTier.hero => p.cardElevated,
      GlassTier.subtle => p.cardSubtle,
    };
    final double sigma = blur ??
        switch (tier) {
          GlassTier.hero || GlassTier.elevated => MomentumTokens.blur2xl,
          GlassTier.base => MomentumTokens.blurXl,
          GlassTier.subtle => MomentumTokens.blurMd,
        };
    final shadows = tier == GlassTier.hero ? p.heroShadow : p.cardShadow;
    final border = borderColor ?? p.hairline;

    Widget inner = Padding(padding: padding, child: child);

    inner = Stack(
      children: [
        if (glow != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: glow!.alignment,
                child: Transform.translate(
                  offset: Offset(glow!.alignment.x * glow!.size * .38, glow!.alignment.y * -glow!.size * .38),
                  child: GlassOrb(size: glow!.size, color: glow!.color ?? p.orb1, sigma: 32),
                ),
              ),
            ),
          ),
        if (mosqueWatermark)
          Positioned(
            right: -16,
            bottom: -8,
            child: IgnorePointer(
              child: Opacity(
                opacity: .14,
                child: CustomPaint(size: const Size(192, 144), painter: MosqueSilhouettePainter(color: p.primary)),
              ),
            ),
          ),
        if (overlayGradient != null)
          Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: overlayGradient)))),
        // Inset refractive top rim highlight.
        Positioned(
          top: 0,
          left: 10,
          right: 10,
          height: 1.2,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: p.dark ? .28 : .85),
                  Colors.white.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
        ),
        inner,
      ],
    );

    if (onTap != null || onLongPress != null) {
      inner = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: inner,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: borderRadius,
              border: Border.all(color: border),
            ),
            child: inner,
          ),
        ),
      ),
    );
  }
}

/// Softly blurred circular glow field.
class GlassOrb extends StatelessWidget {
  final double size;
  final double height;
  final Color color;
  final double sigma;
  const GlassOrb({super.key, required this.size, required this.color, this.sigma = 40, double? height})
      : height = height ?? size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          width: size,
          height: height,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(size), color: color),
        ),
      ),
    );
  }
}

/// Full-screen atmospheric background:
/// flat canvas → wallpaper scene (Store-controlled, blur-controlled) →
/// three Stitch-positioned glow fields → readability scrim.
class MomentumBackdrop extends StatelessWidget {
  final int wallpaperIndex;
  final double wallpaperBlur;
  final Widget child;

  const MomentumBackdrop({
    super.key,
    required this.wallpaperIndex,
    required this.wallpaperBlur,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final spec = wallpapers[wallpaperIndex.clamp(0, wallpapers.length - 1)];
    final colors = p.dark ? spec.dark : spec.light;
    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Flat theme canvas.
        ColoredBox(color: p.canvas),
        // Wallpaper scene, softened by the user-controlled blur.
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: wallpaperBlur, sigmaY: wallpaperBlur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            ),
          ),
        ),
        // Three large atmospheric glow fields (Stitch fixed layer).
        Positioned(left: -80, top: -128, child: GlassOrb(size: 384, color: p.orb1, sigma: 40)),
        Positioned(right: -96, top: size.height * .25, child: GlassOrb(size: 320, color: p.orb2, sigma: 40)),
        Positioned(
          bottom: 80,
          left: (size.width - 512) / 2,
          child: GlassOrb(size: 512, height: 288, color: p.orb3, sigma: 40),
        ),
        // Readability scrim.
        ColoredBox(color: p.scrim),
        child,
      ],
    );
  }
}

/// Elegant mosque silhouette watermark (traced from the Stitch SVG, 200x150).
class MosqueSilhouettePainter extends CustomPainter {
  final Color color;
  const MosqueSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 200;
    final sy = size.height / 150;
    canvas.scale(sx, sy);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Central dome.
    final dome = Path()
      ..moveTo(100, 20)
      ..cubicTo(95, 40, 85, 55, 85, 75)
      ..lineTo(115, 75)
      ..cubicTo(115, 55, 105, 40, 100, 20)
      ..close();
    canvas.drawPath(dome, paint);

    // Side domes.
    final left = Path()
      ..moveTo(70, 60)
      ..cubicTo(65, 72, 58, 82, 58, 95)
      ..lineTo(82, 95)
      ..cubicTo(82, 82, 75, 72, 70, 60)
      ..close();
    canvas.drawPath(left, paint);
    final right = Path()
      ..moveTo(130, 60)
      ..cubicTo(125, 72, 118, 82, 118, 95)
      ..lineTo(142, 95)
      ..cubicTo(142, 82, 135, 72, 130, 60)
      ..close();
    canvas.drawPath(right, paint);

    // Minarets.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(20, 90, 8, 60), const Radius.circular(4)), paint);
    canvas.drawPath(Path()..moveTo(24, 75)..lineTo(20, 90)..lineTo(28, 90)..close(), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(172, 90, 8, 60), const Radius.circular(4)), paint);
    canvas.drawPath(Path()..moveTo(176, 75)..lineTo(172, 90)..lineTo(180, 90)..close(), paint);

    // Main hall with arched doorways punched out.
    final hall = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(40, 95, 120, 55), const Radius.circular(6)));
    final doors = Path()
      ..addOval(Rect.fromCircle(center: const Offset(100, 120), radius: 14))
      ..addOval(Rect.fromCircle(center: const Offset(70, 124), radius: 9))
      ..addOval(Rect.fromCircle(center: const Offset(130, 124), radius: 9));
    canvas.drawPath(Path.combine(PathOperation.difference, hall, doors), paint);
  }

  @override
  bool shouldRepaint(covariant MosqueSilhouettePainter oldDelegate) => oldDelegate.color != color;
}
