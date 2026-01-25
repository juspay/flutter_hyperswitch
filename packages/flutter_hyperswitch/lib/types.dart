import 'dart:ffi';

/// A class representing parameters for the Hyperswitch configuration.
class HyperConfig {
  String publishableKey;
  String? customBackendUrl;
  String? customLogUrl;

  HyperConfig({
    required this.publishableKey,
    this.customBackendUrl,
    this.customLogUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'publishableKey': publishableKey,
      'customBackendUrl': customBackendUrl,
      'customLogUrl': customLogUrl,
    };
  }
}

/// A class representing parameters for payment method initialization.
class PaymentMethodParams {
  String clientSecret;
  Configuration? configuration;
  Map<String, dynamic>? customParams;
  HyperParams? hyperParams;

  PaymentMethodParams({
    required this.clientSecret,
    this.configuration,
    this.customParams,
    this.hyperParams,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientSecret': clientSecret,
      'configuration': configuration?.toJson(),
      'customParams': customParams,
      'hyperParams': hyperParams?.toJson(),
    };
  }
}

/// A class representing configuration parameters for the payment sheet.
class Configuration {
  Appearance? appearance;
  bool? allowsDelayedPaymentMethods;
  bool? allowsPaymentMethodsRequiringShippingAddress;
  String? merchantDisplayName;
  String? primaryButtonLabel;
  Customer? customer;
  BillingDetails? defaultBillingDetails;
  ShippingDetails? shippingDetails;
  Placeholder? placeholder;
  bool? displaySavedPaymentMethodsCheckbox;
  bool? displaySavedPaymentMethods;
  String? paymentSheetHeaderLabel;
  String? savedPaymentSheetHeaderLabel;
  bool? displayDefaultSavedPaymentIcon;
  String? netceteraSDKApiKey;

  Configuration({
    this.appearance,
    this.allowsDelayedPaymentMethods,
    this.allowsPaymentMethodsRequiringShippingAddress,
    this.merchantDisplayName,
    this.primaryButtonLabel,
    this.customer,
    this.defaultBillingDetails,
    this.shippingDetails,
    this.placeholder,
    this.displaySavedPaymentMethodsCheckbox,
    this.displaySavedPaymentMethods,
    this.paymentSheetHeaderLabel,
    this.savedPaymentSheetHeaderLabel,
    this.displayDefaultSavedPaymentIcon,
    this.netceteraSDKApiKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'appearance': appearance?.toJson(),
      'allowsDelayedPaymentMethods': allowsDelayedPaymentMethods,
      'allowsPaymentMethodsRequiringShippingAddress':
          allowsPaymentMethodsRequiringShippingAddress,
      'merchantDisplayName': merchantDisplayName,
      'primaryButtonLabel': primaryButtonLabel,
      'customer': customer?.toJson(),
      'defaultBillingDetails': defaultBillingDetails?.toJson(),
      'shippingDetails': shippingDetails?.toJson(),
      'placeholder': placeholder?.toJson(),
      'displaySavedPaymentMethodsCheckbox': displaySavedPaymentMethodsCheckbox,
      'displaySavedPaymentMethods': displaySavedPaymentMethods,
      'paymentSheetHeaderLabel': paymentSheetHeaderLabel,
      'savedPaymentSheetHeaderLabel': savedPaymentSheetHeaderLabel,
      'displayDefaultSavedPaymentIcon': displayDefaultSavedPaymentIcon,
      'netceteraSDKApiKey': netceteraSDKApiKey,
    };
  }
}

/// A class representing placeholder configurations.
class Placeholder {
  String? cardNumber;
  String? expiryDate;
  String? cvv;

  Placeholder({this.cardNumber, this.expiryDate, this.cvv});

