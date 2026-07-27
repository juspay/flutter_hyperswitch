package io.hyperswitch.flutterhyperswitchexample

import io.flutter.embedding.android.FlutterFragmentActivity
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler

class MainActivity: FlutterFragmentActivity(), DefaultHardwareBackBtnHandler {
    override fun invokeDefaultOnBackPressed() {
        super.onBackPressed()
    }
}
