package io.hyperswitch.flutter_hyperswitch

import android.content.Context
import android.view.View
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.hyperswitch.view.CVCWidget
import io.hyperswitch.view.PaymentElement

class PaymentElementPlatformView : PlatformView {
    private val view: PaymentElement
    private val widgetId: String?

    constructor(context: Context, viewId: Int, args: Map<String, Any?>?) {
        view = PaymentElement(context)
        view.id = viewId
        widgetId = args?.get("widgetId") as? String
        if (widgetId != null) {
            view.tag = widgetId
            FlutterHyperswitchPlugin.widgetViews[widgetId] = view
        }
    }

    override fun getView(): View = view

    override fun dispose() {
        if (widgetId != null) {
            FlutterHyperswitchPlugin.widgetViews.remove(widgetId)
        }
        (view.parent as? android.view.ViewGroup)?.removeView(view)
    }
}

class PaymentElementPlatformViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        return PaymentElementPlatformView(context, viewId, params)
    }
}

class CvcWidgetPlatformView : PlatformView {
    private val view: CVCWidget
    private val widgetId: String?

    constructor(context: Context, viewId: Int, args: Map<String, Any?>?) {
        view = CVCWidget(context)
        view.id = viewId
        widgetId = args?.get("widgetId") as? String
        if (widgetId != null) {
            view.tag = widgetId
            FlutterHyperswitchPlugin.widgetViews[widgetId] = view
        }
    }

    override fun getView(): View = view

    override fun dispose() {
        if (widgetId != null) {
            FlutterHyperswitchPlugin.widgetViews.remove(widgetId)
        }
        (view.parent as? android.view.ViewGroup)?.removeView(view)
    }
}

class CvcWidgetPlatformViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        return CvcWidgetPlatformView(context, viewId, params)
    }
}
