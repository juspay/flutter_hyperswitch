package io.hyperswitch.flutter_hyperswitch

import android.app.Activity
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import com.facebook.react.views.text.ReactFontManager
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.hyperswitch.model.CustomEndpointConfiguration
import io.hyperswitch.model.HyperswitchConfiguration
import io.hyperswitch.model.HyperswitchEnvironment
import io.hyperswitch.model.OverrideEndpoints
import io.hyperswitch.model.PaymentSessionConfiguration
import io.hyperswitch.paymentsheet.PaymentResult
import io.hyperswitch.paymentsession.PaymentSessionHandler
import io.hyperswitch.paymentsession.PMError
import io.hyperswitch.sdk.Hyperswitch
import io.hyperswitch.sdk.HyperswitchInstance
import io.hyperswitch.sdk.PaymentSession
import java.util.concurrent.atomic.AtomicBoolean


/** FlutterHyperswitchPlugin */
class FlutterHyperswitchPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var flutterPluginBindings: FlutterPlugin.FlutterPluginBinding
    private lateinit var activity: Activity
    private var hyperswitchInstance: HyperswitchInstance? = null
    private var paymentSession: PaymentSession? = null
    private var handler: PaymentSessionHandler? = null


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBindings = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_hyperswitch")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}

    @RequiresApi(Build.VERSION_CODES.P)
    override fun onMethodCall(call: MethodCall, result: Result) {

        val defaultMap = HashMap<String, Any>()
        defaultMap["type"] = "failed"
        defaultMap["message"] = "Not Initialised"

        fun resultHandler(paymentResult: PaymentResult) {
            val map = HashMap<String, Any>()
            when (paymentResult) {
                is PaymentResult.Canceled -> {
                    map["type"] = "canceled"
                    map["message"] = paymentResult.data
                }

                is PaymentResult.Failed -> {
                    map["type"] = "failed"
                    map["message"] = paymentResult.throwable.message ?: "Unknown Error"
                }

                is PaymentResult.Completed -> {
                    map["type"] = "completed"
                    map["message"] = paymentResult.data
                }
            }
            callBackHandler(result, map)
        }

        fun initSavedPaymentMethodSessionCallback(
            handler: PaymentSessionHandler
        ) {
            this.handler = handler
            val map = HashMap<String, Any>()
            map["type"] = "success"
            map["message"] = params["sdkAuthorization"] ?: ""
            callBackHandler(result, map)
        }

        when (call.method) {
            "init" -> {
                call.argument<HashMap<String, Any>>("params")?.let {
                    params.putAll(it)
                }
                val publishableKey = params["publishableKey"] as String? ?: ""
                val profileId = params["profileId"] as String?
                val customEndpointConfiguration = buildCustomEndpointConfiguration(params)
                val environment = when ((params["environment"] as? String)?.uppercase()) {
                    "SANDBOX" -> HyperswitchEnvironment.SANDBOX
                    "INTEG" -> HyperswitchEnvironment.INTEG
                    else -> HyperswitchEnvironment.PROD
                }

                hyperswitchInstance = Hyperswitch.init(
                    activity,
                    HyperswitchConfiguration(
                        publishableKey,
                        profileId,
                        customEndpointConfiguration,
                        environment
                    )
                )
            }

            "initPaymentSession" -> {
                call.argument<HashMap<String, Any>>("params")?.let {
                    params.putAll(it)
                }

                val fontName = (params["configuration"] as? HashMap<*, *>)?.let { config ->
                    (config["appearance"] as? HashMap<*, *>)?.let { appearance ->
                        (appearance["typography"] as? HashMap<*, *>)?.let { typography ->
                            typography["fontResId"] as? String
                        }
                    }
                }

                fontName?.let { name ->

                    val fonts = arrayOf(
                        "Black",
                        "BlackItalic",
                        "Bold",
                        "BoldItalic",
                        "ExtraBold",
                        "ExtraBoldItalic",
                        "ExtraLight",
                        "ExtraLightItalic",
                        "Italic",
                        "Light",
                        "LightItalic",
                        "Medium",
                        "MediumItalic",
                        "Regular",
                        "SemiBold",
                        "SemiBoldItalic",
                        "Thin",
                        "ThinItalic"
                    )

                    val loader = FlutterInjector.instance().flutterLoader()

                    try {
                        val fontKey = loader.getLookupKeyForAsset("fonts/${name}.ttf")
                        val myTypeface = Typeface.createFromAsset(
                            activity.applicationContext.resources.assets, fontKey
                        )
                        ReactFontManager.getInstance().addCustomFont(
                            name, myTypeface
                        )
                    } catch (_: Exception) {
                        Log.w(
                            "Hyperswitch Warning",
                            "Font not found",
                        )
                    }

                    for (suffix in fonts) {
                        try {
                            val fontKey = loader.getLookupKeyForAsset("fonts/${name}-${suffix}.ttf")
                            val myTypeface = Typeface.createFromAsset(
                                activity.applicationContext.resources.assets, fontKey
                            )
                            ReactFontManager.getInstance().addCustomFont(
                                name + if (suffix == "Regular") "" else suffix, myTypeface
                            )
                        } catch (_: Exception) {
                            Log.w(
                                "Hyperswitch Warning",
                                "Font not found",
                            )
                        }
                    }

                }

                val sdkAuthorization = params["sdkAuthorization"] as String?
                    ?: params["clientSecret"] as String?
                    ?: ""
                params["sdkAuthorization"] = sdkAuthorization

                if (sdkAuthorization.isEmpty()) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "sdkAuthorization is required"
                    callBackHandler(result, map)
                    return
                }

                hyperswitchInstance?.initPaymentSession(
                    PaymentSessionConfiguration(sdkAuthorization)
                ) { session ->
                    paymentSession = session
                    val map = HashMap<String, Any>()
                    map["type"] = "success"
                    map["message"] = sdkAuthorization
                    callBackHandler(result, map)
                } ?: run {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "Hyperswitch not initialised"
                    callBackHandler(result, map)
                }
            }

            "getCustomerSavedPaymentMethods" -> {
                paymentSession?.getCustomerSavedPaymentMethods(
                    savedPaymentMethodCallback = ::initSavedPaymentMethodSessionCallback
                ) ?: callBackHandler(result, defaultMap)
            }

            "getCustomerSavedPaymentMethodData" -> {
                var map = HashMap<String, Any>()
                val currentHandler = handler
                if (currentHandler == null) {
                    map = defaultMap
                } else {
                    currentHandler.getCustomerDefaultSavedPaymentMethodData().fold(onSuccess = {
                        map["type"] = "success"
                        map["message"] = it.toMap()
                    }, onFailure = {
                        map["type"] = "failure"
                        map["message"] = (it as? PMError)?.toMap() ?: "Unknown Error"
                    })
                }
                callBackHandler(result, map)
            }

            "confirmWithCustomerDefaultPaymentMethod" -> {
                confirmWithCurrentHandler(
                    result,
                    defaultMap,
                    ::resultHandler,
                    useLastUsed = false
                )
            }

            "getCustomerLastUsedPaymentMethodData" -> {
                var map = HashMap<String, Any>()
                val currentHandler = handler
                if (currentHandler == null) {
                    map = defaultMap
                } else {
                    currentHandler.getCustomerLastUsedPaymentMethodData().fold(onSuccess = {
                        map["type"] = "success"
                        map["message"] = it.toMap()
                    }, onFailure = {
                        map["type"] = "failure"
                        map["message"] = (it as? PMError)?.toMap() ?: "Unknown Error"
                    })
                }
                callBackHandler(result, map)
            }

            "confirmWithCustomerLastUsedPaymentMethod" -> {
                confirmWithCurrentHandler(
                    result,
                    defaultMap,
                    ::resultHandler,
                    useLastUsed = true
                )
            }

            "presentPaymentSheet" -> {
                call.argument<HashMap<String, Any>>("params")?.let {
                    params.putAll(it)
                }
                val pk = params["publishableKey"]
                if (pk == null) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "Payment Sheet Initialisation Failed"
                    callBackHandler(result, map)
                } else {
                    paymentSheetResult = result
                    val presentParams = buildPaymentSheetParams()
                    paymentSession?.presentPaymentSheet(presentParams, null, ::onPaymentSheetResult)
                        ?: callBackHandler(result, defaultMap)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun sendResultToFlutter(status: String, message: String) {
        val map = HashMap<String, Any>()
        map["type"] = status
        map["message"] = message
        paymentSheetResult?.let {
            callBackHandler(it, map)
            paymentSheetResult = null
        }
    }

    private fun onPaymentSheetResult(paymentSheetResult: PaymentResult) {
        when (paymentSheetResult) {
            is PaymentResult.Canceled -> {
                sendResultToFlutter("canceled", paymentSheetResult.data)
            }

            is PaymentResult.Failed -> {
                sendResultToFlutter("failed", paymentSheetResult.throwable.message ?: "")
            }

            is PaymentResult.Completed -> {
                sendResultToFlutter("completed", paymentSheetResult.data)
            }
        }
    }

    companion object {
        private const val CONFIRM_TIMEOUT_MS = 30000L

        @JvmStatic
        var paymentSheetResult: Result? = null
        var params: HashMap<String, Any> = HashMap()

        fun callBackHandler(result: Result, map: HashMap<String, Any>) {
            try {
                result.success(map)
            } catch (_: Exception) {
            }
        }
    }

    private fun confirmWithCurrentHandler(
        result: Result,
        defaultMap: HashMap<String, Any>,
        resultHandler: (PaymentResult) -> Unit,
        useLastUsed: Boolean
    ) {
        val currentHandler = handler
        if (currentHandler == null) {
            callBackHandler(result, defaultMap)
            return
        }

        activity.runOnUiThread {
            val didRespond = AtomicBoolean(false)
            val timeoutHandler = Handler(Looper.getMainLooper())
            val timeoutRunnable = Runnable {
                if (didRespond.compareAndSet(false, true)) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "Headless confirm timed out before native SDK callback"
                    callBackHandler(result, map)
                }
            }

            fun complete(paymentResult: PaymentResult) {
                if (didRespond.compareAndSet(false, true)) {
                    timeoutHandler.removeCallbacks(timeoutRunnable)
                    resultHandler(paymentResult)
                }
            }

            try {
                timeoutHandler.postDelayed(timeoutRunnable, CONFIRM_TIMEOUT_MS)
                if (useLastUsed) {
                    currentHandler.confirmWithCustomerLastUsedPaymentMethod { complete(it) }
                } else {
                    currentHandler.confirmWithCustomerDefaultPaymentMethod { complete(it) }
                }
            } catch (error: Exception) {
                timeoutHandler.removeCallbacks(timeoutRunnable)
                didRespond.set(true)
                val map = HashMap<String, Any>()
                map["type"] = "failed"
                map["message"] = error.message ?: "Confirm Payment Failed"
                callBackHandler(result, map)
            }
        }
    }

    private fun buildPaymentSheetParams(): HashMap<String, Any?> {
        val publishableKey = params["publishableKey"] as? String ?: ""
        val sdkAuthorization = params["sdkAuthorization"] as? String
            ?: params["clientSecret"] as? String
            ?: ""
        val customBackendUrl = params["customBackendUrl"] as? String
        val customLogUrl = params["customLogUrl"] as? String
        val configuration = params["configuration"] as? HashMap<*, *>

        val hyperswitchConfig = HashMap<String, Any?>()
        hyperswitchConfig["publishableKey"] = publishableKey
        params["profileId"]?.let { hyperswitchConfig["profileId"] = it }
        params["environment"]?.let { hyperswitchConfig["environment"] = it }

        val customEndpoints = params["customEndpoints"] as? HashMap<*, *>
        if (customEndpoints != null || customBackendUrl != null || customLogUrl != null) {
            val customEndpointsMap = HashMap<String, Any?>()
            customEndpoints?.get("commonEndpoint")?.let {
                customEndpointsMap["commonEndpoint"] = it
            }

            val overrideEndpoints = HashMap<String, Any?>()
            (customEndpoints?.get("overrideEndpoints") as? HashMap<*, *>)?.forEach { (key, value) ->
                if (key != null) overrideEndpoints[key.toString()] = value
            }
            customBackendUrl?.let { overrideEndpoints["customBackendEndpoint"] = it }
            customLogUrl?.let { overrideEndpoints["customLoggingEndpoint"] = it }
            if (overrideEndpoints.isNotEmpty()) {
                customEndpointsMap["overrideEndpoints"] = overrideEndpoints
            }
            if (customEndpointsMap.isNotEmpty()) {
                hyperswitchConfig["customEndpoints"] = customEndpointsMap
            }
        }

        val paymentSessionConfig = HashMap<String, Any?>()
        paymentSessionConfig["sdkAuthorization"] = sdkAuthorization
        paymentSessionConfig["clientSecret"] = params["clientSecret"] as? String ?: ""

        return HashMap<String, Any?>().apply {
            put("type", "payment")
            put("from", "flutter")
            put("publishableKey", publishableKey)
            put("sdkAuthorization", sdkAuthorization)
            put("customBackendUrl", customBackendUrl)
            put("customLoggingUrl", customLogUrl)
            put("customLogUrl", customLogUrl)
            put("hyperswitchConfig", hyperswitchConfig)
            put("paymentSessionConfig", paymentSessionConfig)
            if (configuration != null) {
                put("configuration", configuration)
            }
        }
    }

    private fun buildCustomEndpointConfiguration(params: HashMap<String, Any>): CustomEndpointConfiguration? {
        val customEndpoints = params["customEndpoints"] as? HashMap<*, *>
        val commonEndpoint = customEndpoints?.get("commonEndpoint") as? String
        val overrideEndpoints = customEndpoints?.get("overrideEndpoints") as? HashMap<*, *>
        val customBackendUrl = params["customBackendUrl"] as? String
        val customLogUrl = params["customLogUrl"] as? String

        val overrideConfig = if (overrideEndpoints != null || customBackendUrl != null || customLogUrl != null) {
            OverrideEndpoints(
                customBackendEndpoint = overrideEndpoints?.get("customBackendEndpoint") as? String
                    ?: customBackendUrl,
                customLoggingEndpoint = overrideEndpoints?.get("customLoggingEndpoint") as? String
                    ?: customLogUrl,
                customAssetEndpoint = overrideEndpoints?.get("customAssetEndpoint") as? String,
                customSDKConfigEndpoint = overrideEndpoints?.get("customSDKConfigEndpoint") as? String,
                customConfirmEndpoint = overrideEndpoints?.get("customConfirmEndpoint") as? String,
                customAirborneEndpoint = overrideEndpoints?.get("customAirborneEndpoint") as? String,
            )
        } else {
            null
        }

        return if (commonEndpoint != null || overrideConfig != null) {
            CustomEndpointConfiguration(overrideConfig, commonEndpoint)
        } else {
            null
        }
    }
}
