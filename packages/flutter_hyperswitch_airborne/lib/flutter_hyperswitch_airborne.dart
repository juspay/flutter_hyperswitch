/// flutter_hyperswitch_airborne
///
/// An optional companion package for Hyperswitch Flutter SDK that bundles the native
/// Airborne OTA dependencies for Android and iOS.
///
/// Simply adding this dependency in your app's `pubspec.yaml` will package the native
/// Airborne OTA runtime, which the main Hyperswitch SDK automatically detects and uses
/// to download and apply Over-The-Air updates.
library flutter_hyperswitch_airborne;

class FlutterHyperswitchAirborne {
  /// Confirms the companion package is bundled in the build.
  static const bool isBundled = true;
}
