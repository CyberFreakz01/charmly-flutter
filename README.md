# charmly-flutter

Flutter migration of Charmly using `jeerocks/charmly` as behavioral/visual source-of-truth.

## Current scope delivered

- Full app flow screens: loading, onboarding, quiz, personas, curriculum, chat, score, assist, paywall
- Persisted onboarding/quiz/persona/module/completed-modules/last-score/adaptive-nudge
- Premium gating and locked states for persona/module/assist/delivery feedback
- Chat composer with typing state, retry, end-session scoring flow, and last-score display
- Backend-contract client for `/chat/reply`, `/chat/score`, `/assist/review`
- Explicit mock/fallback mode for AI and paywall when backend/RevenueCat are not configured
- Voice interfaces for speech-to-text and text-to-speech with local-device fallback behavior
- RevenueCat adapter via runtime configuration (no hardcoded private keys)
- Basic unit tests for controller transitions and parsing/fallback behavior

## Runtime configuration (no secrets in source)

Use `--dart-define` values at run/build time:

- `CHARMLY_BACKEND_BASE_URL` (example: `https://api.example.com`)
- `CHARMLY_MOCK_AI_MODE` (`true`/`false`, default `true`)
- `CHARMLY_REVENUECAT_PUBLIC_KEY` (public SDK key only)
- `CHARMLY_MOCK_PREMIUM` (`true` for local dev only, default `false`)

Example:

```bash
flutter run \
  --dart-define=CHARMLY_BACKEND_BASE_URL=https://your-api.example.com \
  --dart-define=CHARMLY_MOCK_AI_MODE=false \
  --dart-define=CHARMLY_REVENUECAT_PUBLIC_KEY=appl_xxx
```

## Backend contracts required

The Flutter client expects:

### `POST /chat/reply`

Request:

```json
{
  "persona": "maya",
  "module": "opener",
  "safety_prompt": "...",
  "messages": [{ "role": "user", "text": "..." }]
}
```

Response:

```json
{ "reply": "..." }
```

### `POST /chat/score`

Request:

```json
{
  "persona": "maya",
  "module": "opener",
  "voice_used": true,
  "transcript": "User: ..."
}
```

Response:

```json
{
  "score": 0,
  "feedback": ["...", "...", "..."],
  "delivery_note": "..."
}
```

### `POST /assist/review`

Request:

```json
{ "transcript": "..." }
```

Response:

```json
{ "working": "...", "next": "...", "watch": "..." }
```

## Voice setup

Dependencies are wired through interfaces:

- `speech_to_text`
- `flutter_tts`

Add platform permissions locally:

- Android: microphone permission in `AndroidManifest.xml`
- iOS: `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription` in `Info.plist`

If voice is unavailable, UI falls back to text input.

## RevenueCat/paywall setup

- Configure only via `CHARMLY_REVENUECAT_PUBLIC_KEY`
- No secret/private key in source
- Mock entitlement mode is explicit and off by default (`CHARMLY_MOCK_PREMIUM=false`)

## Testing / quality commands

Run locally where Flutter SDK is installed:

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

This environment did not include Flutter/Dart CLI, so those commands could not be executed here.

## Visual QA and migration checklist

- Source token colors/rounded shape model mirrored from `jeerocks/charmly`
- Persona image assets copied from source app
- Screen-level parity implemented for onboarding → paywall states
- Add golden/screenshot baselines locally for target devices before claiming pixel-perfect completion

Recommended baseline devices:

- iPhone 15 Pro (393×852)
- Pixel 8 (412×915)

## Known limitations to verify locally

- Final typography fidelity (Inter weights) and animation micro-timing
- RevenueCat offerings/product IDs in real store environments
- Speech engine availability differences by platform/device
- Full backend integration behavior against production endpoints
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
