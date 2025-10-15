# FE / UI Agent Plan

## Objective
Deliver a calm, tactile interface that embodies Marc Andreessen’s three-list ritual across iOS and web. The FE/UI agent owns the visual system, interactive patterns, and user journey after receiving API contracts and domain models from the core team.

## Guiding principles
- **Clarity first**: Each list (Todo, Watch, Later) must be easily distinguishable yet visually cohesive. Minimalist color coding, clear typography, generous spacing.
- **Ritual cues**: Nightly planning and daily wrap-up should feel ceremonial—subtle transitions, haptic moments, and celebratory micro-interactions.
- **Momentum feedback**: Anti-Todo entries should trigger positive reinforcement without being distracting.
- **Cross-device harmony**: Shared design tokens ensure parity between web and iOS while respecting platform conventions.

## Deliverables
1. **Component library**
   - Core list primitives (card, row, tag, progress indicators).
   - 3x5 focus card layout with front/back flipping metaphor.
   - Anti-Todo timeline widgets with celebratory states.
   - Structured procrastination suggestion panel.
2. **Design tokens**
   - Color palette, typography scale, spacing units, elevation, motion curves.
   - Platform-specific adaptations (Dynamic Type, dark mode).
3. **Interaction flows**
   - First-run experience with guided setup.
   - Nightly planning wizard (collect metrics, suggestions, confirmations).
   - Daytime cockpit (list overview, quick capture, Anti-Todo logging).
   - Reflection modal at day end with share/export option.
4. **Accessibility & motion guidelines**
   - WCAG 2.2 AA compliance baseline.
   - Reduced-motion preferences, voice control flows, focus order.
5. **Production hand-off**
   - Annotated Figma/Zeplin spec with variants and responsive behaviors.
   - Tokens exported to code (Style Dictionary or Tailwind config).
   - UI test plan covering focus card creation, Anti-Todo entry, and list triage.

## Dependencies
- API schema (`services/api/src/routes`) for data contracts.
- SwiftUI view architecture skeleton (`apps/ios/AndreApp`).
- Web tech stack (recommended: React + Remix + Tailwind + Framer Motion).
- Structured procrastination endpoint `/v1/suggestions/structured-procrastination` for quick-win recommendations.

## Sequencing
1. Workshop rituals with product + backend teams, refine persona journeys.
2. Establish design tokens and core list components.
3. Prototype focus card flow in Figma, validate with 5 user tests.
4. Iterate on Anti-Todo timeline interactions + shareable summary.
5. Finalize desktop + mobile web breakpoints, then hand off specs & Storybook stories.
