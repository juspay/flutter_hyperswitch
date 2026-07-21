package io.hyperswitch.flutter_hyperswitch

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

/*
 * Unit tests for the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class FlutterHyperswitchPluginTest {
  @Test
  fun onMethodCall_unknownMethod_reportsNotImplemented() {
    val plugin = FlutterHyperswitchPlugin()

    val call = MethodCall("someUnknownMethod", null)
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).notImplemented()
  }

  @Test
  fun onMethodCall_updateIntent_withoutSession_reportsNotInitialised() {
    val plugin = FlutterHyperswitchPlugin()

    val call = MethodCall("updateIntent", mapOf("sdkAuthorization" to "cs_test_123"))
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    val expected = hashMapOf<String, Any>(
      "type" to "failed",
      "message" to "Not Initialised"
    )
    Mockito.verify(mockResult).success(expected)
  }

  @Test
  fun onMethodCall_updateIntent_withoutAuthorization_reportsFailure() {
    val plugin = FlutterHyperswitchPlugin()

    val call = MethodCall("updateIntent", mapOf<String, Any>())
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    val expected = hashMapOf<String, Any>(
      "type" to "failed",
      "message" to "sdkAuthorization is required"
    )
    Mockito.verify(mockResult).success(expected)
  }
}