  factory Placeholder.fromJson(Map<String, dynamic> json) {
    return Placeholder(
      cardNumber: json['cardNumber'],
      expiryDate: json['expiryDate'],
      cvv: json['cvv'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'cardNumber': cardNumber, 'expiryDate': expiryDate, 'cvv': cvv};
  }
}

/// A class representing billing details.
class BillingDetails {
  String? email;
  String? name;
  String? phone;
  Address? address;

  BillingDetails({this.email, this.name, this.phone, this.address});

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: Address.fromJson(json['address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address?.toJson(),
    };
  }
}

/// A class representing shipping details.
class ShippingDetails {
  String? email;
  String? name;
  String? phone;
  Address? address;

  ShippingDetails({this.email, this.name, this.phone, this.address});

  factory ShippingDetails.fromJson(Map<String, dynamic> json) {
    return ShippingDetails(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: Address.fromJson(json['address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address?.toJson(),
    };
  }
}

/// A class representing an address.
class Address {
  late String? postalCode;
  late String? country;
  late String? state;
  late String? line1;
  late String? line2;
  late String? city;

  Address({
    this.postalCode,
    this.country,
    this.state,
    this.line1,
    this.line2,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      postalCode: json['postalCode'],
      country: json['country'],
      state: json['state'],
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postalCode': postalCode,
      'country': country,
      'state': state,
      'line1': line1,
      'line2': line2,
      'city': city,
    };
  }
}

/// Enum representing different themes.
enum Theme { auto, light, dark, minimal, flatMinimal }

/// Function to convert Theme enum to corresponding string values.
String themeToString(Theme? theme) {
  switch (theme) {
    case Theme.light:
      return "Light";
    case Theme.dark:
      return "Dark";
    case Theme.minimal:
      return "Minimal";
    case Theme.flatMinimal:
      return "FlatMinimal";
    default:
      return "default";
  }
}

/// Function to convert string values to corresponding Theme enum .
Theme stringToTheme(String theme) {
  switch (theme) {
    case "light":
      return Theme.light;
    case "dark":
      return Theme.dark;
    case "minimal":
      return Theme.minimal;
    case "flatMinimal":
      return Theme.flatMinimal;
    default:
      return Theme.auto;
  }
}

/// Enum representing different layouts.
enum Layout { tabs, accordion, spacedAccordion }

/// Function to convert Layout enum to corresponding string values.
String layoutToString(Layout? theme) {
  switch (theme) {
    case Layout.accordion:
      return "accordion";
    case Layout.spacedAccordion:
      return "spacedAccordion";
    default:
      return "tabs";
  }
}

/// Function to convert string values to corresponding Layout enum .
Layout stringToLayout(String theme) {
  switch (theme) {
    case "accordion":
      return Layout.accordion;
    case "spacedAccordion":
      return Layout.spacedAccordion;
    default:
      return Layout.tabs;
  }
}

/// A class representing appearance configurations.
class Appearance {
  late Map<String, dynamic> themeData;

  Appearance({
    DynamicColors? colors,
    Shapes? shapes,
    PrimaryButton? primaryButton,
    String? locale,
    Font? font,
    GPayParams? googlePay,
    ApplePayParams? applePay,
    Theme? theme,
    Layout? layout,
  }) {
    themeData = {
      'colors': colors?.toJson(),
      'shapes': shapes?.toJson(),
      'primaryButton': primaryButton?.toJson(),
      'locale': locale,
      'typography': font?.toJson(),
      'applePay': applePay?.toJson(),
      'googlePay': googlePay?.toJson(),
      'theme': themeToString(theme),
      'layout': layoutToString(layout),
    };
  }

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      colors: DynamicColors.fromJson(json['colors']),
      shapes: Shapes.fromJson(json['shapes']),
      primaryButton: PrimaryButton.fromJson(json['primaryButton']),
      locale: json['locale'],
      font: Font.fromJson(json['font']),
      applePay: ApplePayParams.fromJson(json['applePay']),
      googlePay: GPayParams.fromJson(json['googlePay']),
      theme: stringToTheme(json['theme']),
      layout: stringToLayout(json['layout']),
    );
  }

