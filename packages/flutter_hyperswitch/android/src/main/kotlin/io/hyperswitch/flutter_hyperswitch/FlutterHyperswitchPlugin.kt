package io.hyperswitch.flutter_hyperswitch

import android.app.Activity
import android.graphics.Typeface
import android.os.Build
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
import io.hyperswitch.PaymentSession
import io.hyperswitch.payments.paymentlauncher.PaymentResult
import io.hyperswitch.paymentsession.LaunchOptions
import io.hyperswitch.paymentsession.PaymentSessionHandler
import io.hyperswitch.paymentsheet.PaymentSheetResult
import io.hyperswitch.BuildConfig
import io.hyperswitch.paymentsession.PMError


/** FlutterHyperswitchPlugin */
class FlutterHyperswitchPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var flutterPluginBindings: FlutterPlugin.FlutterPluginBinding
    private lateinit var activity: Activity
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
        defaultMap["type"] = "failure"
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
            map["type"] = "card"
            map["message"] = "clientSecret"
            callBackHandler(result, map)
        }

        when (call.method) {
            "init" -> {
                call.argument<HashMap<String, Any>>("params")?.let {
                    params.putAll(it)
                }
                val publishableKey = params["publishableKey"] as String? ?: ""
                val customBackendUrl = params["customBackendUrl"] as String? ?: ""
                val customLogUrl = params["customLogUrl"] as String? ?: ""
                val customParams = LaunchOptions(
                    activity, BuildConfig.VERSION_NAME
                ).toBundle(params["customParams"] as HashMap<*, *>? ?: mapOf<String, Any?>())
                paymentSession = PaymentSession(
                    activity, publishableKey, customBackendUrl, customLogUrl, customParams
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

                val cl = params["clientSecret"] as String? ?: ""
                paymentSession?.initPaymentSession(cl)
                val map = HashMap<String, Any>()
                map["type"] = "success"
                map["message"] = cl
                callBackHandler(result, map)
            }

            "getCustomerSavedPaymentMethods" -> {
                paymentSession?.getCustomerSavedPaymentMethods(::initSavedPaymentMethodSessionCallback)
                    ?: {
                        callBackHandler(result, defaultMap)
                    }
            }

            "getCustomerSavedPaymentMethodData" -> {
                var map = HashMap<String, Any>()
                handler?.getCustomerDefaultSavedPaymentMethodData()?.fold(onSuccess = {
                    map["type"] = "success"
                    map["message"] = it.toMap()
                }, onFailure = {
                    map["type"] = "failure"
                    map["message"] = (it as? PMError)?.toMap() ?: "Unknown Error"
                }) ?: {
                    map = defaultMap
                }
                callBackHandler(result, map)
            }

            "confirmWithCustomerDefaultPaymentMethod" -> {
                handler?.confirmWithCustomerDefaultPaymentMethod(null, ::resultHandler) ?: {
                    callBackHandler(result, defaultMap)
                }
            }

            "getCustomerLastUsedPaymentMethodData" -> {
                var map = HashMap<String, Any>()
                handler?.getCustomerLastUsedPaymentMethodData()?.fold(onSuccess = {
                    map["type"] = "success"
                    map["message"] = it.toMap()
                }, onFailure = {
                    map["type"] = "failure"
                    map["message"] = (it as? PMError)?.toMap() ?: "Unknown Error"
                }) ?: {
                    map = defaultMap
                }
                callBackHandler(result, map)
            }

            "confirmWithCustomerLastUsedPaymentMethod" -> {
                handler?.confirmWithCustomerLastUsedPaymentMethod(null, ::resultHandler) ?: {
                    callBackHandler(result, defaultMap)
                }
            }

            "presentPaymentSheet" -> {
                val pk = params["publishableKey"]
                if (pk == null) {
                    val map = HashMap<String, Any>()
                    map["type"] = "failed"
                    map["message"] = "Payment Sheet Initialisation Failed"
                    callBackHandler(result, map)
                } else {
                    paymentSheetResult = result
                    params["from"] = "flutter"
                    params["type"] = "payment"
                    paymentSession?.presentPaymentSheet(params, ::onPaymentSheetResult) ?: {
                        callBackHandler(result, defaultMap)
                    }
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

    private fun onPaymentSheetResult(paymentSheetResult: PaymentSheetResult) {
        when (paymentSheetResult) {
            is PaymentSheetResult.Canceled -> {
                sendResultToFlutter("cancelled", paymentSheetResult.data)
            }

            is PaymentSheetResult.Failed -> {
                sendResultToFlutter("failed", paymentSheetResult.error.message ?: "")
            }

            is PaymentSheetResult.Completed -> {
                sendResultToFlutter("completed", paymentSheetResult.data)
            }
        }
    }

    companion object {
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
}
