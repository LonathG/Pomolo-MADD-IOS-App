# Pomolo Design System — Simplified LoginUI Specification

> **Source**: Stitch Design MD & Screen `bdf25226bc7a477d83471ed7ed292e76` ("Authentication - Login")  
> **Status**: Verified Single Source of Truth for SwiftUI Implementation  

---

## 1. Design Principles & Minimalist Constraints
- **Zero Distractions**: No top navigation bar, back arrows, or extraneous widgets.
- **Brand Hero Anchor**: Isolated 64×64 rounded Pomolo logo centered above a bold "Welcome back" greeting.
- **Adaptive Canvas**: Harmonious off-white `#F8F4EE` canvas with tactile contrast cards and buttons.
- **Focused Action**: Vibrant Orange `#FF7A1A` reserved strictly for the primary "Log in" action button.
- **Dark Mode Pairing**: Seamless semantic color inversion between Light Mode and Dark Mode.

---

## 2. Color Palette & Token Reference

| Semantic Token | Light Mode Hex | Dark Mode Hex | Usage |
|---|---|---|---|
| `pomoloCanvas` | `#F8F4EE` | `#131315` | Full-screen background canvas |
| `pomoloCard` | `#FFFFFF` | `#1C1B1D` | Input containers, Google SSO button |
| `pomoloCardElevated` | `#F0EDED` | `#252427` | Subtle border and elevation |
| `pomoloTextPrimary` | `#2A2A2A` | `#F8F4EE` | "Welcome back" headline, input text, Google button text |
| `pomoloTextSecondary` | `#6B6661` | `#CFC2D6` | Placeholders, "or continue with", footer link prefix |
| `pomoloOrange` | `#FF7A1A` | `#FF7A1A` | Primary "Log in" CTA button, "Sign Up" highlight text |
| `pomoloSoftPeach` | `#FFD7B0` | `#5E2700` | Accent glow & secondary touch states |
| `pomoloBorder` | `#E4E2E1` | `#333235` | Hairline divider line, subtle input field strokes |
| `pomoloAppleButton` | `#2A2A2A` | `#FFFFFF` | Sign in with Apple background |
| `pomoloAppleText` | `#FFFFFF` | `#131315` | Sign in with Apple foreground text & logo |

---

## 3. Typography & Dynamic Type Specifications

All typography is built on native Apple system fonts (San Francisco) mapped to the Stitch `Inter` scale, utilizing `@ScaledMetric` for accessibility:

| Role | Font / Weight | Size | Tracking | Dynamic Type Style |
|---|---|---|---|---|
| **Header Title** | Bold (`.bold`) | 28pt | `-0.02em` (`-0.5pt`) | `.title` / `.title2` |
| **Input Text** | Medium (`.medium`) | 15pt | `0.0em` | `.body` / `.callout` |
| **Button Primary** | Bold (`.bold`) | 17pt | `-0.01em` (`-0.2pt`) | `.headline` |
| **SSO Buttons** | Semibold (`.semibold`) | 16pt | `-0.005em` | `.callout` |
| **Divider Label** | Semibold (`.semibold`) | 11pt | `+0.04em` (`+0.6pt`) | `.caption2` (Uppercase) |
| **Footnote / Link** | Regular / Semibold | 13pt / 14pt | `0.01em` | `.footnote` / `.subheadline` |

---

## 4. Component Layout & Spacing Metrics

- **Screen Margins**: Horizontal padding `24pt` (`margin-tablet`/adaptive).
- **Brand Hero**:
  - Logo Box: `64pt × 64pt`, corner radius `18pt` (`.continuous`), background `#FFFFFF` / `pomoloCard`, shadow `color: .black.opacity(0.06), radius: 10, y: 4`.
  - Inner Logo: `44pt × 44pt` fitted image.
  - Spacing below logo: `16pt`.
  - Spacing below header: `32pt`.
- **Input Fields**:
  - Background: Pure `#FFFFFF` (`pomoloCard`) in Light Mode, `#1C1B1D` in Dark Mode.
  - Height / Padding: Vertical padding `16pt`, horizontal padding `16pt`.
  - Corner Radius: `16pt` (`.continuous`).
  - Subtle Drop Shadow: `color: .black.opacity(0.04), radius: 6, y: 2`.
  - Subtle Border: `0.5pt` stroke of `pomoloBorder`.
  - Eye Toggle Button: `32pt × 32pt` touch target for password reveal.
- **Forgot Password**:
  - Alignment: Trailing right.
  - Spacing: `8pt` below password field.
- **Primary "Log in" CTA**:
  - Background: Vibrant Orange `#FF7A1A`.
  - Foreground: White `#FFFFFF`.
  - Corner Radius: Capsule (`9999pt` / `.capsule`).
  - Height / Padding: Vertical `16pt`, full horizontal stretch.
  - Shadow: `color: Color(hex: "#FF7A1A").opacity(0.28), radius: 12, y: 6`.
  - Press Animation: Scale to `0.98` with spring animation.
- **Divider ("OR CONTINUE WITH")**:
  - Spacing: Top & bottom `24pt`.
  - Hairline: `1pt` height, color `pomoloBorder`.
  - Label: Centered with background capsule matching canvas for clean text cutout.
- **SSO Buttons**:
  - **Apple**: Background `#2A2A2A` (Light) / `#FFFFFF` (Dark), Text & Icon inverted. Height `52pt`, Corner Radius: Capsule (`.capsule`).
  - **Google**: Background `#FFFFFF` (Light) / `#1C1B1D` (Dark), Text `pomoloTextPrimary`, Google 4-color SVG/Glyph, border `0.5pt` stroke of `pomoloBorder`. Height `52pt`, Corner Radius: Capsule (`.capsule`).
- **Footer**:
  - Text: "Don't have an account? Sign Up"
  - Spacing: Pushed cleanly towards bottom with adaptive spacer (`24pt+`).
