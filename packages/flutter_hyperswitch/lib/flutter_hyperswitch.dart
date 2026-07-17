import 'dart:async';
import 'package:flutter/services.dart';
import 'flutter_hyperswitch_platform_interface.dart';
import 'types.dart';
export 'types.dart';
export 'widgets.dart';

const _eventChannel = EventChannel('flutter_hyperswitch/events');

typedef IntentResolver = Future<PaymentSessionConfiguration> Function();

/// A class providing methods to interact with Hyperswitch functionality.
class FlutterHyperswitch {
  final Map<String, SessionPaymentMethodOrError> _sessionMap = {};

  /// Initializes the payment sheet with the provided [HyperConfig].
  void init(HyperConfig config) {
    FlutterHyperswitchPlatform.instance.init(config.toJson());
  }

  /// Initializes the payment session with the provided [PaymentSessionConfiguration].
  ///
  /// Returns a `Future` that completes with the initialized session id.
  Future<Session> initPaymentSession(PaymentSessionConfiguration params) async {
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
          _sessionMap[params.sdkAuthorization] = Session(response['message']);
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
    SavedSession session, {
    String? widgetId,
  }) async {
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
              .confirmWithCustomerDefaultPaymentMethod(widgetId) ??
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
    SavedSession session, {
    String? widgetId,
  }) async {
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
              .confirmWithLastUsedPaymentMethod(widgetId) ??
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

  /// Confirms payment with a specific payment token.
  ///
  /// Returns a `Future` that completes with the result of confirming the payment
  /// with the provided [paymentToken].
  Future<PaymentResult> confirmWithCustomerPaymentToken(
    SavedSession session,
    String paymentToken,
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
              .confirmWithCustomerPaymentToken(paymentToken) ??
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

  Future<Session> updateIntent(
    Session session,
    String sdkAuthorization,
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
              .updateIntent(sdkAuthorization) ??
          {};
      if (response["type"] == "success") {
        _sessionMap.remove(session.sessionData);
        _sessionMap[sdkAuthorization] = Session(sdkAuthorization);
        return Session(sdkAuthorization);
      } else {
        return Future.error(
          HyperswitchException(
            code: response["type"] ?? "error",
            message: response["message"] ?? "Update Intent Failed",
          ),
        );
      }
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Update Intent Failed: $error",
        ),
      );
    }
  }

  Future<PaymentResult> presentPaymentSheet(
    Session session, [
    Configuration? configuration,
    void Function(PaymentEvent)? onPaymentEvent,
  ]) async {
    final sessionChecker = _sessionMap[session.sessionData];
    if (sessionChecker == null ||
        (sessionChecker is Session &&
            (sessionChecker.sessionData != session.sessionData))) {
      return Future.error(
        HyperswitchException(code: "error", message: "Session Id Mismatch"),
      );
    }

    StreamSubscription? eventSubscription;
    try {
      if (onPaymentEvent != null) {
        eventSubscription = _eventChannel.receiveBroadcastStream().listen(
          (event) {
            onPaymentEvent(PaymentEvent.fromMap(event as Map<dynamic, dynamic>));
          },
        );
      }

      final params = <String, dynamic>{
        if (configuration != null) 'configuration': configuration.toJson(),
      };
      final response =
          await FlutterHyperswitchPlatform.instance.presentPaymentSheet(
            params,
          ) ??
          {};
      return PaymentResult.fromMap(response);
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "Present Payment Sheet Failed: $error",
        ),
      );
    } finally {
      await eventSubscription?.cancel();
    }
  }

  Future<Elements> elements(PaymentSessionConfiguration params) async {
    try {
      final response = await FlutterHyperswitchPlatform.instance
          .elements(params.toJson());
      if (response == null) {
        return Future.error(
          HyperswitchException(
            code: "failed",
            message: "Elements Initialization Failed",
          ),
        );
      }
      final type = response['type'] ?? "failed";
      final message =
          response['message'] ?? "Elements Initialization Failed";
      if (type != "failed") {
        final session = Session(message);
        _sessionMap[params.sdkAuthorization] = session;
        return Elements._(session, params.sdkAuthorization, (
          previousAuthorization,
          updatedSession,
        ) {
          _sessionMap.remove(previousAuthorization);
          _sessionMap[updatedSession.sessionData] = updatedSession;
        });
      } else {
        return Future.error(
          HyperswitchException(code: type, message: message),
        );
      }
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "failed",
          message: "Elements Initialization Failed: $error",
        ),
      );
    }
  }
}

class Elements {
  Session _session;
  String _sdkAuthorization;
  final void Function(String previousAuthorization, Session session)
  _onSessionUpdated;
  final Map<String, PaymentElementController> _paymentElementControllers = {};
  final Map<String, CvcWidgetController> _cvcWidgetControllers = {};
  StreamSubscription? _eventSubscription;
  bool _updateIntentInProgress = false;

  Elements._(this._session, this._sdkAuthorization, this._onSessionUpdated);

  Session get session => _session;

