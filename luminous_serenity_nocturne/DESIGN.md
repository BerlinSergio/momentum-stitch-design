---
name: Luminous Serenity Nocturne
colors:
  surface: '#0e131f'
  surface-dim: '#0e131f'
  surface-bright: '#343946'
  surface-container-lowest: '#080e1a'
  surface-container-low: '#161c28'
  surface-container: '#1a202c'
  surface-container-high: '#242a36'
  surface-container-highest: '#2f3542'
  on-surface: '#dde2f3'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#dde2f3'
  inverse-on-surface: '#2b303d'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#d0bcff'
  on-tertiary: '#3c0091'
  tertiary-container: '#a078ff'
  on-tertiary-container: '#340080'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d0bcff'
  on-tertiary-fixed: '#23005c'
  on-tertiary-fixed-variant: '#5516be'
  background: '#0e131f'
  on-background: '#dde2f3'
  surface-variant: '#2f3542'
typography:
  display-hero:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.03em
  display-hero-mobile:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
    letterSpacing: 0em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 3rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system establishes an atmospheric, contemplative dark mode that marries deep nocturnal calm with razor-sharp computational clarity. Designed for high-focus digital environments, productivity suites, and modern creative workflows, it evokes quiet power, spatial depth, and effortless immersion.

The design movement balances **Atmospheric Glassmorphism** with **Futuristic Minimalism**:
- **Surfaces:** Translucent frosted obsidian and midnight navy planes that layer optical density over dynamic ambient backdrops.
- **Lighting & Energy:** Restrained, luminous light spills—vibrant electric violet, cyan, and indigo accents that guide focus without inducing glare or visual fatigue.
- **Emotional Resonance:** Poised, cinematic, cerebral, and serene. It eliminates spatial clutter in favor of deep atmospheric contrast and pristine legibility.

## Colors

The nocturnal palette is anchored in abyssal dark values, layered with translucent acrylic treatments and punctate luminous hues.

### Primary, Secondary & Accent Roles
- **Primary (`#6366F1` - Electric Indigo):** Primary calls to action, active indicators, and high-priority interactive highlights.
- **Secondary (`#06B6D4` - Luminous Cyan):** Real-time telemetries, secondary state confirmations, success highlights, and fluid progress indicators.
- **Tertiary (`#8B5CF6` - Vivid Violet):** Ambient glows, creative state affordances, and dynamic gradient terminations.

### Surface Architecture & Neutral System
- **Void Canvas (`#030712`):** The foundational substrate representing deep cosmic midnight.
- **Obsidian Glass Base (`rgba(8, 15, 30, 0.72)`):** Level-1 container planes combined with `backdrop-filter: blur(24px)`.
- **Midnight Elevated Glass (`rgba(15, 23, 42, 0.65)`):** Level-2 floating panels, flyouts, and dynamic menus.
- **Luminous Edge Stroking (`rgba(255, 255, 255, 0.08)` to `rgba(99, 102, 241, 0.25)`):** Dual-purpose perimeter definitions preserving separation without opaque boundaries.

### Typography Hierarchy
- **High Contrast (`#F1F5F9` - Slate-100):** Headings, critical metrics, and active states.
- **Standard Text (`#E2E8F0` - Slate-200):** Primary reading content, form values, and input text.
- **Subdued & Muted (`#94A3B8` - Slate-400):** Captions, descriptive metadata, and disabled or placeholder states.

## Typography

The typographic engine balances technical geometry with humanist clarity:
- **Headlines (`Space Grotesk`):** Offers a crisp, structural visual tone that reflects architectural balance in large scale titles. Kerning is intentionally tightened at display levels to produce cohesive visual silhouettes against dark backgrounds.
- **Body Text (`Plus Jakarta Sans`):** Selected for its open apertures and generous x-height, rendering long-form copy readable against dense, light-absorbing backdrops without pixel vibration.
- **Data & Micro-Labels (`JetBrains Mono`):** Delivers clean precision to metadata, data visualization points, chips, and uppercase state labels, introducing systematic discipline into the interface.

## Layout & Spacing

The layout is built on an adaptive 12-column responsive fluid grid matched to the rhythm of the light mode counterpart. 

- **Grid Architecture:** 
  - **Desktop (1024px+):** 12 columns with `1.5rem` (`24px`) gutters and `3rem` (`48px`) global boundary margins. Maximum canvas container is pinned to `1440px` centered.
  - **Tablet (768px – 1023px):** 8 columns with `1.5rem` gutters and `2rem` margins.
  - **Mobile (< 768px):** 4 columns with `1rem` (`16px`) gutters and `1rem` (`16px`) side margins.