  Map<String, dynamic> toJson() {
    return themeData;
  }
}

class Font {
  String? family;
  Float? scale;

  Font({this.family, this.scale});

  factory Font.fromJson(Map<String, dynamic> json) {
    return Font(family: json['family'], scale: json['scale']);
  }

  Map<String, dynamic> toJson() {
    return {'fontResId': family, 'fontSizeSp': scale};
  }
}

/// A class representing primary button configurations.
class PrimaryButton {
  Shapes? shapes;
  DynamicColors? colors;

  PrimaryButton({this.shapes, this.colors});

  factory PrimaryButton.fromJson(Map<String, dynamic> json) {
    return PrimaryButton(
      shapes: Shapes.fromJson(json['shapes']),
      colors: DynamicColors.fromJson(json['colors']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'shapes': shapes?.toJson(), 'colors': colors?.toJson()};
  }
}

/// A class representing shapes configurations.
class Shapes {
  double? borderRadius;
  double? borderWidth;
  Shadow? shadow;

  Shapes({this.borderRadius, this.borderWidth, this.shadow});

  factory Shapes.fromJson(Map<String, dynamic> json) {
    return Shapes(
      borderRadius: json['borderRadius'],
      borderWidth: json['borderWidth'],
      shadow: Shadow.fromJson(json['shadow']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borderRadius': borderRadius,
      'borderWidth': borderWidth,
      'shadow': shadow?.toJson(),
    };
  }
}

/// A class representing offset configurations.
class Offset {
  double? x;
  double? y;

  Offset({this.x, this.y});

  factory Offset.fromJson(Map<String, dynamic> json) {
    return Offset(x: json['x'], y: json['y']);
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }
}

/// A class representing shadow configurations.
class Shadow {
  String? color;
  double? opacity;
  double? blurRadius;
  Offset? offset;
  double? intensity;

  Shadow({
    this.color,
    this.opacity,
    this.blurRadius,
    this.offset,
    this.intensity,
  });

  factory Shadow.fromJson(Map<String, dynamic> json) {
    return Shadow(
      color: json['color'],
      opacity: json['opacity'],
      blurRadius: json['blurRadius'],
      offset: json['offset'],
      intensity: json['intensity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'opacity': opacity,
      'blurRadius': blurRadius,
      'offset': offset?.toJson(),
      'intensity': intensity,
    };
  }
}

/// A class representing dynamic colors configurations.
class DynamicColors {
  ColorsObject? light;
  ColorsObject? dark;

  DynamicColors({this.light, this.dark});

  factory DynamicColors.fromJson(Map<String, dynamic> json) {
    return DynamicColors(
      light: ColorsObject.fromJson(json['light']),
      dark: ColorsObject.fromJson(json['dark']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'light': light?.toJson(), 'dark': dark?.toJson()};
  }
}

/// A class representing color object.
class ColorsObject {
  String? primary;
  String? background;
  String? componentBackground;
  String? componentBorder;
  String? componentDivider;
  String? componentText;
  String? primaryText;
  String? secondaryText;
  String? placeholderText;
  String? icon;
  String? error;
  String? loaderBackground;
  String? loaderForeground;

  ColorsObject({
    this.primary,
    this.background,
    this.componentBackground,
    this.componentBorder,
    this.componentDivider,
    this.componentText,
    this.primaryText,
    this.secondaryText,
    this.placeholderText,
    this.icon,
    this.error,
    this.loaderBackground,
    this.loaderForeground,
  });

