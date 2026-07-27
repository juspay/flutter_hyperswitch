import Flutter
import UIKit

/// Host view for an SDK widget. The widget itself is attached later, during
/// `createElement`, once the payment session exists.
class WidgetContainerView: UIView {
    var hostedWidget: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let widget = hostedWidget {
                widget.frame = bounds
                addSubview(widget)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hostedWidget?.frame = bounds
    }
}

final class PaymentElementContainerView: WidgetContainerView {}
final class CvcWidgetContainerView: WidgetContainerView {}

class HyperswitchPlatformView: NSObject, FlutterPlatformView {
    private let container: WidgetContainerView
    private let widgetId: String?
    private weak var plugin: FlutterHyperswitchPlugin?

    init(
        frame: CGRect,
        args: [String: Any]?,
        plugin: FlutterHyperswitchPlugin?,
        container: WidgetContainerView
    ) {
        self.container = container
        self.container.frame = frame
        self.widgetId = args?["widgetId"] as? String
        self.plugin = plugin
        super.init()
        if let widgetId = widgetId {
            plugin?.registerContainer(widgetId: widgetId, container: container)
        }
    }

    func view() -> UIView { container }

    deinit {
        if let widgetId = widgetId {
            plugin?.unregisterContainer(widgetId: widgetId, container: container)
        }
    }
}

class PaymentElementPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private weak var plugin: FlutterHyperswitchPlugin?

    init(plugin: FlutterHyperswitchPlugin) {
        self.plugin = plugin
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        HyperswitchPlatformView(
            frame: frame,
            args: args as? [String: Any],
            plugin: plugin,
            container: PaymentElementContainerView()
        )
    }
}

class CvcWidgetPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private weak var plugin: FlutterHyperswitchPlugin?

    init(plugin: FlutterHyperswitchPlugin) {
        self.plugin = plugin
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        HyperswitchPlatformView(
            frame: frame,
            args: args as? [String: Any],
            plugin: plugin,
            container: CvcWidgetContainerView()
        )
    }
}
