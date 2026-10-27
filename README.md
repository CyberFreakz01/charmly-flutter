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