  factory ColorsObject.fromJson(Map<String, dynamic> json) {
    return ColorsObject(
      primary: json['primary'],
      background: json['background'],
      componentBackground: json['componentBackground'],
      componentBorder: json['componentBorder'],
      componentDivider: json['componentDivider'],
      componentText: json['componentText'],
      primaryText: json['primaryText'],
      secondaryText: json['secondaryText'],
      placeholderText: json['placeholderText'],
      icon: json['icon'],
      error: json['error'],
      loaderBackground: json['loaderBackground'],
      loaderForeground: json['loaderForeground'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'background': background,
      'componentBackground': componentBackground,
      'componentBorder': componentBorder,
      'componentDivider': componentDivider,
      'componentText': componentText,
      'primaryText': primaryText,
      'secondaryText': secondaryText,
      'placeholderText': placeholderText,
      'icon': icon,
      'error': error,
      'text': primaryText,
      'loaderBackground': loaderBackground,
      'loaderForeground': loaderForeground,
    };
  }
}

/// A class representing customer configurations.
class Customer {
  final String? ephemeralKeySecret;
  final String? id;

  Customer({this.ephemeralKeySecret, this.id});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      ephemeralKeySecret: json['ephemeralKey'],
      id: json['customerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'ephemeralKeySecret': ephemeralKeySecret, 'id': id};
  }
}

/// A class representing hyper parameters.
class HyperParams {
  bool? disableBranding;
  bool? defaultView;

  HyperParams({this.disableBranding, this.defaultView});

  factory HyperParams.fromJson(Map<String, dynamic> json) {
    return HyperParams(
      disableBranding: json['disableBranding'] ?? false,
      defaultView: json['defaultView'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'disableBranding': disableBranding, 'defaultView': defaultView};
  }
}

/// Enum representing different types of Google Pay buttons.
enum GPayButtonType {
  buy,
  book,
  checkout,
  donate,
  order,
  pay,
  subscribe,
  plain,
}

/// Enum representing the style type for Google Pay buttons.
enum GPayButtonStyleType { light, dark }

/// A class representing the style of Google Pay buttons.
class GPayButtonStyle {
  GPayButtonStyleType light;
  GPayButtonStyleType dark;

  GPayButtonStyle({required this.light, required this.dark});

  /// Factory method to create a [GPayButtonStyle] from a JSON map.
  factory GPayButtonStyle.fromJson(Map<String, dynamic> json) {
    return GPayButtonStyle(
      light: GPayButtonStyleType.values.firstWhere(
        (e) => e.name == json['light'],
      ),
      dark: GPayButtonStyleType.values.firstWhere(
        (e) => e.name == json['dark'],
      ),
    );
  }

  /// Converts this [GPayButtonStyle] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'light': light.name, 'dark': dark.name};
  }
}

/// A class representing Google Pay configurations.
class GPayParams {
  GPayButtonType? buttonType;
  GPayButtonStyle? buttonStyle;

  GPayParams({this.buttonType, this.buttonStyle});

  /// Factory method to create a [GPayParams] from a JSON map.
  factory GPayParams.fromJson(Map<String, dynamic> json) {
    return GPayParams(
      buttonType: json['buttonType'] != null
          ? GPayButtonType.values.firstWhere(
              (e) => e.name.toUpperCase() == json['buttonType'],
            )
          : null,
      buttonStyle: json['buttonStyle'] != null
          ? GPayButtonStyle.fromJson(json['buttonStyle'])
          : null,
    );
  }

  /// Converts this [GPayParams] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'buttonType': buttonType?.name.toUpperCase(),
      'buttonStyle': buttonStyle?.toJson(),
    };
  }
}

/// Enum representing different types of Apple Pay buttons.
enum ApplePayButtonType {
  buy,
  setUp,
  inStore,
  donate,
  checkout,
  book,
  subscribe,
  plain,
}

/// Enum representing the style type for Apple Pay buttons.
enum ApplePayButtonStyleType { white, whiteOutline, black }

/// A class representing the style of Apple Pay buttons.
class ApplePayButtonStyle {
  ApplePayButtonStyleType light;
  ApplePayButtonStyleType dark;

  ApplePayButtonStyle({required this.light, required this.dark});

