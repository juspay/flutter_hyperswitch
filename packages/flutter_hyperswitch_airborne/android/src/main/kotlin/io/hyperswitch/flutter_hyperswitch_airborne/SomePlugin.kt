package io.hyperswitch.flutter_hyperswitch_airborne

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Native plugin implementation that bundles the Hyperswitch Airborne OTA SDK
 * (io.hyperswitch:hyperswitch-sdk-android-airborne).
 *
 * The main Hyperswitch SDK detects the native Airborne OTA classes automatically at runtime.
 */
class SomePlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Native Airborne OTA dependency is available on the classpath.
        // The main Hyperswitch SDK accesses Airborne via reflection.
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
