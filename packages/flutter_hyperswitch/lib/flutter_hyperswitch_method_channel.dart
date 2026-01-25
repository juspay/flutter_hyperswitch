import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_hyperswitch_platform_interface.dart';

/// An implementation of [FlutterHyperswitchPlatform] that uses method channels.
class MethodChannelFlutterHyperswitch extends FlutterHyperswitchPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_hyperswitch');

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
  Future<Map<String, dynamic>?> presentPaymentSheet() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'presentPaymentSheet',
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
  confirmWithCustomerDefaultPaymentMethod() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'confirmWithCustomerDefaultPaymentMethod',
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
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
  Future<Map<String, dynamic>?> confirmWithLastUsedPaymentMethod() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'confirmWithCustomerLastUsedPaymentMethod',
    );
    if (result != null) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return resultMap;
    }
    return null;
  }
}