  /// Factory method to create an [ApplePayButtonStyle] from a JSON map.
  factory ApplePayButtonStyle.fromJson(Map<String, dynamic> json) {
    return ApplePayButtonStyle(
      light: ApplePayButtonStyleType.values.firstWhere(
        (e) => e.name == json['light'],
      ),
      dark: ApplePayButtonStyleType.values.firstWhere(
        (e) => e.name == json['dark'],
      ),
    );
  }

  /// Converts this [ApplePayButtonStyle] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'light': light.name, 'dark': dark.name};
  }
}

/// A class representing Apple Pay configurations.
class ApplePayParams {
  ApplePayButtonType? buttonType;
  ApplePayButtonStyle? buttonStyle;

  ApplePayParams({this.buttonType, this.buttonStyle});

  /// Factory method to create an [ApplePayParams] from a JSON map.
  factory ApplePayParams.fromJson(Map<String, dynamic> json) {
    return ApplePayParams(
      buttonType: json['buttonType'] != null
          ? ApplePayButtonType.values.firstWhere(
              (e) => e.name == json['buttonType'],
            )
          : null,
      buttonStyle: json['buttonStyle'] != null
          ? ApplePayButtonStyle.fromJson(json['buttonStyle'])
          : null,
    );
  }

  /// Converts this [ApplePayParams] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'buttonType': buttonType?.name,
      'buttonStyle': buttonStyle?.toJson(),
    };
  }
}

/// Represents a payment method or an error.
abstract class SessionPaymentMethodOrError {}

/// Represents a payment method or an error.
abstract class PaymentMethodResponse {}

/// Represents a Session
class Session extends SessionPaymentMethodOrError {
  final String sessionData;
  Session(this.sessionData);
}

/// Represents a SavedSession
class SavedSession extends SessionPaymentMethodOrError {
  final String sessionData;
  SavedSession(this.sessionData);
}

/// Enum representing different payment method types.
enum PaymentMethodType {
  card,
  wallet,
  payLater,
  bankRedirect,
  bankTransfer,
  bankDebit,
  crypto,
  reward,
  upi,
  voucher,
  giftCard,
  cardRedirect,
  realTimePayment,
  unknown;

  String toStringValue() {
    switch (this) {
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.wallet:
        return 'wallet';
      case PaymentMethodType.payLater:
        return 'pay_later';
      case PaymentMethodType.bankRedirect:
        return 'bank_redirect';
      case PaymentMethodType.bankTransfer:
        return 'bank_transfer';
      case PaymentMethodType.bankDebit:
        return 'bank_debit';
      case PaymentMethodType.crypto:
        return 'crypto';
      case PaymentMethodType.reward:
        return 'reward';
      case PaymentMethodType.upi:
        return 'upi';
      case PaymentMethodType.voucher:
        return 'voucher';
      case PaymentMethodType.giftCard:
        return 'gift_card';
      case PaymentMethodType.cardRedirect:
        return 'card_redirect';
      case PaymentMethodType.realTimePayment:
        return 'real_time_payment';
      default:
        return 'unknown';
    }
  }

  static PaymentMethodType fromString(String value) {
    switch (value) {
      case 'card':
        return PaymentMethodType.card;
      case 'wallet':
        return PaymentMethodType.wallet;
      case 'pay_later':
        return PaymentMethodType.payLater;
      case 'bank_redirect':
        return PaymentMethodType.bankRedirect;
      case 'bank_transfer':
        return PaymentMethodType.bankTransfer;
      case 'bank_debit':
        return PaymentMethodType.bankDebit;
      case 'crypto':
        return PaymentMethodType.crypto;
      case 'reward':
        return PaymentMethodType.reward;
      case 'upi':
        return PaymentMethodType.upi;
      case 'voucher':
        return PaymentMethodType.voucher;
      case 'gift_card':
        return PaymentMethodType.giftCard;
      case 'card_redirect':
        return PaymentMethodType.cardRedirect;
      case 'real_time_payment':
        return PaymentMethodType.realTimePayment;
      default:
        return PaymentMethodType.unknown;
    }
  }
}

/// Represents a card payment method.
class Card {
  final String? last4Digits;
  final String? cardNumber;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardHolderName;
  final String? nickName;
  final String? cardBrand;

