import Flutter
import Hyperswitch
import UIKit

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

public class FlutterHyperswitchPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_hyperswitch", binaryMessenger: registrar.messenger())
        let instance = FlutterHyperswitchPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func findFontFile(named fileName: String) -> String? {
        let fileManager = FileManager.default
        guard let bundlePath = Bundle.main.privateFrameworksPath else { return nil }

        //MARK: Assuming that default flutter structure is intact.
        let flutterAssetsPath = (bundlePath as NSString).appendingPathComponent("App.framework/flutter_assets/fonts")
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

    var paymentSession: PaymentSession?
    var params: [String: Any] = [:]
    var confirmWithDefault: ((String?, @escaping (PaymentResult) -> Void ) -> Void)?
    var confirmWithLastUsed: ((String?, @escaping (PaymentResult) -> Void ) -> Void)?
    var handler: PaymentSessionHandler?

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        func initSavedPaymentMethodSessionCallback(handler: PaymentSessionHandler)-> Void {
            self.handler = handler
            result(["type": "success", "message": "clientSecret"])
        }

        func resultHandler(_ paymentResult: PaymentResult) {
            switch paymentResult {
            case .completed(let data):
                result(["type": "completed", "message": data])
            case .canceled(let data):
                result(["type": "canceled", "message": data])
            case .failed(let error):
                result(["type": "failed", "message": "\(error)"])
            }
        }

        switch call.method {

        case "init":
            if let params = call.arguments as? [String: Any] {
                if let argumentValue = params["params"] as? [String: Any] {
                    if let publishableKey = argumentValue["publishableKey"] as? String {
                        let customBackendUrl = argumentValue["customBackendUrl"] as? String
                        let customLogUrl = argumentValue["customLogUrl"] as? String
                        let customParams = argumentValue["customParams"] as? [String:Any]
                        self.params.merge(argumentValue, uniquingKeysWith: {_, new in new})
                        paymentSession = PaymentSession(publishableKey: publishableKey, customBackendUrl: customBackendUrl, customParams: customParams, customLogUrl: customLogUrl)
                    }
                }
            }
        case "initPaymentSession":
            if let params = call.arguments as? [String: Any],
               let argumentValue = params["params"] as? [String: Any],
               let clientSecret = argumentValue["clientSecret"] as? String {

                if let config = argumentValue["configuration"] as? [String: Any],
                   let appearance = config["appearance"] as? [String: Any],
                   let typography = appearance["typography"] as? [String: Any],
                   let fontFamily = typography["fontResId"] as? String {

                    let fonts = [
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
                    ]

                    for font in fonts {
                        let fontName = "\(fontFamily)-\(font)"

                        //MARK: Skip if already registered.
                        if let _ = UIFont(name: fontName, size: 12) {
                            continue
                        }

                        let fileName = "\(fontName).ttf"
                        if let fontPath = findFontFile(named: fileName) {
                            do {
                                let fontData = try NSData(contentsOfFile: fontPath, options: .mappedIfSafe)
                                if let dataProvider = CGDataProvider(data: fontData),
                                   let fontRef = CGFont(dataProvider) {
                                    var errorRef: Unmanaged<CFError>? = nil
                                    if !CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) {
                                        if let error = errorRef?.takeUnretainedValue() {
                                            print("Failed to register font \(fontName): \(error)")
                                        }
                                    } else {
                                        print("Successfully registered font: \(fontName)")
                                    }
                                }
                            } catch {
                                print("Error loading font \(fontName): \(error.localizedDescription)")
                            }
                        } else {
                            print("Font file not found: \(fileName)")
                        }
                    }
                }

                self.params["from"] = "flutter"
                self.params.merge(argumentValue, uniquingKeysWith: {_, new in new})
                paymentSession?.initPaymentSession(paymentIntentClientSecret: clientSecret)
                result(["type": "success", "message": clientSecret])
            } else {
                result(["type": "failed", "message": "Payment Session Initialization Failed"])
            }

        case "getCustomerSavedPaymentMethods":
            paymentSession?.getCustomerSavedPaymentMethods(initSavedPaymentMethodSessionCallback)

        case "getCustomerSavedPaymentMethodData":
            let paymentMethod = handler?.getCustomerDefaultSavedPaymentMethodData()
            switch paymentMethod {
            case .success(let pm):
                let dict = try? pm.asDictionary()
                result(dict.map { ["type": "success", "message": $0] } ?? ["type": "error", "message": ["code": "2", "message": "Unknown Error"]])
            case .failure(let error):
                let dict = try? error.asDictionary()
                result(dict.map { ["type": "error", "message": $0] } ?? ["type": "error", "message": ["code": "1", "message": "Unknown Error"]])
            default:
                result(["type": "error", "message": ["code": "0", "message": "Unknown Error"]])
            }

        case "confirmWithCustomerDefaultPaymentMethod":
            handler?.confirmWithCustomerDefaultPaymentMethod(resultHandler: resultHandler)

        case "getCustomerLastUsedPaymentMethodData":
            let paymentMethod = handler?.getCustomerLastUsedPaymentMethodData()
            switch paymentMethod {
            case .success(let pm):
                let dict = try? pm.asDictionary()
                result(dict.map { ["type": "success", "message": $0] } ?? ["type": "error", "message": ["code": "2", "message": "Unknown Error"]])
            case .failure(let error):
                let dict = try? error.asDictionary()
                result(dict.map { ["type": "error", "message": $0] } ?? ["type": "error", "message": ["code": "1", "message": "Unknown Error"]])
            default:
                result(["type": "error", "message": ["code": "0", "message": "Unknown Error"]])
            }

        case "confirmWithCustomerLastUsedPaymentMethod":
            handler?.confirmWithCustomerLastUsedPaymentMethod(resultHandler: resultHandler)

        case "presentPaymentSheet":
            DispatchQueue.main.async {
                guard let vc = RCTPresentedViewController() else {
                    result(["type": "failed", "message": "Payment Sheet Initialization Failed"])
                    return
                }
                self.paymentSession?.presentPaymentSheetWithParams(viewController: vc, params: self.params, completion: { result2 in
                    switch result2 {
                    case .completed(let data):
                        result(["type": "completed", "message": data])
                    case .failed(let error as NSError):
                        result(["type": "failed", "message": "Payment failed: \(error.userInfo["message"] ?? "Failed")"])
                    case .canceled(let data):
                        result(["type": "cancelled", "message": data])
                    }
                })
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
