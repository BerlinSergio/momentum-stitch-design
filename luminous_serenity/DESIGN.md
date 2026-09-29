---
name: Luminous Serenity
colors:
  surface: '#faf8ff'
  surface-dim: '#d4d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#ebedff'
  surface-container-high: '#e3e7ff'
  surface-container-highest: '#dce1fd'
  on-surface: '#151b2e'
  on-surface-variant: '#444655'
  inverse-surface: '#2a3044'
  inverse-on-surface: '#eff0ff'
  outline: '#757687'
  outline-variant: '#c5c5d8'
  surface-tint: '#2d4ce2'
  primary: '#2a49df'
  on-primary: '#ffffff'
  primary-container: '#4965f9'
  on-primary-container: '#fffbff'
  inverse-primary: '#bac3ff'
  secondary: '#663bd2'
  on-secondary: '#ffffff'
  secondary-container: '#7f58ed'
  on-secondary-container: '#fffbff'
  tertiary: '#006768'
  on-tertiary: '#ffffff'
  tertiary-container: '#008283'
  on-tertiary-container: '#f3fffe'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dee0ff'
  primary-fixed-dim: '#bac3ff'
  on-primary-fixed: '#00105b'
  on-primary-fixed-variant: '#002fc9'
  secondary-fixed: '#e8ddff'
  secondary-fixed-dim: '#cebdff'
  on-secondary-fixed: '#21005e'
  on-secondary-fixed-variant: '#501dbc'
  tertiary-fixed: '#6df7f8'
  tertiary-fixed-dim: '#4bdadc'
  on-tertiary-fixed: '#002020'
  on-tertiary-fixed-variant: '#004f50'
  background: '#faf8ff'
  on-background: '#151b2e'
  surface-variant: '#dce1fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 22px
  body-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
  metric-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 0.75rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style

This design system embodies a serene, mindful lifestyle and productivity philosophy where spiritual equilibrium meets structured daily execution. Designed for individuals seeking mental clarity, intentional habit building, and calm visual relief from noisy digital environments, the interface creates an atmosphere of lightness, spaciousness, and gentle focus.

The visual direction pairs **advanced glassmorphism** with **dreamy ambient luminescence**. Floating frosted surfaces filter an ethereal sky-and-water backdrop, establishing depth through diffuse light refraction rather than artificial elevation. Every element feels weightless, polished, and breathable, invoking an emotional response of peace, mindfulness, and effortless control.

## Colors

The palette balances airy luminescence with high-clarity typography:

- **Primary (`#4F6BFF`)**: Electric soft indigo driving primary actions, selected navigation indicators, and visual accents.
- **Secondary (`#8A63F8`)**: Radiant violet used in radiant gradient blends, circular trackers, and completed habit states.
- **Tertiary (`#22C1C3`)**: Aquamarine cyan evoking tranquil water, utilized for goal progression, wellness checks, and positive streaks.
- **Neutral (`#1E2438`)**: Deep twilight indigo-charcoal for crisp, readable copy against high-translucency glass panes.

### Glass Surfaces & Accents
- **Canvas Base**: Full-screen wallpaper featuring high-key morning light over pastel clouds and water.
- **Frosted Card Fill**: `rgba(255, 255, 255, 0.72)` supported by `backdrop-filter: blur(24px) saturate(160%)`.
- **Specular Border Stroke**: `1px solid rgba(255, 255, 255, 0.85)` with a secondary inner inset highlight `rgba(255, 255, 255, 0.4)`.
- **Soft Glow Gradient**: Linear gradient `135deg, #4F6BFF 0%, #8A63F8 50%, #22C1C3 100%` reserved for key floating action touchpoints and celebratory states.
- **Subdued Text**: `rgba(30, 36, 56, 0.65)` for secondary labels and metadata; `rgba(30, 36, 56, 0.4)` for disabled states and tertiary guidance.

## Typography

Typography prioritizes pristine legibility across luminous, translucent backdrops:

- **Typeface Selection**: `Inter` provides neutral geometric proportions, tall x-height, and precise numerical glyphs essential for schedules, prayers, metrics, and checklists.
- **Hierarchy & Weight Distribution**: Bold weights are restricted to primary titles, numerical metrics, and active states. Secondary labels remain regular to medium weight to sustain a delicate, airy atmosphere.
- **Tracking & Readability**: Compact micro-labels (`label-sm`) utilize slight letter-spacing (`+0.02em`) to ensure legibility when overlaid on frosted glass. Metric displays emphasize weight over physical footprint.

## Layout & Spacing

The layout utilizes an intentional vertical stack structure optimized for touch interaction on hand-held mobile devices:

- **Rhythm**: Anchored by an outer edge margin of `16px` (`margin`) that lets the atmospheric wallpaper peek through the sides, framing the floating cards.
- **Card Padding**: Structured content containers maintain internal breathing room of `16px` to `20px` (`space-lg`), separating section headers from nested list groups.
- **Vertical Stack Gaps**: Cards maintain a clean `12px` to `14px` rhythm, avoiding claustrophobic density while sustaining visual continuity during vertical scroll.
- **Safe Zones**: Top padding accommodates the device dynamic island/notch (`54px` clearance). Bottom content includes `100px` of padding-bottom to allow unobstructed scrolling above the floating dock bar.

## Elevation & Depth

Visual hierarchy does not use opaque drop shadows or harsh elevation levels. Instead, depth is synthesized through light refraction, glass thickness, and chromatic glow:

- **Surface Level 1 (Frosted Cards)**:
  - Fill: `rgba(255, 255, 255, 0.7)` with `backdrop-filter: blur(28px) saturate(150%)`.
  - Border: `1px solid rgba(255, 255, 255, 0.85)`.
  - Shadow: Multi-layered ambient dispersion `0 10px 30px -5px rgba(80, 110, 180, 0.12), 0 2px 6px -1px rgba(255, 255, 255, 0.4) inset`.
- **Surface Level 2 (Floating Action Button / Primary Triggers)**:
  - Fill: Linear multi-stop gradient `135deg, #4F6BFF 0%, #8A63F8 50%, #22C1C3 100%`.
  - Outer Glow: `0 10px 24px -2px rgba(79, 107, 255, 0.45)`.
  - Highlight: `1.5px solid rgba(255, 255, 255, 0.6)`.
- **Surface Level 3 (Floating Bottom Nav Dock)**:
  - Fill: `rgba(255, 255, 255, 0.78)` with `backdrop-filter: blur(32px)`.
  - Outer Glow: `0 16px 40px rgba(30, 45, 90, 0.15)`.
  - Border: `1px solid rgba(255, 255, 255, 0.9)`.

## Shapes

The design system embraces an ultra-smooth, organically rounded aesthetic:

- **Large Glass Cards**: Softened with a continuous corner radius of `24px` to `28px` (`rounded-xl`), creating organic pebble-like visual tiles.
- **Buttons & Pills**: All interactive filters, tag chips, and action buttons adopt full pill profiles (`9999px`), ensuring tactile comfort.
- **Progress Circles & Rings**: Smooth radial geometry with rounded cap terminals on SVG stroke paths.
- **Dock Bar**: Sculpted pill container (`36px` border radius) floating gracefully above the bottom navigation zone.

## Components

### Glass Cards
Primary structural container. Composed of `rgba(255, 255, 255, 0.72)` background, `24px` border-radius, `1px` subtle white border, and diffuse light refraction. When used for themed modules (e.g., prayer or mindfulness), subtle monochromatic skyline or organic water motifs may tint the bottom right corner at `15%` opacity.

### Floating Bottom Navigation Bar
- A single horizontal floating island (`width: calc(100% - 32px)`), positioned `24px` above the bottom edge.
- 5 equidistant layout positions: Home, Tasks, Center Action, Earnings, Settings.
- Inactive items: `rgba(30, 36, 56, 0.5)` with `11px` micro-labels.
- Active items: Primary blue tint with a subtle back-glow circle (`rgba(79, 107, 255, 0.15)`).
- Centered Action Button (`+`): Overhanging `56px` circular button centered vertically, filled with the signature indigo-to-cyan gradient, encased in a pure white halo outline with soft radial blur.

### Circular Progress Indicators
Concentric data rings displaying percentages:
- Track: `4px` to `6px` path with `rgba(79, 107, 255, 0.12)`.
- Active Bar: Gradient stroke blending `#22C1C3` to `#8A63F8` with `stroke-linecap: round`.
- Center Content: Primary bold metric accompanied by secondary context below.

### Interactive Checklists & Routine Items
- Circular indicator (`20px`) with a soft border (`1.5px solid rgba(79, 107, 255, 0.35)`).
- Completed State: Solid fill with matching accent colors (indigo, violet, or cyan) displaying a centered white check icon.
- Content rows: Left-aligned title with right-aligned time stamps or durations rendered in muted text.

### Action Chips & Status Pills
- Micro-pills (`height: 28px`) used for secondary controls such as "+ Add Task" or "Notifications On".
- Translucent white backing (`rgba(255, 255, 255, 0.6)`) with subtle hairline border and `12px` semi-bold text.