  Card({
    this.last4Digits,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cardHolderName,
    this.nickName,
    this.cardBrand,
  });

  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      last4Digits: map['last4_digits'] as String?,
      cardNumber: map['card_number'] as String?,
      expiryMonth: map['expiry_month'] as String?,
      expiryYear: map['expiry_year'] as String?,
      cardHolderName: map['card_holder_name'] as String?,
      nickName: map['nick_name'] as String?,
      cardBrand: map['card_brand'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'last4_digits': last4Digits,
      'card_number': cardNumber,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'card_holder_name': cardHolderName,
      'nick_name': nickName,
      'card_brand': cardBrand,
    };
  }
}

/// Represents a saved payment method.
class PaymentMethod extends PaymentMethodResponse {
  final String paymentToken;
  final String paymentMethodId;
  final String customerId;
  final PaymentMethodType paymentMethod;
  final String paymentMethodType;
  final String paymentMethodIssuer;
  final String? paymentMethodIssuerCode;
  final bool recurringEnabled;
  final bool installmentPaymentEnabled;
  final List<String> paymentExperience;
  final Card? card;
  final String? metadata;
  final String created;
  final String? bank;
  final String? surchargeDetails;
  final bool requiresCvv;
  final String lastUsedAt;
  final bool defaultPaymentMethodSet;

  PaymentMethod({
    required this.paymentToken,
    required this.paymentMethodId,
    required this.customerId,
    required this.paymentMethod,
    required this.paymentMethodType,
    required this.paymentMethodIssuer,
    this.paymentMethodIssuerCode,
    required this.recurringEnabled,
    required this.installmentPaymentEnabled,
    required this.paymentExperience,
    this.card,
    this.metadata,
    required this.created,
    this.bank,
    this.surchargeDetails,
    required this.requiresCvv,
    required this.lastUsedAt,
    required this.defaultPaymentMethodSet,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      paymentToken: map['payment_token'] as String,
      paymentMethodId: map['payment_method_id'] as String,
      customerId: map['customer_id'] as String,
      paymentMethod: PaymentMethodType.fromString(
        map['payment_method_str'] as String? ?? map['payment_method'] as String,
      ),
      paymentMethodType: map['payment_method_type'] as String,
      paymentMethodIssuer: map['payment_method_issuer'] as String,
      paymentMethodIssuerCode: map['payment_method_issuer_code'] as String?,
      recurringEnabled: map['recurring_enabled'] as bool,
      installmentPaymentEnabled: map['installment_payment_enabled'] as bool,
      paymentExperience: List<String>.from(map['payment_experience'] as List),
      card: map['card'] != null
          ? Card.fromMap(Map<String, dynamic>.from(map['card'] as Map))
          : null,
      metadata: map['metadata'] as String?,
      created: map['created'] as String,
      bank: map['bank'] as String?,
      surchargeDetails: map['surcharge_details'] as String?,
      requiresCvv: map['requires_cvv'] as bool,
      lastUsedAt: map['last_used_at'] as String,
      defaultPaymentMethodSet: map['default_payment_method_set'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'payment_token': paymentToken,
      'payment_method_id': paymentMethodId,
      'customer_id': customerId,
      'payment_method': paymentMethod.toStringValue(),
      'payment_method_type': paymentMethodType,
      'payment_method_issuer': paymentMethodIssuer,
      'payment_method_issuer_code': paymentMethodIssuerCode,
      'recurring_enabled': recurringEnabled,
      'installment_payment_enabled': installmentPaymentEnabled,
      'payment_experience': paymentExperience,
      'card': card?.toMap(),
      'metadata': metadata,
      'created': created,
      'bank': bank,
      'surcharge_details': surchargeDetails,
      'requires_cvv': requiresCvv,
      'last_used_at': lastUsedAt,
      'default_payment_method_set': defaultPaymentMethodSet,
    };
  }
}

/// Represents an HyperswitchException.
class HyperswitchException extends PaymentMethodResponse {
  final String code;
  final String message;