  Future<void> _ensureEventListener() async {
    if (_eventSubscription != null) return;
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      final map = event as Map<dynamic, dynamic>;
      final widgetId = map['widgetId'] as String?;
      if (widgetId == null) return;
      final type = map['type'] as String? ?? '';
      final payload = map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'] as Map)
          : <String, dynamic>{};

      if (_paymentElementControllers.containsKey(widgetId)) {
        final controller = _paymentElementControllers[widgetId]!;
        switch (type) {
          case 'onPaymentResult':
            controller.onPaymentResult?.call(PaymentResult.fromMap(payload));
            break;
          case 'onPaymentConfirmButtonClick':
            if (controller.onPaymentConfirmButtonClick != null) {
              final data = PaymentRequestData.fromMap(map['payload'] ?? {});
              controller.onPaymentConfirmButtonClick!(data).then((proceed) {
                resolvePaymentConfirmButtonClick(widgetId, proceed);
              });
            }
            break;
          default:
            controller.onPaymentEvent?.call(
              PaymentEvent(eventName: type, payload: payload),
            );
        }
      } else if (_cvcWidgetControllers.containsKey(widgetId)) {
        final controller = _cvcWidgetControllers[widgetId]!;
        controller.onCvcEvent?.call(
          CvcWidgetEvent(type: type, payload: payload),
        );
      }
    });
  }

  Future<void> createElement({
    required String type,
    required String widgetId,
    Configuration? configuration,
    PaymentElementController? paymentElementController,
    CvcWidgetController? cvcWidgetController,
  }) async {
    if (type == 'paymentElement') {
      if (paymentElementController == null) {
        return Future.error(
          HyperswitchException(
            code: "error",
            message: "paymentElementController is required for paymentElement",
          ),
        );
      }
      _paymentElementControllers[widgetId] = paymentElementController;
    } else if (type == 'cvcWidget') {
      if (cvcWidgetController == null) {
        return Future.error(
          HyperswitchException(
            code: "error",
            message: "cvcWidgetController is required for cvcWidget",
          ),
        );
      }
      _cvcWidgetControllers[widgetId] = cvcWidgetController;
    }

    await _ensureEventListener();

    final params = <String, dynamic>{
      'type': type,
      'widgetId': widgetId,
      'sdkAuthorization': _sdkAuthorization,
      if (configuration != null) 'configuration': configuration.toJson(),
    };

    const maxAttempts = 120;
    const retryDelay = Duration(milliseconds: 16);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await FlutterHyperswitchPlatform.instance
            .createElement(params);
        if (response != null && response['type'] == 'failed') {
          final message = response['message'] ?? '';
          if (message.contains('not found') && attempt < maxAttempts - 1) {
            await Future.delayed(retryDelay);
            continue;
          }
          return Future.error(
            HyperswitchException(
              code: response['type'] ?? 'error',
              message: message,
            ),
          );
        }
        return;
      } catch (error) {
        return Future.error(
          HyperswitchException(
            code: "error",
            message: "createElement Failed: $error",
          ),
        );
      }
    }
  }

  Future<Session> updateIntent(IntentResolver intentResolver) async {
    if (_updateIntentInProgress) {
      throw HyperswitchException(
        code: 'already_in_progress',
        message: 'An Elements intent update is already in progress',
      );
    }
    _updateIntentInProgress = true;
    try {
      Future<PaymentSessionConfiguration>? pendingConfiguration;
      PaymentSessionConfiguration? resolvedConfiguration;

      Future<Map<String, dynamic>> resolveIntent() async {
        pendingConfiguration ??= Future<PaymentSessionConfiguration>.sync(
          intentResolver,
        );
        final configuration = await pendingConfiguration!;
        if (configuration.sdkAuthorization.trim().isEmpty) {
          throw HyperswitchException(
            code: 'invalid_sdk_authorization',
            message: 'sdkAuthorization must not be empty',
          );
        }
        resolvedConfiguration = configuration;
        return configuration.toJson();
      }

      final response =
          await FlutterHyperswitchPlatform.instance.updateElementsIntent(
            resolveIntent,
          ) ??
          {};
      final type = response['type'] as String? ?? 'failed';
      final configuration = resolvedConfiguration;
      if (configuration != null) {
        final previousAuthorization = _sdkAuthorization;
        _sdkAuthorization = configuration.sdkAuthorization.trim();
        _session = Session(_sdkAuthorization);
        _onSessionUpdated(previousAuthorization, _session);
      }
      if (type != 'success') {
        throw HyperswitchException(
          code: type,
          message: response['message'] as String? ?? 'Update Intent Failed',
        );
      }
      return _session;
    } catch (error) {
      if (error is HyperswitchException) rethrow;
      throw HyperswitchException(
        code: 'error',
        message: 'Update Intent Failed: $error',
      );
    } finally {
      _updateIntentInProgress = false;
    }
  }

  Future<PaymentResult> confirmPayment(String widgetId) async {
    try {
      final response =
          await FlutterHyperswitchPlatform.instance.confirmPayment(widgetId) ??
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

  Future<void> resolvePaymentConfirmButtonClick(
    String widgetId,
    bool proceed,
  ) async {
    try {
      await FlutterHyperswitchPlatform.instance
          .resolvePaymentConfirmButtonClick(widgetId, proceed);
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "resolvePaymentConfirmButtonClick Failed: $error",
        ),
      );
    }
  }

  Future<void> destroyElement(String widgetId) async {
    try {
      await FlutterHyperswitchPlatform.instance.destroyElement(widgetId);
      _paymentElementControllers.remove(widgetId);
      _cvcWidgetControllers.remove(widgetId);
    } catch (error) {
      return Future.error(
        HyperswitchException(
          code: "error",
          message: "destroyElement Failed: $error",
        ),
      );
    }
  }

  Future<PaymentResult> confirmWithCustomerDefaultPaymentMethod({
    String? widgetId,
  }) async {
    try {
      final response = await FlutterHyperswitchPlatform.instance
          .confirmWithCustomerDefaultPaymentMethod(widgetId) ??
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

  Future<PaymentResult> confirmWithLastUsedPaymentMethod({
    String? widgetId,
  }) async {
    try {
      final response = await FlutterHyperswitchPlatform.instance
          .confirmWithLastUsedPaymentMethod(widgetId) ??
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

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    _paymentElementControllers.clear();
    _cvcWidgetControllers.clear();
  }
}
