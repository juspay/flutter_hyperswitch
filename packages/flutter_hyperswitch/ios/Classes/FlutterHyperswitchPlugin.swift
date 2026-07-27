import Flutter
import Hyperswitch
import UIKit

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "flutter_hyperswitch", code: 0)
        }
        return dictionary
    }
}

public class FlutterHyperswitchPlugin: NSObject, FlutterPlugin {

    private var channel: FlutterMethodChannel?
    private var eventSink: FlutterEventSink?
    private var registrar: FlutterPluginRegistrar?

    private var hyperswitch: Hyperswitch?
    private var paymentSession: PaymentSession?
    private var handler: PaymentSessionHandler?
    private var params: [String: Any] = [:]
    private var elementsInitialised = false

    // All registries are main-thread confined: Flutter method-channel calls
    // arrive on the main thread and SDK callbacks are re-dispatched to it.
    private var containers: [String: WidgetContainerView] = [:]
    private var paymentWidgets: [String: PaymentWidget] = [:]
    private var cvcWidgets: [String: CVCWidget] = [:]
    private var widgetConfigs: [String: (type: String, configuration: [String: Any]?)] = [:]
    private var pendingConfirmCallbacks: [String: (Bool) -> Void] = [:]
    private var pendingConfirmResults: [String: FlutterResult] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_hyperswitch", binaryMessenger: registrar.messenger())
        let instance = FlutterHyperswitchPlugin()
        instance.channel = channel
        instance.registrar = registrar
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(name: "flutter_hyperswitch/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)

        registrar.register(
            PaymentElementPlatformViewFactory(plugin: instance),
            withId: "hyperswitch_payment_element"
        )
        registrar.register(
            CvcWidgetPlatformViewFactory(plugin: instance),
            withId: "hyperswitch_cvc_widget"
        )
    }

    // MARK: - Container registry (called by platform views)

    func registerContainer(widgetId: String, container: WidgetContainerView) {
        DispatchQueue.main.async {
            self.containers[widgetId] = container
        }
    }

    func unregisterContainer(widgetId: String, container: WidgetContainerView) {
        DispatchQueue.main.async {
            if self.containers[widgetId] === container {
                self.containers.removeValue(forKey: widgetId)
            }
        }
    }

    // MARK: - Event emission

    private func emitWidgetEvent(_ widgetId: String, _ type: String, _ payload: [String: Any]) {
        DispatchQueue.main.async {
            self.eventSink?([
                "widgetId": widgetId,
                "type": type,
                "payload": payload,
            ])
        }
    }

    private func emitSheetEvent(_ eventName: String, _ payload: [String: Any]) {
        DispatchQueue.main.async {
            self.eventSink?([
                "eventName": eventName,
                "payload": payload,
            ])
        }
    }

    // MARK: - Helpers

    private func paymentResultToDict(_ result: PaymentResult) -> [String: Any] {
        switch result {
        case .completed(let data):
            return ["type": "completed", "message": data]
        case .canceled(let data):
            return ["type": "canceled", "message": data]
        case .failed(let error):
            return ["type": "failed", "message": error.localizedDescription]
        }
    }

    private static let notInitialisedMap: [String: Any] = [
        "type": "failed",
        "message": "Not Initialised",
    ]

    private func failedMap(_ message: String) -> [String: Any] {
        ["type": "failed", "message": message]
    }

    private func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    private func subscribedEvents(from configuration: [String: Any]?) -> [String] {
        guard let raw = configuration?["subscribedEvents"] else { return [] }
        if let arr = raw as? [String] { return arr }
        if let arr = raw as? [Any] { return arr.compactMap { $0 as? String } }
        return []
    }

