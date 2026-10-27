# charmly-flutter

Phase 1 Flutter foundation for migrating `jeerocks/charmly` (Expo/React Native) into `CyberFreakz01/charmly-flutter`.

## Scope completed in Phase 1

- Conventional Flutter foundation files: `lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml`, Android/iOS folder scaffolding.
- Charmly theme tokens from source:
  - background `#1B1324`
  - foreground `#FFF7F1`
  - card `#281B34`
  - primary `#FF8A75`
  - secondary `#382744`
  - muted `#30203D`
  - muted foreground `#BBAABD`
  - accent `#BBA1FF`
  - border `#453453`
  - input `#594366`
  - radius `18`
- Phase 1 product flow with local state:
  - loading
  - age + terms onboarding (both required)
  - required 3-step personalization quiz
  - persona selection (6 personas, Easy/Medium/Hard tiers)
  - five-module curriculum with premium lock visuals
- Behavior parity for this phase:
  - onboarding blocks until age + terms are confirmed
  - each quiz step requires a selection
  - free content selectable
  - premium personas/modules shown as locked and unavailable
- Reusable widgets:
  - brand mark
  - primary/secondary buttons
  - screen header
  - check row
  - progress segments
  - persona card
  - curriculum module row
- Local persistence via `shared_preferences` for:
  - onboarding completion
  - quiz answers
  - selected persona
  - selected module
- Tests added for design tokens and onboarding/quiz transitions.

## Project structure

- `lib/app/` theme + app wiring
- `lib/core/` source-mapped personas/modules/quiz models
- `lib/features/foundation/` Phase 1 state, storage, widgets
- `test/theme/` design token checks
- `test/state/` onboarding/quiz/premium-lock behavior checks

## Source mapping (reference only)

Source repository was not modified. Data/tokens were mapped from:

- `jeerocks/charmly/artifacts/charmly/constants/colors.ts`
- `jeerocks/charmly/artifacts/charmly/app/index.tsx`

Persona image sources in reference repo:

- `artifacts/charmly/assets/images/persona-maya.png`
- `artifacts/charmly/assets/images/persona-sofia.png`
- `artifacts/charmly/assets/images/persona-elena.png`
- `artifacts/charmly/assets/images/persona-jake.png`
- `artifacts/charmly/assets/images/persona-ethan.png`
- `artifacts/charmly/assets/images/persona-marcus.png`

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Notes about this cloud environment

Flutter SDK was not available in this session, so `flutter format`, `flutter analyze`, and `flutter test` could not be executed here.

## Later phases (not implemented in Phase 1)

- Gemini integration
- speech recognition / TTS
- RevenueCat purchases / entitlement unlocks
- backend/API migration
- chat/session scoring/rizz assist screens and logic
- screenshot-based pixel validation
