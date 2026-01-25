import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_hyperswitch_method_channel.dart';

/// An abstract class representing the platform interface for Flutter Hyperswitch.
abstract class FlutterHyperswitchPlatform extends PlatformInterface {
  /// Constructs a FlutterHyperswitchPlatform.
  FlutterHyperswitchPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterHyperswitchPlatform _instance =
      MethodChannelFlutterHyperswitch();

  /// The default instance of [FlutterHyperswitchPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterHyperswitch].
  static FlutterHyperswitchPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterHyperswitchPlatform] when
  /// they register themselves.
  static set instance(FlutterHyperswitchPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the payment sheet with the provided [params].
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  init(Map<String, dynamic> params) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Initializes the payment sheet with the provided [params].
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  Future<Map<String, dynamic>?> initPaymentSession(
    Map<String, dynamic> params,
  ) {
    throw UnimplementedError('initPaymentSheet() has not been implemented.');
  }

  /// Presents the payment sheet.
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  Future<Map<String, dynamic>?> presentPaymentSheet() {
    throw UnimplementedError('presentPaymentSheet() has not been implemented.');
  }

  /// Presents the payment sheet.
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  Future<Map<String, dynamic>?> getCustomerSavedPaymentMethods() {
    throw UnimplementedError(
      'getCustomerSavedPaymentMethods() has not been implemented.',
    );
  }

  /// Presents the payment sheet.
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  Future<Map<String, dynamic>?> getCustomerSavedPaymentMethodData() {
    throw UnimplementedError(
      'getCustomerSavedPaymentMethods() has not been implemented.',
    );
  }

  /// Presents the payment sheet.
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  Future<Map<String, dynamic>?> confirmWithCustomerDefaultPaymentMethod() {
    throw UnimplementedError(
      'confirmWithCustomerDefaultPaymentMethod() has not been implemented.',
    );
  }

  /// Get Customer Last Used Payment Methods.
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  Future<Map<String, dynamic>?> getCustomerLastUsedPaymentMethodData() {
    throw UnimplementedError(
      'getCustomerLastUsedPaymentMethods() has not been implemented.',
    );
  }

  /// Confirm with Customer Last Used Payment Methods.
  ///
  /// Throws an [UnimplementedError] if the method is not implemented.
  Future<Map<String, dynamic>?> confirmWithLastUsedPaymentMethod() {
    throw UnimplementedError(
      'confirmWithLastUsedPaymentMethod() has not been implemented.',
    );
  }
}
