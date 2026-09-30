// ============================================================================
// MOMENTUM DESIGN SYSTEM — APP CHROME
// Pinned frosted tab header, 56px sub-page bar with 40px circular back button,
// and the floating full-pill bottom dock with the centered 56px `+` medallion.
// ============================================================================

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'symbols.dart';
import 'tokens.dart';

/// Height of the fixed chrome (status bar + 56px bar) at [context].
double topChromeHeight(BuildContext context) =>
    MediaQuery.paddingOf(context).top + MomentumTokens.topBarHeight;

/// Standard scroll padding for a Momentum page body.
/// Use `dock: true` on main-tab pages so content clears the floating dock.
EdgeInsets pagePadding(BuildContext context, {bool dock = false, double top = 14, double? bottom}) {
  final mq = MediaQuery.paddingOf(context);
  final b = bottom ?? (dock ? mq.bottom + MomentumTokens.dockClearance : mq.bottom + 28);
  return EdgeInsets.fromLTRB(MomentumTokens.gutter, topChromeHeight(context) + top, MomentumTokens.gutter, b);
}

/// Shared frosted shell for both header variants.
class _FrostedTopShell extends StatelessWidget {
  final Widget child;
  const _FrostedTopShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: p.dark ? Colors.black.withValues(alpha: .35) : const Color.fromRGBO(42, 73, 223, .06),
            blurRadius: 12,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: MomentumTokens.blurXl, sigmaY: MomentumTokens.blurXl),
          child: Container(
            color: p.headerSurface,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: MomentumTokens.topBarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MomentumTokens.gutter),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pinned main-tab header: logo bubble + left title, bell + avatar cluster.
class MomentumHeaderBar extends StatelessWidget {
  final String title;
  final String avatarInitial;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onBellTap;

  const MomentumHeaderBar({
    super.key,
    required this.title,
    required this.avatarInitial,
    this.onAvatarTap,
    this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return _FrostedTopShell(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: p.primary.withValues(alpha: p.dark ? .24 : .14)),
            child: Icon(MSym.bubbleChart, size: 20, color: p.accentText),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -.2, color: p.textPrimary)),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: onBellTap,
              icon: Icon(MSym.notifications, size: 22, color: p.textSecondary),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.primary,
                boxShadow: [BoxShadow(color: p.primary.withValues(alpha: .25), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: Text(avatarInitial,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sub-page bar: 40px circular back button, optically centered title,
/// balanced right slot (action or 40px spacer).
class SubPageBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const SubPageBar({super.key, required this.title, this.onBack, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return _FrostedTopShell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            left: 52,
            right: 52,
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -.2, color: p.textPrimary),
              ),
            ),
          ),
          Row(
            children: [
              if (onBack != null)
                _CircleTap(icon: MSym.arrowBack, onTap: onBack!)
              else
                const SizedBox(width: MomentumTokens.backButton),
              const Spacer(),
              if (actions.isEmpty)
                const SizedBox(width: MomentumTokens.backButton)
              else
                Row(mainAxisSize: MainAxisSize.min, children: actions),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleTap extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleTap({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: MomentumTokens.backButton,
          height: MomentumTokens.backButton,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: p.cardBase,
            border: Border.all(color: p.hairline),
          ),
          child: Icon(icon, size: 20, color: p.textPrimary),
        ),
      ),
    );
  }
}

/// Circular action for the right slot of [SubPageBar].
class TopBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const TopBarAction({super.key, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => _CircleTap(icon: icon, onTap: onTap);
}

/// Floating full-pill bottom dock.
/// Slots: Home | Finance | (+) | Tasks | More — the `+` is mathematically
/// centered, 56px, lifted 20px above the rim, tri-gradient with halo ring.
class MomentumDock extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTab;
  final VoidCallback onCenter;

  const MomentumDock({super.key, required this.activeTab, required this.onTab, required this.onCenter});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(MomentumTokens.gutter, 4, MomentumTokens.gutter, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: SizedBox(
            height: MomentumTokens.dockHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Pill enclosure (frosted).
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(MomentumTokens.radiusDock), boxShadow: p.dockShadow),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MomentumTokens.radiusDock),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: MomentumTokens.blur2xl, sigmaY: MomentumTokens.blur2xl),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: p.dock,
                            borderRadius: BorderRadius.circular(MomentumTokens.radiusDock),
                            border: Border.all(color: p.dark ? Colors.white.withValues(alpha: .08) : Colors.white.withValues(alpha: .82)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                _tab(context, 0, MSym.home, 'Home'),
                                _tab(context, 1, MSym.accountBalanceWallet, 'Finance'),
                                // Reserved center gap keeps `+` mathematically centered.
                                const SizedBox(width: MomentumTokens.centerButton + 12),
                                _tab(context, 3, MSym.checklist, 'Tasks'),
                                _tab(context, 4, MSym.gridView, 'More'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Centered floating `+` medallion.
                Positioned(
                  top: -MomentumTokens.centerButtonLift,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: onCenter,
                      child: Container(
                        width: MomentumTokens.centerButton + 8,
                        height: MomentumTokens.centerButton + 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.dark ? p.canvas.withValues(alpha: .90) : Colors.white.withValues(alpha: .92),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: p.triGradientDiagonal,
                            boxShadow: p.fabGlow,
                          ),
                          child: const Icon(MSym.add, size: 27, color: Colors.white, weight: 600),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int index, IconData icon, String label) {
    final p = Pal.of(context);
    final selected = activeTab == index;
    final color = selected ? p.accentText : p.textTertiary;
    return Expanded(
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: selected ? p.primary.withValues(alpha: p.dark ? .26 : .13) : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: color, fill: selected ? 1 : 0),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5,
                      height: 1.2,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
