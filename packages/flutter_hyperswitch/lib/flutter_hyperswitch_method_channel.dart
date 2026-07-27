import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_hyperswitch_platform_interface.dart';

/// An implementation of [FlutterHyperswitchPlatform] that uses method channels.
class MethodChannelFlutterHyperswitch extends FlutterHyperswitchPlatform {
  MethodChannelFlutterHyperswitch() {
    methodChannel.setMethodCallHandler(_handleNativeMethodCall);
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_hyperswitch');
  PlatformIntentResolver? _elementsIntentResolver;

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    if (call.method != 'resolveElementsIntent') {
      throw MissingPluginException('Unknown native method ${call.method}');
    }
    final resolver = _elementsIntentResolver;
    if (resolver == null) {
      throw PlatformException(
        code: 'missing_intent_resolver',
        message: 'No Elements intent update is in progress',
      );
    }
    return resolver();
  }

  @override
  init(Map<String, dynamic> params) {
    methodChannel.invokeMethod<Map<dynamic, dynamic>>('init', {
      "params": params,
    });
  }

  @override
  Future<Map<String, dynamic>?> initPaymentSession(
    Map<String, dynamic> params,
  ) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'initPaymentSession',
      {"params": params},
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> presentPaymentSheet(
    Map<String, dynamic> params,
  ) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'presentPaymentSheet',
      {"params": params},
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getCustomerSavedPaymentMethods() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getCustomerSavedPaymentMethods',
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getCustomerSavedPaymentMethodData() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getCustomerSavedPaymentMethodData',
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?>
  confirmWithCustomerDefaultPaymentMethod([
    String? widgetId,
  ]) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'confirmWithCustomerDefaultPaymentMethod',
      widgetId != null ? {"widgetId": widgetId} : null,
    );
    if (result != null) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getCustomerLastUsedPaymentMethodData() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getCustomerLastUsedPaymentMethodData',
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> confirmWithLastUsedPaymentMethod([
    String? widgetId,
  ]) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'confirmWithCustomerLastUsedPaymentMethod',
      widgetId != null ? {"widgetId": widgetId} : null,
    );
    if (result != null) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> confirmWithCustomerPaymentToken(
    String paymentToken,
  ) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'confirmWithCustomerPaymentToken',
      {"paymentToken": paymentToken},
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> updateIntent(String sdkAuthorization) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'updateIntent',
      {"sdkAuthorization": sdkAuthorization},
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> updateElementsIntent(
    PlatformIntentResolver intentResolver,
  ) async {
    if (_elementsIntentResolver != null) {
      throw PlatformException(
        code: 'already_in_progress',
        message: 'An Elements intent update is already in progress',
      );
    }
    _elementsIntentResolver = intentResolver;
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'updateElementsIntent',
      );
      return result == null ? null : Map<String, dynamic>.from(result);
    } finally {
      _elementsIntentResolver = null;
    }
  }

  @override
  Future<Map<String, dynamic>?> elements(Map<String, dynamic> params) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'elements',
      {"params": params},
    );
    if (result != null) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> createElement(
    Map<String, dynamic> params,
  ) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'createElement',
      {"params": params},
    );
    if (result != null) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> confirmPayment(String widgetId) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'confirmPayment',
      {"widgetId": widgetId},
    );
    if (result != null) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  @override
  Future<void> resolvePaymentConfirmButtonClick(
    String widgetId,
    bool proceed,
  ) async {
    await methodChannel.invokeMethod('resolvePaymentConfirmButtonClick', {
      "widgetId": widgetId,
      "proceed": proceed,
    });
  }

  @override
  Future<void> destroyElement(String widgetId) async {
    await methodChannel.invokeMethod('destroyElement', {
      "widgetId": widgetId,
    });
  }
}
