package io.hyperswitch.flutter_hyperswitch

import android.content.Context
import android.view.View
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.hyperswitch.view.CVCWidget
import io.hyperswitch.view.HyperswitchElement
import io.hyperswitch.view.PaymentElement
import java.util.concurrent.ConcurrentHashMap

class PaymentElementPlatformView(
    context: Context,
    viewId: Int,
    args: Map<String, Any?>?,
    private val widgetViews: ConcurrentHashMap<String, HyperswitchElement>
) : PlatformView {
    private val view: PaymentElement = PaymentElement(context)
    private val widgetId: String? = args?.get("widgetId") as? String

    init {
        view.id = viewId
        if (widgetId != null) {
            view.tag = widgetId
            widgetViews[widgetId] = view
        }
    }

    override fun getView(): View = view

    override fun dispose() {
        if (widgetId != null) {
            widgetViews.remove(widgetId, view)
        }
        (view.parent as? android.view.ViewGroup)?.removeView(view)
    }
}

class PaymentElementPlatformViewFactory(
    private val widgetViews: ConcurrentHashMap<String, HyperswitchElement>
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        return PaymentElementPlatformView(context, viewId, params, widgetViews)
    }
}

class CvcWidgetPlatformView(
    context: Context,
    viewId: Int,
    args: Map<String, Any?>?,
    private val widgetViews: ConcurrentHashMap<String, HyperswitchElement>
) : PlatformView {
    private val view: CVCWidget = CVCWidget(context)
    private val widgetId: String? = args?.get("widgetId") as? String

    init {
        view.id = viewId
        if (widgetId != null) {
            view.tag = widgetId
            widgetViews[widgetId] = view
        }
    }

    override fun getView(): View = view

    override fun dispose() {
        if (widgetId != null) {
            widgetViews.remove(widgetId, view)
        }
        (view.parent as? android.view.ViewGroup)?.removeView(view)
    }
}

class CvcWidgetPlatformViewFactory(
    private val widgetViews: ConcurrentHashMap<String, HyperswitchElement>
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        return CvcWidgetPlatformView(context, viewId, params, widgetViews)
    }
}
