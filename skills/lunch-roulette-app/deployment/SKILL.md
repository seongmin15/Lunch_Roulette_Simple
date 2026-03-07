# Deployment — Flutter

> This skill defines deployment rules for the **lunch-roulette-app** service.
> Distribution: **** | Update: ****

---

## 1. Build & Package

```bash
# iOS
flutter build ios --release

# Android (APK)
flutter build apk --release

# Android (App Bundle — preferred for Play Store)
flutter build appbundle --release
```

**Rules:**
- Always commit `pubspec.lock`.
- Use `flutter pub get` (not `flutter pub upgrade`) in CI for reproducible builds.
- Pin Flutter SDK version in CI (use FVM or `.flutter-version` file).
- Run `flutter doctor` to verify toolchain before first CI setup.

---

## 2. App Signing

### iOS
- Use Xcode managed signing for development.
- Use match (fastlane) or manual profiles for CI/distribution.
- Never commit certificates or provisioning profiles to git.

### Android
- Store keystore file outside the repo.
- Reference keystore path and passwords via environment variables.

```groovy
// android/app/build.gradle
signingConfigs {
    release {
        storeFile file(System.getenv("RELEASE_STORE_FILE") ?: "release.keystore")
        storePassword System.getenv("RELEASE_STORE_PASSWORD")
        keyAlias System.getenv("RELEASE_KEY_ALIAS")
        keyPassword System.getenv("RELEASE_KEY_PASSWORD")
    }
}
```

**Rules:**
- Never hardcode signing credentials in build files.
- Use `--obfuscate --split-debug-info=build/symbols` for release builds (code protection + smaller size).

---

## 3. Environment Configuration


**Use `--dart-define` or `--dart-define-from-file` for environment variables:**

```bash
# Option A: inline
flutter build apk --dart-define=API_URL=https://api.production.com

# Option B: from file (preferred)
flutter build apk --dart-define-from-file=env/production.json
```

```dart
// Access in code
const apiUrl = String.fromEnvironment('API_URL');
```

**Rules:**
- Never embed secrets in the app bundle — they can be extracted.
- API keys for third-party services: use server-proxied calls when possible.
- Per-environment config files. Only development config may be committed.

---

## 5. Distribution


| Platform | Tool | Notes |
|----------|------|-------|
| App Store (iOS) | App Store Connect / Fastlane | Review takes 1-3 days |
| Play Store (Android) | Google Play Console / Fastlane | Use App Bundle (.aab) |
| TestFlight (iOS beta) | Fastlane `pilot` | Up to 10,000 testers |
| Internal testing | Firebase App Distribution | Quick distribution for QA |

**Version management:**

```yaml
# pubspec.yaml
version: 1.2.3+45    # semver+buildNumber
```

- `version` in `pubspec.yaml` is the single source of truth.
- Flutter auto-syncs to `Info.plist` (iOS) and `build.gradle` (Android).
- Build number (`+N`) increments on every CI build.
- Use `--build-name` and `--build-number` flags to override in CI.

---

## 7. Operational Commands

```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices

# Clean build artifacts
flutter clean

# Rebuild dependencies
flutter pub get

# Check project health
flutter doctor

# Analyze code
dart analyze

# Build size analysis
flutter build apk --analyze-size
flutter build ios --analyze-size
```
