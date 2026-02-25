# BioID Flutter Demo

A Flutter showcase app for Sybrin's **Identity**, **Liveness Detection**, and **Facial Comparison** SDKs — Android only.

---

## Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | ≥ 3.2.0 |
| Android SDK | API 24+ (Android 7.0) |
| Java | 17 |
| Sybrin Maven credentials | Required — contact Sybrin |

---

## 1. Clone & install dependencies

```bash
git clone <repo-url>
cd bioid_flutter
flutter pub get
```

---

## 2. Configure Sybrin Maven credentials

The Sybrin Identity SDK is hosted on a private GitHub Maven repository. Credentials are read from `android/local.properties` at build time — this file is **gitignored and must never be committed**.

Add the following to `android/local.properties` (create it if it doesn't exist):

```properties
sdk.dir=/path/to/your/Android/Sdk
sybrin.username=YOUR_GITHUB_USERNAME
sybrin.token=YOUR_GITHUB_PERSONAL_ACCESS_TOKEN
```

The token needs **`read:packages`** scope on GitHub. Sybrin will provide the token for the demo environment — contact your Sybrin representative if you don't have one.

> `android/build.gradle.kts` reads `sybrin.username` and `sybrin.token` automatically. No other changes needed.

---

## 3. Set SDK license keys

License keys live in one file:

```
android/app/src/main/kotlin/com/demo/bioid_flutter/SDKConfig.kt
```

Replace the placeholder strings with your environment's keys:

```kotlin
object SDKConfig {
    const val IDENTITY_KEY   = "YOUR_IDENTITY_LICENSE_KEY"
    const val BIOMETRICS_KEY = "YOUR_BIOMETRICS_LICENSE_KEY"
}
```

> Keys are environment-specific. Use development keys for testing; production keys require a separate Sybrin licence agreement.

---

## 4. Run the app

Connect a physical Android device (API 24+) — the Sybrin camera SDKs do not work on emulators.

```bash
flutter run
```

For a release build:

```bash
flutter build apk --release
```

---

## 5. Feature flags

By default, **Biometrics features are enabled** and **Identity features are disabled**. Enable Identity features in-app via **Settings** (top-right on the home screen).

| Feature | Default | SDK Used |
|---|---|---|
| Green Book scan | ❌ Off | Sybrin Identity |
| Passport scan | ❌ Off | Sybrin Identity |
| ID Card scan | ❌ Off | Sybrin Identity |
| Liveness Detection | ✅ On | Sybrin Biometrics |
| Face Comparison | ✅ On | Sybrin Biometrics |

---

## 6. Testing each feature

### Identity scanning
1. Enable the desired document type in **Settings**.
2. Tap the feature card on the home screen.
3. Hold the document steady in front of the camera — the SDK handles capture automatically.
4. Results (OCR fields + portrait) are shown on the Result screen.

### Liveness Detection
1. Tap **Liveness Detection** on the home screen.
2. Hold the device at face level — passive detection, no gestures needed.
3. Result shows confidence score (0–100%).

### Face Comparison
1. Tap **Face Comparison** on the home screen.
2. Tap the **Reference Face** panel → choose camera or gallery.
3. Tap the **Selfie / Probe** panel → choose camera or gallery.
4. Tap **Compare Faces** — result shows average similarity score.

---

## Project structure

```
bioid_flutter/
├── lib/
│   ├── config/sdk_config.dart        # Flutter-side feature flag defaults
│   ├── screens/                      # One file per screen
│   ├── providers/                    # State management (Provider)
│   ├── services/sybrin_channel.dart  # MethodChannel bridge (Dart side)
│   └── theme/app_theme.dart          # Centralised design tokens
└── android/app/src/main/kotlin/
    ├── MainActivity.kt               # MethodChannel handler + SDK calls
    └── SDKConfig.kt                  # License keys ← edit this
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Build fails: `Could not resolve com.github.sybrin-innovations:…` | Check `local.properties` credentials; token must have `read:packages` scope |
| SDK init fails at launch | Verify license keys in `SDKConfig.kt` match the target environment |
| Camera doesn't open | Use a **physical device** — emulators are not supported |
| Features greyed out | Enable them in **Settings** |