  HyperswitchException({required this.code, required this.message});

  /// Constructs an Error object from a map.
  factory HyperswitchException.fromMap(Map<String, dynamic> map) {
    return HyperswitchException(
      code: map['code'] ?? '',
      message: map['message'] ?? '',
    );
  }
}

/// Represents an error.
class PaymentMethodError extends PaymentMethodResponse {
  final String code;
  final String message;

  PaymentMethodError({required this.code, required this.message});

  /// Constructs an Error object from a map.
  factory PaymentMethodError.fromMap(Map<String, dynamic> map) {
    return PaymentMethodError(
      code: map['code'] ?? '',
      message: map['message'] ?? '',
    );
  }
}

/// Enum representing the status of a payment.
enum Status {
  /// Payment completed successfully.
  completed,

  /// Payment failed.
  failed,

  /// Payment was cancelled.
  cancelled,
}

/// Enum representing different possible results of a payment.
enum Result {
  /// Payment succeeded.
  succeeded,

  /// Payment failed.
  failed,

  /// Payment was cancelled.
  cancelled,

  /// Payment is in processing state.
  processing,

  /// Payment requires action from the customer.
  requiresCustomerAction,

  /// Payment requires action from the merchant.
  requiresMerchantAction,

  /// Payment requires a payment method.
  requiresPaymentMethod,

  /// Payment requires confirmation.
  requiresConfirmation,

  /// Payment requires capture.
  requiresCapture,

  /// Payment was partially captured.
  partiallyCaptured,

  /// Payment was partially captured and can still be captured.
  partiallyCapturedAndCapturable,

  /// Payment resulted in an error.
  error,
}

/// Represents the result of a payment operation.
class PaymentResult {
  /// Status of the payment.
  final Status status;

  /// Message indicating the result of the payment.
  final Result? message;

  /// Message indicating the result of the payment.
  final HyperswitchException error;

  /// Constructs a PaymentResult object with the given status and message.
  PaymentResult({required this.status, this.message, required this.error});

  /// Constructs a PaymentResult object from a map representation.
  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      status: _getStatusFromString(map['type'] ?? ''),
      message: _getMessageFromString(map['message'] ?? ''),
      error: _getErrorFromString(map['type'] ?? '', map['message'] ?? ''),
    );
  }

  /// Converts a status string to a Status enum value.
  static Status _getStatusFromString(String statusString) {
    switch (statusString) {
      case 'completed':
        return Status.completed;
      case 'cancelled':
        return Status.cancelled;
      default:
        return Status.failed;
    }
  }

  /// Converts a message string to a Result value.
  static Result? _getMessageFromString(String messageString) {
    switch (messageString) {
      case 'succeeded':
        return Result.succeeded;
      case 'failed':
        return Result.failed;
      case 'cancelled':
        return Result.cancelled;
      case 'processing':
        return Result.processing;
      case 'requires_customer_action':
        return Result.requiresCustomerAction;
      case 'requires_merchant_action':
        return Result.requiresMerchantAction;
      case 'requires_payment_method':
        return Result.requiresPaymentMethod;
      case 'requires_confirmation':
        return Result.requiresConfirmation;
      case 'requires_capture':
        return Result.requiresCapture;
      case 'partially_captured':
        return Result.partiallyCaptured;
      case 'partially_captured_and_capturable':
        return Result.partiallyCapturedAndCapturable;
      default:
        return null;
    }
  }

  /// Converts a message string to an error.
  static HyperswitchException _getErrorFromString(
    String statusString,
    String messageString,
  ) {
    return HyperswitchException(code: statusString, message: messageString);
  }
}
