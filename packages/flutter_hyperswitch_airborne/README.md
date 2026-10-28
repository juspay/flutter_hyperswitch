# flutter_hyperswitch_airborne

An optional companion plugin for **Hyperswitch Flutter SDK** that enables Over-The-Air (OTA) updates using Airborne.

## Overview

Airborne is kept as an optional dependency so apps that do not require OTA updates are not burdened with additional binary size or runtime components.

By adding `flutter_hyperswitch_airborne` to your Flutter app's dependencies:
- On **Android**, it links `io.hyperswitch:hyperswitch-sdk-android-airborne`.
- On **iOS**, it links `hyperswitch-sdk-ios/airborne`.

The main Hyperswitch SDK automatically detects the presence of the Airborne native library at runtime via reflection, initializes the Airborne update service, and seamlessly boots the latest verified JavaScript bundle.

## Usage

Add `flutter_hyperswitch_airborne` to your app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_hyperswitch: ^latest
  flutter_hyperswitch_airborne: ^latest
```

No additional Dart initialization code is required—the core Hyperswitch SDK handles the lifecycle automatically.
