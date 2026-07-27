package io.hyperswitch.flutter_hyperswitch

import android.app.Activity
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
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
import io.flutter.plugin.common.EventChannel
import io.hyperswitch.model.CustomEndpointConfiguration
import io.hyperswitch.model.ElementsUpdateResult
import io.hyperswitch.model.HyperswitchConfiguration
import io.hyperswitch.model.HyperswitchEnvironment
import io.hyperswitch.model.OverrideEndpoints
import io.hyperswitch.model.PaymentSessionConfiguration
import io.hyperswitch.paymentsheet.PaymentResult
import io.hyperswitch.PaymentEvents
import io.hyperswitch.PaymentEventSubscriptionBuilder
import io.hyperswitch.CvcWidgetEvents
import io.hyperswitch.paymentsession.PaymentSessionHandler
import io.hyperswitch.paymentsession.PMError
import io.hyperswitch.sdk.Elements
import io.hyperswitch.sdk.Hyperswitch
import io.hyperswitch.sdk.HyperswitchBoundElement
import io.hyperswitch.sdk.HyperswitchInstance
import io.hyperswitch.sdk.PaymentSession
import io.flutter.plugin.platform.PlatformViewRegistry
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine


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
    private var eventSink: EventChannel.EventSink? = null
    private var elements: Elements? = null
    private val boundElements = ConcurrentHashMap<String, HyperswitchBoundElement>()
    private val pendingConfirmCallbacks = ConcurrentHashMap<String, (Boolean) -> Unit>()
    private val widgetViews = ConcurrentHashMap<String, io.hyperswitch.view.HyperswitchElement>()


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBindings = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_hyperswitch")
        channel.setMethodCallHandler(this)
        val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_hyperswitch/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                eventSink = sink
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        val registry: PlatformViewRegistry = flutterPluginBinding.platformViewRegistry
        registry.registerViewFactory("hyperswitch_payment_element", PaymentElementPlatformViewFactory(widgetViews))
        registry.registerViewFactory("hyperswitch_cvc_widget", CvcWidgetPlatformViewFactory(widgetViews))
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

                registerCustomFonts(params["configuration"] as? HashMap<*, *>)

                val sdkAuthorization = params["sdkAuthorization"] as String? ?: ""
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
                val widgetId = call.argument<String>("widgetId")
                confirmWithCurrentHandler(
                    result,
                    defaultMap,
                    ::resultHandler,
                    useLastUsed = false,
                    widgetId = widgetId
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
                val widgetId = call.argument<String>("widgetId")
                confirmWithCurrentHandler(
                    result,
                    defaultMap,
                    ::resultHandler,
                    useLastUsed = true,
                    widgetId = widgetId
                )
            }

            "confirmWithCustomerPaymentToken" -> {
                val paymentToken = call.argument<String>("paymentToken") ?: ""
                confirmWithCurrentHandler(
                    result,
                    defaultMap,
                    ::resultHandler,
                    paymentToken = paymentToken
                )
            }

            "updateIntent" -> {
                val sdkAuthorization = call.argument<String>("sdkAuthorization") ?: ""
                val session = paymentSession
                if (sdkAuthorization.isEmpty()) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "sdkAuthorization is required"
                    callBackHandler(result, map)
                } else if (session == null) {
                    callBackHandler(result, defaultMap)
                } else {
                    session.updateSdkAuthorization(sdkAuthorization)
                    val map = HashMap<String, Any>()
                    map["type"] = "success"
                    callBackHandler(result, map)
                }
            }

            "updateElementsIntent" -> {
                val currentElements = elements
                if (currentElements == null) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "Elements not initialised"
                    callBackHandler(result, map)
                    return
                }

                var resolvedParams: HashMap<String, Any>? = null
                var resolverError: Throwable? = null
                currentElements.updateIntent(
                    completion = {
                        try {
                            val configuration = resolveElementsIntent()
                            resolvedParams = configuration
                            PaymentSessionConfiguration(
                                configuration["sdkAuthorization"] as String
                            )
                        } catch (error: Exception) {
                            resolverError = error
                            throw error
                        }
                    },
                    onResult = { updateResult ->
                        val map = HashMap<String, Any>()
                        resolverError?.let { error ->
                            map["type"] = "failed"
                            map["message"] = error.message ?: "Intent resolver failed"
                            callBackHandler(result, map)
                            return@updateIntent
                        }

                        resolvedParams?.let { params.putAll(it) }
                        when (updateResult) {
                            ElementsUpdateResult.Success -> {
                                map["type"] = "success"
                            }
                            is ElementsUpdateResult.PartialFailure -> {
                                map["type"] = "partial_failure"
                                map["message"] =
                                    "${updateResult.failed.size} element(s) failed to update"
                            }
                            is ElementsUpdateResult.TotalFailure -> {
                                map["type"] = "failed"
                                map["message"] = updateResult.cause.message
                                    ?: "Elements update failed"
                            }
                        }
                        callBackHandler(result, map)
                    }
                )
            }

            "elements" -> {
                call.argument<HashMap<String, Any>>("params")?.let { p ->
                    params.putAll(p)
                }
                registerCustomFonts(params["configuration"] as? HashMap<*, *>)
                val sdkAuthorization = params["sdkAuthorization"] as String? ?: ""
                if (sdkAuthorization.isEmpty()) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "sdkAuthorization is required"
                    callBackHandler(result, map)
                    return
                }
                hyperswitchInstance?.elements(
                    PaymentSessionConfiguration(sdkAuthorization)
                ) { els ->
                    elements = els
                    paymentSession = els.getPaymentSession()
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

            "createElement" -> {
                val createParams = call.argument<HashMap<String, Any>>("params") ?: HashMap()
                val type = createParams["type"] as? String ?: ""
                val widgetId = createParams["widgetId"] as? String ?: ""
                val configuration = createParams["configuration"] as? HashMap<*, *>

                if (widgetId.isEmpty()) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "widgetId is required"
                    callBackHandler(result, map)
                    return
                }

                val els = elements
                if (els == null) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "elements() not called"
                    callBackHandler(result, map)
                    return
                }

                val view = widgetViews[widgetId]
                if (view == null) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "PlatformView for widgetId=$widgetId not found"
                    callBackHandler(result, map)
                    return
                }

                val hsElement: io.hyperswitch.view.HyperswitchElement = view

                registerCustomFonts(configuration)

                // Flatten configuration into a top-level map (SDK expects flat keys:
                // appearance, paymentMethodLayout, etc. — NOT nested under "configuration")
                val configMap = HashMap<String, Any?>()
                if (configuration != null) {
                    for ((key, value) in configuration) {
                        if (key != null && value != null) configMap[key.toString()] = value
                    }
                }
                val subscribedEvents = (configMap.remove("subscribedEvents") as? List<*>) ?: emptyList<String>()

                activity.runOnUiThread {
                    try {
                        // Unbind existing element if present (prevents stale bindings on re-create)
                        boundElements.remove(widgetId)?.let { oldBound ->
                            pendingConfirmCallbacks.remove(widgetId)
                            try { els.unbind(oldBound) } catch (_: Exception) {}
                            try { oldBound.destroy() } catch (_: Exception) {}
                        }

                        if (type == "paymentElement" || type == "payment") {
                            val bound = els.bind(hsElement, configMap) {
                                if (subscribedEvents.contains("FORM_STATUS"))
                                    on(PaymentEvents.FormStatus) { event ->
                                        emitWidgetEvent(widgetId, "FORM_STATUS", event.payload)
                                    }
                                if (subscribedEvents.contains("PAYMENT_METHOD_STATUS"))
                                    on(PaymentEvents.PaymentMethodStatus) { event ->
                                        emitWidgetEvent(widgetId, "PAYMENT_METHOD_STATUS", event.payload)
                                    }
                                if (subscribedEvents.contains("PAYMENT_METHOD_INFO_CARD"))
                                    on(PaymentEvents.PaymentMethodInfoCard) { event ->
                                        emitWidgetEvent(widgetId, "PAYMENT_METHOD_INFO_CARD", event.payload)
                                    }
                                if (subscribedEvents.contains("PAYMENT_METHOD_INFO_BILLING_ADDRESS"))
                                    on(PaymentEvents.PaymentMethodInfoBillingAddress) { event ->
                                        emitWidgetEvent(widgetId, "PAYMENT_METHOD_INFO_BILLING_ADDRESS", event.payload)
                                    }
                            }
                            boundElements[widgetId] = bound
                            bound.onPaymentResult { paymentResult ->
                                val resultMap = HashMap<String, Any>()
                                when (paymentResult) {
                                    is PaymentResult.Canceled -> {
                                        resultMap["type"] = "canceled"
                                        resultMap["message"] = paymentResult.data
                                    }
                                    is PaymentResult.Failed -> {
                                        resultMap["type"] = "failed"
                                        resultMap["message"] = paymentResult.throwable.message ?: "Unknown Error"
                                    }
                                    is PaymentResult.Completed -> {
                                        resultMap["type"] = "completed"
                                        resultMap["message"] = paymentResult.data
                                    }
                                }
                                emitWidgetEvent(widgetId, "onPaymentResult", resultMap)
                            }
                            bound.onPaymentConfirmButtonClick { data, callback ->
                                pendingConfirmCallbacks[widgetId] = callback
                                val payloadMap = HashMap<String, Any>()
                                payloadMap["paymentMethodType"] = data?.paymentMethodType ?: ""
                                emitWidgetEvent(widgetId, "onPaymentConfirmButtonClick", payloadMap)
                            }
                        } else if (type == "cvcWidget" || type == "cvc") {
                            val bound = els.bind(hsElement, configMap) {
                                on(CvcWidgetEvents.CvcStatus) { event ->
                                    emitWidgetEvent(widgetId, "CVC_STATUS", event.payload)
                                }
                            }
                            boundElements[widgetId] = bound
                        } else {
                            val map = HashMap<String, Any>()
                            map["type"] = "failed"
                            map["message"] = "Unknown element type: $type"
                            callBackHandler(result, map)
                            return@runOnUiThread
                        }

                        val map = HashMap<String, Any>()
                        map["type"] = "success"
                        callBackHandler(result, map)
                    } catch (error: Exception) {
                        val map = HashMap<String, Any>()
                        map["type"] = "failed"
                        map["message"] = error.message ?: "createElement failed"
                        callBackHandler(result, map)
                    }
                }
            }

            "confirmPayment" -> {
                val widgetId = call.argument<String>("widgetId") ?: ""
                val bound = boundElements[widgetId]
                if (bound == null) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "PaymentElement not bound for widgetId=$widgetId"
                    callBackHandler(result, map)
                    return
                }
                activity.runOnUiThread {
                    try {
                        bound.confirmPayment { paymentResult ->
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
                    } catch (error: Exception) {
                        val map = HashMap<String, Any>()
                        map["type"] = "failed"
                        map["message"] = error.message ?: "Confirm Payment Failed"
                        callBackHandler(result, map)
                    }
                }
            }

            "resolvePaymentConfirmButtonClick" -> {
                val widgetId = call.argument<String>("widgetId") ?: ""
                val proceed = call.argument<Boolean>("proceed") ?: false
                val callback = pendingConfirmCallbacks.remove(widgetId)
                activity.runOnUiThread {
                    try {
                        callback?.invoke(proceed)
                    } catch (_: Exception) {
                    }
                }
                result.success(null)
            }

            "destroyElement" -> {
                val widgetId = call.argument<String>("widgetId") ?: ""
                val bound = boundElements.remove(widgetId)
                pendingConfirmCallbacks.remove(widgetId)
                widgetViews.remove(widgetId)
                val els = elements
                activity.runOnUiThread {
                    try {
                        bound?.let { b ->
                            els?.let { try { it.unbind(b) } catch (_: Exception) {} }
                            b.destroy()
                        }
                    } catch (_: Exception) {
                    }
                }
                result.success(null)
            }

            "presentPaymentSheet" -> {
                call.argument<HashMap<String, Any>>("params")?.let {
                    params.putAll(it)
                }
                // The sheet configuration (and its font) often arrives only here.
                registerCustomFonts(params["configuration"] as? HashMap<*, *>)
                val pk = params["publishableKey"]
                if (pk == null) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "Payment Sheet Initialisation Failed"
                    callBackHandler(result, map)
                } else {
                    paymentSheetResult = result
                    val presentParams = buildPaymentSheetParams()
                    val configuration = presentParams["configuration"] as? HashMap<*, *>
                    val subscribedEvents = configuration?.get("subscribedEvents") as? List<*> ?: emptyList<String>()
                    paymentSession?.presentPaymentSheet(presentParams, {
                        if (subscribedEvents.contains("PAYMENT_METHOD_INFO_CARD"))
                            on(PaymentEvents.PaymentMethodInfoCard) { event -> emitEvent(event.type, event.payload) }
                        if (subscribedEvents.contains("PAYMENT_METHOD_STATUS"))
                            on(PaymentEvents.PaymentMethodStatus) { event -> emitEvent(event.type, event.payload) }
                        if (subscribedEvents.contains("FORM_STATUS"))
                            on(PaymentEvents.FormStatus) { event -> emitEvent(event.type, event.payload) }
                        if (subscribedEvents.contains("PAYMENT_METHOD_INFO_BILLING_ADDRESS"))
                            on(PaymentEvents.PaymentMethodInfoBillingAddress) { event -> emitEvent(event.type, event.payload) }
                    }, ::onPaymentSheetResult)
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
        eventSink = null
    }

    private fun emitEvent(eventType: String, payload: Map<String, Any>) {
        val map = HashMap<String, Any>()
        map["eventName"] = eventType
        map["payload"] = payload
        activity.runOnUiThread {
            eventSink?.success(map)
        }
    }

    private fun emitWidgetEvent(widgetId: String, type: String, payload: Any?) {
        val map = HashMap<String, Any>()
        map["widgetId"] = widgetId
        map["type"] = type
        map["payload"] = payload ?: HashMap<String, Any>()
        activity.runOnUiThread {
            eventSink?.success(map)
        }
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

    /**
     * Registers Flutter-asset fonts so the SDK bundle can resolve
     * `appearance.font.family`.
     *
     * The family may contain spaces (e.g. "Press Start 2P") while the font
     * files conventionally don't ("PressStart2P-Regular.ttf"), so lookup also
     * tries a space-stripped file name. Fonts are registered under the
     * configured family string either way.
     */
    private fun registerCustomFonts(configuration: HashMap<*, *>?) {
        val appearance = configuration?.get("appearance") as? HashMap<*, *> ?: return
        val fontName = (appearance["font"] as? HashMap<*, *>)?.get("family") as? String
            ?: return

        val fonts = arrayOf(
            "Black", "BlackItalic", "Bold", "BoldItalic",
            "ExtraBold", "ExtraBoldItalic", "ExtraLight", "ExtraLightItalic",
            "Italic", "Light", "LightItalic", "Medium", "MediumItalic",
            "Regular", "SemiBold", "SemiBoldItalic", "Thin", "ThinItalic"
        )

        val loader = FlutterInjector.instance().flutterLoader()
        val fileBases = linkedSetOf(fontName, fontName.replace(" ", ""))

        fun typefaceForVariant(suffix: String?): Typeface? {
            for (base in fileBases) {
                val fileName = if (suffix == null) "$base.ttf" else "$base-$suffix.ttf"
                try {
                    val fontKey = loader.getLookupKeyForAsset("fonts/$fileName")
                    return Typeface.createFromAsset(
                        activity.applicationContext.resources.assets, fontKey
                    )
                } catch (_: Exception) {
                }
            }
            return null
        }

        typefaceForVariant(null)?.let {
            ReactFontManager.getInstance().addCustomFont(fontName, it)
        } ?: Log.w("Hyperswitch Warning", "Font not found: $fontName")

        for (suffix in fonts) {
            typefaceForVariant(suffix)?.let {
                ReactFontManager.getInstance().addCustomFont(
                    fontName + if (suffix == "Regular") "" else suffix, it
                )
            } ?: Log.w("Hyperswitch Warning", "Font not found: $fontName-$suffix")
        }
    }

    private suspend fun resolveElementsIntent(): HashMap<String, Any> =
        suspendCoroutine { continuation ->
            channel.invokeMethod(
                "resolveElementsIntent",
                null,
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        val response = result as? Map<*, *>
                        if (response == null) {
                            continuation.resumeWithException(
                                IllegalStateException(
                                    "Intent resolver returned an invalid configuration"
                                )
                            )
                            return
                        }
                        val configuration = HashMap<String, Any>()
                        response.forEach { (key, value) ->
                            if (key is String && value != null) {
                                configuration[key] = value
                            }
                        }
                        val sdkAuthorization =
                            configuration["sdkAuthorization"] as? String ?: ""
                        if (sdkAuthorization.isBlank()) {
                            continuation.resumeWithException(
                                IllegalArgumentException("sdkAuthorization is required")
                            )
                            return
                        }
                        continuation.resume(configuration)
                    }

                    override fun error(
                        errorCode: String,
                        errorMessage: String?,
                        errorDetails: Any?
                    ) {
                        continuation.resumeWithException(
                            IllegalStateException(
                                errorMessage ?: "Intent resolver failed ($errorCode)"
                            )
                        )
                    }

                    override fun notImplemented() {
                        continuation.resumeWithException(
                            UnsupportedOperationException(
                                "Intent resolver is not implemented by Dart"
                            )
                        )
                    }
                }
            )
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
        useLastUsed: Boolean = false,
        paymentToken: String? = null,
        widgetId: String? = null
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

            val cvcWidgetView: View? = widgetId?.let { widgetViews[it] }

            try {
                timeoutHandler.postDelayed(timeoutRunnable, CONFIRM_TIMEOUT_MS)
                when {
                    paymentToken != null -> {
                        currentHandler.confirmWithCustomerPaymentToken(paymentToken, null) { complete(it) }
                    }
                    useLastUsed -> {
                        if (cvcWidgetView != null) {
                            currentHandler.confirmWithCustomerLastUsedPaymentMethod(cvcWidgetView) { complete(it) }
                        } else {
                            currentHandler.confirmWithCustomerLastUsedPaymentMethod { complete(it) }
                        }
                    }
                    else -> {
                        if (cvcWidgetView != null) {
                            currentHandler.confirmWithCustomerDefaultPaymentMethod(cvcWidgetView) { complete(it) }
                        } else {
                            currentHandler.confirmWithCustomerDefaultPaymentMethod { complete(it) }
                        }
                    }
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

    /**
     * Launch props for the SDK bundle, which reads only `type`,
     * `hyperswitchConfig`, `paymentSessionConfig` and `configuration`;
     * custom endpoints ride inside `hyperswitchConfig.customEndpoints`.
     */
    private fun buildPaymentSheetParams(): HashMap<String, Any?> {
        val publishableKey = params["publishableKey"] as? String ?: ""
        val sdkAuthorization = params["sdkAuthorization"] as? String ?: ""
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
                if (key != null && value != null) overrideEndpoints[key.toString()] = value
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
        paymentSessionConfig["clientSecret"] = sdkAuthorization

        return HashMap<String, Any?>().apply {
            put("type", "payment")
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
