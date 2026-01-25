import 'flutter_hyperswitch_platform_interface.dart';
import 'types.dart';
export 'types.dart';

/// A class providing methods to interact with Hyperswitch functionality.
class FlutterHyperswitch {
  final Map<String, SessionPaymentMethodOrError> _sessionMap = {};

  /// Initializes the payment sheet with the provided [HyperConfig].
  void init(HyperConfig config) {
    FlutterHyperswitchPlatform.instance.init(config.toJson());
  }

  /// Initializes the payment session with the provided [PaymentMethodParams].
  ///
  /// Returns a `Future` that completes with the initialized session id.
  Future<Session> initPaymentSession(PaymentMethodParams params) async {
    try {
      final response = await FlutterHyperswitchPlatform.instance
          .initPaymentSession(params.toJson());
      if (response == null) {
        return Future.error(
          HyperswitchException(
            code: "failed",
            message: "Payment Session Initialization Failed",
          ),
        );
      } else {
        final type = response['type'] ?? "failed";
        final message =
            response['message'] ?? "Payment Session Initialization Failed";
        if (type != "failed") {
          _sessionMap[params.clientSecret] = Session(response['message']);
          return Session(response['message']);
        } else {
          return Future.error(
            HyperswitchException(code: type, message: message),
          );
        }
      }
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "failed",
          message: "Payment Session Initialization Failed: $error",
        ),
      );
    }
  }

  /// Initializes the saved payment method session.
  ///
  /// Returns a `Future` that completes with the initialized payment method [Session].
  Future<SavedSession> getCustomerSavedPaymentMethods(Session session) async {
    final sessionChecker = _sessionMap[session.sessionData];
    if (sessionChecker == null) {
      return Future.error(
        HyperswitchException(code: "error", message: "Session Id Mismatch"),
      );
    }
    try {
      await FlutterHyperswitchPlatform.instance
              .getCustomerSavedPaymentMethods() ??
          {};
      return SavedSession(session.sessionData);
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Get Customer Saved Payment Methods Failed: $error",
        ),
      );
    }
  }

  /// Retrieves the appropriate default saved payment method data based on the response type.
  ///
  /// Returns a [PaymentMethodResponse] that completes with the result of presenting the payment sheet with the provided [SavedSession].
  Future<PaymentMethodResponse> getCustomerDefaultSavedPaymentMethodData(
    SavedSession session,
  ) async {
    final sessionChecker = _sessionMap[session.sessionData];
    if (sessionChecker == null) {
      return Future.error(
        HyperswitchException(code: "error", message: "Session Id Mismatch"),
      );
    }
    try {
      final response =
          await FlutterHyperswitchPlatform.instance
              .getCustomerSavedPaymentMethodData() ??
          {};
      switch (response["type"]) {
        case "success":
          return PaymentMethod.fromMap(
            Map<String, dynamic>.from(response["message"]),
          );
        default:
          if (response["message"] == 'Not Initialised') {
            return Future.error(
              HyperswitchException(
                code: "error",
                message: "getCustomerSavedPaymentMethods not initialised",
              ),
            );
          }
          return PaymentMethodError.fromMap(
            Map<String, dynamic>.from(response["message"]),
          );
      }
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Get Customer Default Saved Payment Methods Failed: $error",
        ),
      );
    }
  }

  /// Confirms payment with the default customer payment method.
  ///
  /// Returns a `Future` that completes with the result of presenting the payment sheet with the provided [SavedSession].
  Future<PaymentResult> confirmWithCustomerDefaultPaymentMethod(
    SavedSession session,
  ) async {
    if (session.sessionData == '') {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "getCustomerSavedPaymentMethods not initialised",
        ),
      );
    }
    try {
      _sessionMap[session.sessionData] = Session(session.sessionData);
      final response =
          await FlutterHyperswitchPlatform.instance
              .confirmWithCustomerDefaultPaymentMethod() ??
          {};
      return PaymentResult.fromMap(response);
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Confirm Payment Failed: $error",
        ),
      );
    }
  }

  /// Retrieves the appropriate last used saved payment method data based on the response type.
  ///
  /// Returns a [PaymentMethodResponse] that completes with the result of presenting the payment sheet with the provided [SavedSession].
  Future<PaymentMethodResponse> getCustomerLastUsedPaymentMethodData(
    SavedSession session,
  ) async {
    final sessionChecker = _sessionMap[session.sessionData];
    if (sessionChecker == null) {
      return Future.error(
        HyperswitchException(code: "error", message: "Session Id Mismatch"),
      );
    }
    try {
      final response =
          await FlutterHyperswitchPlatform.instance
              .getCustomerLastUsedPaymentMethodData() ??
          {};
      switch (response["type"]) {
        case "success":
          return PaymentMethod.fromMap(
            Map<String, dynamic>.from(response["message"]),
          );
        default:
          if (response["message"] == 'Not Initialised') {
            return Future.error(
              HyperswitchException(
                code: "error",
                message: "getCustomerSavedPaymentMethods not initialised",
              ),
            );
          }
          return PaymentMethodError.fromMap(
            Map<String, dynamic>.from(response["message"]),
          );
      }
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Get Customer Last Used Payment Methods Failed: $error",
        ),
      );
    }
  }

  /// Confirms payment with the default customer payment method.
  ///
  /// Returns a `Future` that completes with the result of presenting the payment sheet with the provided [SavedSession].
  Future<PaymentResult> confirmWithLastUsedPaymentMethod(
    SavedSession session,
  ) async {
    if (session.sessionData == '') {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "getCustomerSavedPaymentMethods not initialised",
        ),
      );
    }
    try {
      _sessionMap[session.sessionData] = Session(session.sessionData);
      final response =
          await FlutterHyperswitchPlatform.instance
              .confirmWithLastUsedPaymentMethod() ??
          {};
      return PaymentResult.fromMap(response);
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Confirm Payment Failed: $error",
        ),
      );
    }
  }

  /// Presents the payment sheet.
  ///
  /// Returns a `Future` that completes with the result of presenting the payment sheet with the provided [Session].
  Future<PaymentResult> presentPaymentSheet(Session session) async {
    final sessionChecker = _sessionMap[session.sessionData];
    if (sessionChecker == null ||
        (sessionChecker is Session &&
            (sessionChecker.sessionData != session.sessionData))) {
      return Future.error(
        HyperswitchException(code: "error", message: "Session Id Mismatch"),
      );
    }
    try {
      final response =
          await FlutterHyperswitchPlatform.instance.presentPaymentSheet() ?? {};
      return PaymentResult.fromMap(response);
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Present Payment Sheet Failed: $error",
        ),
      );
    }
  }
}