- **Spatial Rhythm:** Built strictly on an 8-point vertical cadence (with a 4-point micro-step: `0.25rem`). All paddings and inter-component gaps scale predictably from `space-xs` through `space-xl`.

## Elevation & Depth

Spatial elevation relies on frosted translucency, edge luminosity, and ambient back-glows rather than black drop shadows, which are ineffective on dark canvases:

- **Level 0 (Cosmic Floor):** `#030712` canvas embedded with radial gradients of soft indigo (`rgba(99, 102, 241, 0.08)`) and cyan (`rgba(6, 182, 212, 0.05)`) positioned strategically to act as background light sources.
- **Level 1 (Substrate Cards & Panels):** `rgba(8, 15, 30, 0.70)` surface with `backdrop-filter: blur(20px)` and a top-weighted border gradient of `rgba(255, 255, 255, 0.12)` descending to `rgba(255, 255, 255, 0.02)`.
- **Level 2 (Active Cards & Floating Drawers):** `rgba(15, 23, 42, 0.78)` surface with `backdrop-filter: blur(28px)`, a hairline border of `rgba(99, 102, 241, 0.30)`, and an ambient back-projected drop shadow of `0 12px 36px -8px rgba(0, 0, 0, 0.60)`.
- **Level 3 (Modals & Popovers):** `rgba(17, 24, 39, 0.90)` surface with `backdrop-filter: blur(32px)`, an omnidirectional glowing edge aura of `0 0 24px rgba(99, 102, 241, 0.18)`, and a subtle physical border of `rgba(255, 255, 255, 0.18)`.

## Shapes

The interface maintains the curvature system of the light mode counterpart to ensure absolute cross-theme parity:
- **Base Components (Inputs, Buttons, Badges):** `rounded` at `0.5rem` (`8px`) for compact balance.
- **Structured Containers (Cards, Dialogs):** `rounded-lg` at `1rem` (`16px`), framing content with continuous, soft geometric curves.
- **Hero Containers & Overlays:** `rounded-xl` at `1.5rem` (`24px`).
- **Capsule Elements (Chips, Indicator Tags):** Pill geometry (`9999px`) where continuous lateral curvature conveys distinct interactivity.

## Components

### Buttons
- **Primary:** Gradient-filled surface (`linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)`), text in `#FFFFFF`, with a continuous edge glow of `0 0 20px rgba(99, 102, 241, 0.4)`. In hover state, brightness increases by 10% and glow expands to `24px`.
- **Secondary:** Frosted obsidian base (`rgba(255, 255, 255, 0.05)`), border `1px solid rgba(255, 255, 255, 0.12)`, text `#E2E8F0`. Hover triggers cyan edge transition (`rgba(6, 182, 212, 0.4)`).
- **Ghost:** Background transparent, text `#94A3B8`, transitioning on hover to `background: rgba(255, 255, 255, 0.06)` and text `#F1F5F9`.

### Form Controls & Inputs
- **Text Inputs:** Height 44px, background `rgba(8, 15, 30, 0.60)`, border `1px solid rgba(255, 255, 255, 0.10)`, text `#F1F5F9`, placeholder `#64748B`. Focus introduces a sharp luminous boundary: `border-color: #6366F1` backed by an outer ring of `0 0 0 3px rgba(99, 102, 241, 0.20)`.
- **Checkboxes & Radios:** Dimensions 18x18px. Inactive state: `rgba(255, 255, 255, 0.08)` border, dark center. Checked state: solid `#6366F1` with an inner white checkmark, accompanied by a subtle soft-focus cyan aura.

### Chips & Badges
- **Status Badges:** Compact capsule silhouettes styled with translucent color fill (`rgba(6, 182, 212, 0.12)`), text `#06B6D4`, and a hairline inner stroke (`rgba(6, 182, 212, 0.3)`). Typography renders in `JetBrains Mono` (`label-sm`).

### Cards & Surfaces
- **Interactive Cards:** Crafted from frosted obsidian panels (`backdrop-filter: blur(20px)`). Rest state features a soft white top edge line (`rgba(255, 255, 255, 0.08)`). On hover, the border seamlessly interpolates to `rgba(99, 102, 241, 0.45)` alongside an internal radial gradient accentuating the cursor position.

### Lists & Tables
- **Rows:** Separated by low-contrast micro-dividers (`rgba(255, 255, 255, 0.05)`). Hover rows gently tint with `rgba(255, 255, 255, 0.03)` with no layout shift.