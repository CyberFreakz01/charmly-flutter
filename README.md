# Charmly Flutter

Flutter migration of Charmly using `jeerocks/charmly` as the behavioral and visual source of truth.

## Delivered scope

- Onboarding, personalization quiz, persona selection, curriculum, chat, scoring, assist, and paywall flows.
- Persisted onboarding, quiz, persona, module, completed-module, score, and adaptive-nudge state.
- Premium gating for personas, modules, voice delivery feedback, and Rizz Assist.
- Backend clients for `/chat/reply`, `/chat/score`, and `/assist/review`.
- Explicit mock/fallback behavior for AI and RevenueCat when runtime configuration is absent.
- Speech-to-text and text-to-speech services with local-device fallback behavior.

## Runtime configuration

Configure these values with `--dart-define`:

- `CHARMLY_BACKEND_BASE_URL`
- `CHARMLY_MOCK_AI_MODE` (`true`/`false`, default `true`)
- `CHARMLY_REVENUECAT_PUBLIC_KEY`
- `CHARMLY_MOCK_PREMIUM` (`true` for local development only, default `false`)

Example:

```bash
flutter run \
  --dart-define=CHARMLY_BACKEND_BASE_URL=https://your-api.example.com \
  --dart-define=CHARMLY_MOCK_AI_MODE=false \
  --dart-define=CHARMLY_REVENUECAT_PUBLIC_KEY=appl_xxx
```

## Quality checks

```bash
dart format .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Platform microphone and speech-recognition permissions must be configured locally for voice features. RevenueCat offerings and product IDs must also be configured in the target store environments.