    private func bindPaymentEvents(
        builder: PaymentEventSubscriptionBuilder,
        subscribed: [String],
        emit: @escaping (String, [String: Any]) -> Void
    ) {
        if subscribed.contains(PaymentEventType.formStatus.rawValue) {
            builder.on(.formStatus) { event in
                emit(PaymentEventType.formStatus.rawValue, event.payload)
            }
        }
        if subscribed.contains(PaymentEventType.paymentMethodStatus.rawValue) {
            builder.on(.paymentMethodStatus) { event in
                emit(PaymentEventType.paymentMethodStatus.rawValue, event.payload)
            }
        }
        if subscribed.contains(PaymentEventType.paymentMethodInfoCard.rawValue) {
            builder.on(.paymentMethodInfoCard) { event in
                emit(PaymentEventType.paymentMethodInfoCard.rawValue, event.payload)
            }
        }
        if subscribed.contains(PaymentEventType.paymentMethodInfoBillingAddress.rawValue) {
            builder.on(.paymentMethodInfoBillingAddress) { event in
                emit(PaymentEventType.paymentMethodInfoBillingAddress.rawValue, event.payload)
            }
        }
    }

    // MARK: - Element binding

    /// Creates (or re-creates) the SDK widget for `widgetId` and attaches it
    /// to its registered platform-view container. Shared by `createElement`
    /// and the post-updateIntent refresh.
    private func attachElement(
        type: String,
        widgetId: String,
        configuration: [String: Any]?
    ) -> [String: Any] {
        guard elementsInitialised, let paymentSession = paymentSession, let hyperswitch = hyperswitch else {
            return failedMap("elements() not called")
        }
        guard let container = containers[widgetId] else {
            return failedMap("PlatformView for widgetId=\(widgetId) not found")
        }

        registerCustomFonts(configuration: configuration)

        var configMap = configuration ?? [:]
        let subscribed = subscribedEvents(from: configuration)
        configMap.removeValue(forKey: "subscribedEvents")

        // Re-create: drop any previous binding for this widgetId.
        paymentWidgets.removeValue(forKey: widgetId)
        cvcWidgets.removeValue(forKey: widgetId)
        pendingConfirmCallbacks.removeValue(forKey: widgetId)
        if let stale = pendingConfirmResults.removeValue(forKey: widgetId) {
            stale(failedMap("Element was re-created"))
        }

        if type == "paymentElement" || type == "payment" {
            guard container is PaymentElementContainerView else {
                return failedMap("PlatformView for widgetId=\(widgetId) is not a PaymentElement")
            }
            let widget = PaymentWidget(
                paymentSession: paymentSession,
                configurationDict: configMap,
                completion: { [weak self] paymentResult in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        let dict = self.paymentResultToDict(paymentResult)
                        if let pending = self.pendingConfirmResults.removeValue(forKey: widgetId) {
                            pending(dict)
                        }
                        self.emitWidgetEvent(widgetId, "onPaymentResult", dict)
                    }
                },
                subscribe: { [weak self] builder in
                    self?.bindPaymentEvents(builder: builder, subscribed: subscribed) { type, payload in
                        self?.emitWidgetEvent(widgetId, type, payload)
                    }
                }
            )
            widget.shouldProceedWithPayment { [weak self] data, callback in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.pendingConfirmCallbacks[widgetId] = callback
                    let payload = (try? data.asDictionary()) ?? [:]
                    self.emitWidgetEvent(widgetId, "onPaymentConfirmButtonClick", payload)
                }
            }
            container.hostedWidget = widget
            paymentWidgets[widgetId] = widget
            widgetConfigs[widgetId] = (type: type, configuration: configuration)
            return ["type": "success"]

        } else if type == "cvcWidget" || type == "cvc" {
            guard container is CvcWidgetContainerView else {
                return failedMap("PlatformView for widgetId=\(widgetId) is not a CvcWidget")
            }
            let widget = CVCWidget(
                hyperswitch: hyperswitch,
                configurationDict: configMap,
                subscribe: { [weak self] builder in
                    builder.on(.cvcStatus) { event in
                        self?.emitWidgetEvent(widgetId, PaymentEventType.cvcStatus.rawValue, event.payload)
                    }
                }
            )
            container.hostedWidget = widget
            cvcWidgets[widgetId] = widget
            widgetConfigs[widgetId] = (type: type, configuration: configuration)
            return ["type": "success"]

        } else {
            return failedMap("Unknown element type: \(type)")
        }
    }

    /// The SDK's `updateIntent` swaps the session authorization but never
    /// notifies mounted widgets (its internal init/complete flow is disabled),
    /// so re-attach every bound widget — a fresh widget reads the updated
    /// authorization from the session.
    private func refreshBoundElements() {
        for (widgetId, info) in widgetConfigs where containers[widgetId] != nil {
            _ = attachElement(type: info.type, widgetId: widgetId, configuration: info.configuration)
        }
    }

    // MARK: - Custom fonts

    private func findFontFile(named fileName: String) -> String? {
        let fileManager = FileManager.default
        guard let bundlePath = Bundle.main.privateFrameworksPath else { return nil }

        let flutterAssetsPath = (bundlePath as NSString)
            .appendingPathComponent("App.framework/flutter_assets/fonts")
        var foundPath: String?

        func searchDirectory(_ directoryPath: String) {
            guard foundPath == nil,
                  let contents = try? fileManager.contentsOfDirectory(atPath: directoryPath) else {
                return
            }
            for item in contents {
                let fullPath = (directoryPath as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) else {
                    continue
                }
                if isDirectory.boolValue {
                    searchDirectory(fullPath)
                } else if item == fileName {
                    foundPath = fullPath
                    return
                }
            }
        }
        searchDirectory(flutterAssetsPath)
        return foundPath
    }

    /// Resolves a Flutter font asset to an on-disk path, preferring the
    /// official registrar asset lookup and falling back to walking
    /// App.framework/flutter_assets/fonts.
    private func fontAssetPath(fileName: String) -> String? {
        if let key = registrar?.lookupKey(forAsset: "fonts/\(fileName)"),
           let path = Bundle.main.path(forResource: key, ofType: nil) {
            return path
        }
        return findFontFile(named: fileName)
    }

    private func registerFontVariant(_ fontName: String) {
        // The family may contain spaces (e.g. "Press Start 2P") while font
        // files conventionally don't, so also try a space-stripped file name.
        let strippedName = fontName.replacingOccurrences(of: " ", with: "")
        if UIFont(name: fontName, size: 12) != nil || UIFont(name: strippedName, size: 12) != nil {
            return
        }
        let fileBases = fontName == strippedName ? [fontName] : [fontName, strippedName]
        guard let fontPath = fileBases
            .compactMap({ fontAssetPath(fileName: "\($0).ttf") })
            .first else { return }
        guard let fontData = NSData(contentsOfFile: fontPath),
              let dataProvider = CGDataProvider(data: fontData),
              let fontRef = CGFont(dataProvider) else {
            print("[Hyperswitch] Failed to load font data: \(fontPath)")
            return
        }
        var errorRef: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) {
            print("[Hyperswitch] Registered font \(fontRef.postScriptName as String? ?? fontName) from \(fontName).ttf")
        } else if let error = errorRef?.takeUnretainedValue() {
            print("[Hyperswitch] Failed to register font \(fontName): \(error)")
        }
    }

    /// Registers Flutter-asset fonts so the SDK can resolve
    /// `appearance.font.family`.
    ///
    /// CoreText registers fonts under their *embedded* family name — there is
    /// no alias mechanism — so on iOS the configured family string must equal
    /// the font's internal family name (e.g. "Press Start 2P", not the
    /// filename base "PressStart2P").
    private func registerCustomFonts(configuration: [String: Any]?) {
        guard let appearance = configuration?["appearance"] as? [String: Any],
              let fontDict = appearance["font"] as? [String: Any],
              let family = fontDict["family"] as? String else { return }

        let suffixes = [
            "Black", "BlackItalic", "Bold", "BoldItalic",
            "ExtraBold", "ExtraBoldItalic", "ExtraLight", "ExtraLightItalic",
            "Italic", "Light", "LightItalic", "Medium", "MediumItalic",
            "Regular", "SemiBold", "SemiBoldItalic", "Thin", "ThinItalic",
        ]
        registerFontVariant(family)
        for suffix in suffixes {
            registerFontVariant("\(family)-\(suffix)")
        }

        if UIFont.fontNames(forFamilyName: family).isEmpty && UIFont(name: family, size: 12) == nil {
            print(
                "[Hyperswitch] Warning: no registered font resolves for family "
                + "'\(family)'. On iOS the configured family must match the "
                + "font's embedded family name, which may differ from its "
                + "filename (check the registration logs above for the actual "
                + "names)."
            )
        }
    }

    // MARK: - Method channel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]

        switch call.method {

        case "init":
            if let callParams = arguments?["params"] as? [String: Any] {
                params.merge(callParams) { _, new in new }
            }
            let publishableKey = params["publishableKey"] as? String ?? ""
            let profileId = params["profileId"] as? String

            // Dart's toJson emits explicit nulls, which arrive as NSNull —
            // cast to String first so absent values are genuinely nil.
            let legacyBackendUrl = params["customBackendUrl"] as? String
            let legacyLogUrl = params["customLogUrl"] as? String

            var customEndpointConfiguration: CustomEndpointConfiguration?
            let customEndpoints = params["customEndpoints"] as? [String: Any]
            if let commonEndpoint = customEndpoints?["commonEndpoint"] as? String {
                customEndpointConfiguration = CustomEndpointConfiguration.commonEndpoint(commonEndpoint)
            }
            if let overrideEndpoints = customEndpoints?["overrideEndpoints"] as? [String: Any] {
                let config = OverrideEndpointConfiguration(
                    customBackendEndpoint: overrideEndpoints["customBackendEndpoint"] as? String
                        ?? legacyBackendUrl,
                    customAssetEndpoint: overrideEndpoints["customAssetEndpoint"] as? String,
                    customSDKConfigEndpoint: overrideEndpoints["customSDKConfigEndpoint"] as? String,
                    customAirborneEndpoint: overrideEndpoints["customAirborneEndpoint"] as? String,
                    customLoggingEndpoint: overrideEndpoints["customLoggingEndpoint"] as? String
                        ?? legacyLogUrl
                )
                customEndpointConfiguration = CustomEndpointConfiguration.overrideEndpoints(config)
            } else if legacyBackendUrl != nil || legacyLogUrl != nil {
                let config = OverrideEndpointConfiguration(
                    customBackendEndpoint: legacyBackendUrl,
                    customAssetEndpoint: nil,
                    customSDKConfigEndpoint: nil,
                    customAirborneEndpoint: nil,
                    customLoggingEndpoint: legacyLogUrl
                )
                customEndpointConfiguration = CustomEndpointConfiguration.overrideEndpoints(config)
            }

            // The iOS SDK has no INTEG environment; anything other than
            // SANDBOX resolves to production.
            let environment: HyperswitchEnvironment =
                (params["environment"] as? String)?.uppercased() == "SANDBOX" ? .sandbox : .production

            hyperswitch = Hyperswitch(
                configuration: HyperswitchConfiguration(
                    publishableKey: publishableKey,
                    profileId: profileId,
                    customEndpoints: customEndpointConfiguration,
                    environment: environment
                )
            )
            result(nil)

        case "initPaymentSession":
            if let callParams = arguments?["params"] as? [String: Any] {
                params.merge(callParams) { _, new in new }
            }
            registerCustomFonts(configuration: params["configuration"] as? [String: Any])

            let sdkAuthorization = params["sdkAuthorization"] as? String ?? ""
            if sdkAuthorization.isEmpty {
                result(failedMap("sdkAuthorization is required"))
                return
            }
            guard let hyperswitch = hyperswitch else {
                result(failedMap("Hyperswitch not initialised"))
                return
            }
            paymentSession = hyperswitch.initPaymentSession(
                configuration: PaymentSessionConfiguration(sdkAuthorization: sdkAuthorization)
            )
            result(["type": "success", "message": sdkAuthorization])

        case "elements":
            if let callParams = arguments?["params"] as? [String: Any] {
                params.merge(callParams) { _, new in new }
            }
            registerCustomFonts(configuration: params["configuration"] as? [String: Any])

            let sdkAuthorization = params["sdkAuthorization"] as? String ?? ""
            if sdkAuthorization.isEmpty {
                result(failedMap("sdkAuthorization is required"))
                return
            }
            guard let hyperswitch = hyperswitch else {
                result(failedMap("Hyperswitch not initialised"))
                return
            }
            paymentSession = hyperswitch.initPaymentSession(
                configuration: PaymentSessionConfiguration(sdkAuthorization: sdkAuthorization)
            )
            elementsInitialised = true
            result(["type": "success", "message": sdkAuthorization])

        case "createElement":
            let createParams = arguments?["params"] as? [String: Any] ?? [:]
            let type = createParams["type"] as? String ?? ""
            let widgetId = createParams["widgetId"] as? String ?? ""
            let configuration = createParams["configuration"] as? [String: Any]

            if widgetId.isEmpty {
                result(failedMap("widgetId is required"))
                return
            }
            result(attachElement(type: type, widgetId: widgetId, configuration: configuration))

        case "confirmPayment":
            let widgetId = arguments?["widgetId"] as? String ?? ""
            guard let widget = paymentWidgets[widgetId] else {
                result(failedMap("PaymentElement not bound for widgetId=\(widgetId)"))
                return
            }
            if let superseded = pendingConfirmResults.removeValue(forKey: widgetId) {
                superseded(failedMap("Superseded by a newer confirmPayment call"))
            }
            pendingConfirmResults[widgetId] = result
            widget.confirm()

        case "resolvePaymentConfirmButtonClick":
            let widgetId = arguments?["widgetId"] as? String ?? ""
            let proceed = arguments?["proceed"] as? Bool ?? false
            let callback = pendingConfirmCallbacks.removeValue(forKey: widgetId)
            callback?(proceed)
            result(nil)

        case "destroyElement":
            let widgetId = arguments?["widgetId"] as? String ?? ""
            paymentWidgets.removeValue(forKey: widgetId)
            cvcWidgets.removeValue(forKey: widgetId)
            widgetConfigs.removeValue(forKey: widgetId)
            pendingConfirmCallbacks.removeValue(forKey: widgetId)
            pendingConfirmResults.removeValue(forKey: widgetId)
            containers[widgetId]?.hostedWidget = nil
            result(nil)

        case "presentPaymentSheet":
            if let callParams = arguments?["params"] as? [String: Any] {
                params.merge(callParams) { _, new in new }
            }
            // The sheet configuration (and its font) often arrives only here.
            registerCustomFonts(configuration: params["configuration"] as? [String: Any])
            guard params["publishableKey"] != nil else {
                result(failedMap("Payment Sheet Initialisation Failed"))
                return
            }
            guard let paymentSession = paymentSession else {
                result(Self.notInitialisedMap)
                return
            }
            guard let viewController = topViewController() else {
                result(failedMap("Unable to resolve a view controller to present from"))
                return
            }
            // The SDK nests these params under props.configuration itself,
            // so pass the configuration map only.
            let configuration = params["configuration"] as? [String: Any] ?? [:]
            let subscribed = subscribedEvents(from: configuration)

            paymentSession.presentPaymentSheetWithParams(
                viewController: viewController,
                params: configuration,
                subscribe: { [weak self] builder in
                    self?.bindPaymentEvents(builder: builder, subscribed: subscribed) { type, payload in
                        self?.emitSheetEvent(type, payload)
                    }
                },
                completion: { [weak self] paymentResult in
                    guard let self = self else { return }
                    result(self.paymentResultToDict(paymentResult))
                }
            )

        case "getCustomerSavedPaymentMethods":
            guard let paymentSession = paymentSession else {
                result(Self.notInitialisedMap)
                return
            }
            let sdkAuthorization = params["sdkAuthorization"] as? String ?? ""
            paymentSession.getCustomerSavedPaymentMethods({ [weak self] handler in
                DispatchQueue.main.async {
                    self?.handler = handler
                    result(["type": "success", "message": sdkAuthorization])
                }
            })

        case "getCustomerSavedPaymentMethodData":
            guard let handler = handler else {
                result(Self.notInitialisedMap)
                return
            }
            switch handler.getCustomerDefaultSavedPaymentMethodData() {
            case .success(let paymentMethod):
                let dict = (try? paymentMethod.asDictionary()) ?? [:]
                result(["type": "success", "message": dict])
            case .failure(let error):
                result(["type": "failure", "message": ["code": error.code, "message": error.message]])
            }

        case "getCustomerLastUsedPaymentMethodData":
            guard let handler = handler else {
                result(Self.notInitialisedMap)
                return
            }
            switch handler.getCustomerLastUsedPaymentMethodData() {
            case .success(let paymentMethod):
                let dict = (try? paymentMethod.asDictionary()) ?? [:]
                result(["type": "success", "message": dict])
            case .failure(let error):
                result(["type": "failure", "message": ["code": error.code, "message": error.message]])
            }

        case "confirmWithCustomerDefaultPaymentMethod":
            guard let handler = handler else {
                result(Self.notInitialisedMap)
                return
            }
            // The iOS SDK's default-payment-method confirm has no CVC widget
            // variant; a supplied widgetId is ignored.
            handler.confirmWithCustomerDefaultPaymentMethod { [weak self] paymentResult in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    result(self.paymentResultToDict(paymentResult))
                }
            }

        case "confirmWithCustomerLastUsedPaymentMethod":
            guard let handler = handler else {
                result(Self.notInitialisedMap)
                return
            }
            let widgetId = arguments?["widgetId"] as? String
            guard let widgetId = widgetId, let cvcWidget = cvcWidgets[widgetId] else {
                result(failedMap(
                    "The iOS SDK requires a mounted CvcWidget for confirmWithLastUsedPaymentMethod — pass its widgetId"
                ))
                return
            }
            handler.confirmWithCustomerLastUsedPaymentMethod(cvcWidget) { [weak self] paymentResult in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    result(self.paymentResultToDict(paymentResult))
                }
            }

        case "confirmWithCustomerPaymentToken":
            guard let handler = handler else {
                result(Self.notInitialisedMap)
                return
            }
            let paymentToken = arguments?["paymentToken"] as? String ?? ""
            handler.confirmWithCustomerPaymentToken(paymentToken: paymentToken) { [weak self] paymentResult in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    result(self.paymentResultToDict(paymentResult))
                }
            }

        case "updateIntent":
            let sdkAuthorization = arguments?["sdkAuthorization"] as? String ?? ""
            if sdkAuthorization.isEmpty {
                result(failedMap("sdkAuthorization is required"))
                return
            }
            guard let paymentSession = paymentSession else {
                result(Self.notInitialisedMap)
                return
            }
            params["sdkAuthorization"] = sdkAuthorization
            paymentSession.updateIntent(
                authorizationProvider: { provide in provide(sdkAuthorization) },
                completion: { [weak self] updateResult in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch updateResult {
                        case .success:
                            result(["type": "success"])
                        case .cancelled:
                            result(self.failedMap("Update intent cancelled"))
                        case .failure(let error):
                            result(self.failedMap(error.localizedDescription))
                        }
                    }
                }
            )

        case "updateElementsIntent":
            guard elementsInitialised, let paymentSession = paymentSession else {
                result(failedMap("Elements not initialised"))
                return
            }
            channel?.invokeMethod("resolveElementsIntent", arguments: nil) { [weak self] response in
                guard let self = self else { return }
                if response is FlutterError || (response as? NSObject) == FlutterMethodNotImplemented {
                    result(self.failedMap("Intent resolver failed"))
                    return
                }
                guard let configuration = response as? [String: Any],
                      let sdkAuthorization = configuration["sdkAuthorization"] as? String,
                      !sdkAuthorization.trimmingCharacters(in: .whitespaces).isEmpty else {
                    result(self.failedMap("sdkAuthorization is required"))
                    return
                }
                self.params["sdkAuthorization"] = sdkAuthorization
                paymentSession.updateIntent(
                    authorizationProvider: { provide in provide(sdkAuthorization) },
                    completion: { updateResult in
                        DispatchQueue.main.async {
                            switch updateResult {
                            case .success:
                                self.refreshBoundElements()
                                result(["type": "success"])
                            case .cancelled:
                                result(self.failedMap("Update intent cancelled"))
                            case .failure(let error):
                                result(self.failedMap(error.localizedDescription))
                            }
                        }
                    }
                )
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - FlutterStreamHandler

extension FlutterHyperswitchPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
