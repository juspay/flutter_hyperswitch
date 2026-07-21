
/// A class representing parameters for the Hyperswitch configuration.
class HyperConfig {
  String publishableKey;
  String? profileId;
  HyperswitchEnvironment? environment;
  CustomEndpointConfiguration? customConfig;
  String? customBackendUrl;
  String? customLogUrl;

  HyperConfig({
    required this.publishableKey,
    this.profileId,
    this.environment,
    this.customConfig,
    this.customBackendUrl,
    this.customLogUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'publishableKey': publishableKey,
      'profileId': profileId,
      'environment': environmentToString(environment),
      'customEndpoints': customConfig?.toJson(),
      'customBackendUrl': customBackendUrl,
      'customLogUrl': customLogUrl,
    };
  }
}

/// Enum representing Hyperswitch environments.
enum HyperswitchEnvironment { production, sandbox, integ }

String environmentToString(HyperswitchEnvironment? environment) {
  switch (environment) {
    case HyperswitchEnvironment.sandbox:
      return "SANDBOX";
    case HyperswitchEnvironment.integ:
      return "INTEG";
    case HyperswitchEnvironment.production:
    case null:
      return "PROD";
  }
}

/// A class representing custom endpoint overrides for Hyperswitch.
class OverrideEndpoints {
  String? customBackendEndpoint;
  String? customLoggingEndpoint;
  String? customAssetEndpoint;
  String? customSDKConfigEndpoint;
  String? customConfirmEndpoint;
  String? customAirborneEndpoint;

  OverrideEndpoints({
    this.customBackendEndpoint,
    this.customLoggingEndpoint,
    this.customAssetEndpoint,
    this.customSDKConfigEndpoint,
    this.customConfirmEndpoint,
    this.customAirborneEndpoint,
  });

  Map<String, dynamic> toJson() {
    return {
      'customBackendEndpoint': customBackendEndpoint,
      'customLoggingEndpoint': customLoggingEndpoint,
      'customAssetEndpoint': customAssetEndpoint,
      'customSDKConfigEndpoint': customSDKConfigEndpoint,
      'customConfirmEndpoint': customConfirmEndpoint,
      'customAirborneEndpoint': customAirborneEndpoint,
    };
  }
}

/// A class representing custom endpoint configuration for Hyperswitch.
class CustomEndpointConfiguration {
  OverrideEndpoints? overrideEndpoints;
  String? commonEndpoint;

  CustomEndpointConfiguration({this.overrideEndpoints, this.commonEndpoint});

  Map<String, dynamic> toJson() {
    return {
      'overrideEndpoints': overrideEndpoints?.toJson(),
      'commonEndpoint': commonEndpoint,
    };
  }
}

/// A class representing payment session initialization options.
class PaymentSessionConfiguration {
  String sdkAuthorization;

  /// Deprecated: pass this to `presentPaymentSheet(session, configuration)`
  /// instead. Kept so existing Flutter merchants do not break.
  Configuration? configuration;
  Map<String, dynamic>? customParams;

  PaymentSessionConfiguration({
    required this.sdkAuthorization,
    this.configuration,
    this.customParams,
  });

  Map<String, dynamic> toJson() {
    return {
      'sdkAuthorization': sdkAuthorization,
      // The iOS plugin (and older Android plugin versions) read `clientSecret`;
      // emit both keys so existing integrations keep working.
      'clientSecret': sdkAuthorization,
      'configuration': configuration?.toJson(),
      'customParams': customParams,
    };
  }
}

/// Backward-compatible alias for older Flutter SDK integrations.
///
/// Prefer [PaymentSessionConfiguration] with `sdkAuthorization` for new code.
class PaymentMethodParams extends PaymentSessionConfiguration {
  PaymentMethodParams({
    required String clientSecret,
    super.configuration,
    super.customParams,
  }) : super(sdkAuthorization: clientSecret);

  String get clientSecret => sdkAuthorization;

  @override
  Map<String, dynamic> toJson() {
    return {
      'sdkAuthorization': sdkAuthorization,
      'clientSecret': sdkAuthorization,
      'configuration': configuration?.toJson(),
      'customParams': customParams,
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
  bool? disableBranding;
  bool? defaultView;
  bool? displayPayButton;
  bool? stickyPayButton;
  bool? preloadCardElement;
  String? locale;
  List<SubscriptionEvent>? subscribedEvents;
  RedirectionInfo? redirectionInfo;
  bool? alwaysSendCustomerAcceptance;
  bool? opensCardScannerAutomatically;
  List<String>? paymentMethodOrder;
  bool? splitCardFields;
  WalletButtonsConfiguration? walletButtonsConfiguration;
  List<PaymentMethodConfig>? paymentMethodsConfig;
  PaymentMethodLayout? paymentMethodLayout;
  String? paymentSheetHeaderText;
  String? savedPaymentScreenHeaderText;
  String? primaryButtonColor;
  bool? enablePartialLoading;
  bool? hideConfirmButton;

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
    this.disableBranding,
    this.defaultView,
    this.displayPayButton,
    this.stickyPayButton,
    this.preloadCardElement,
    this.locale,
    this.subscribedEvents,
    this.redirectionInfo,
    this.alwaysSendCustomerAcceptance,
    this.opensCardScannerAutomatically,
    this.paymentMethodOrder,
    this.splitCardFields,
    this.walletButtonsConfiguration,
    this.paymentMethodsConfig,
    this.paymentMethodLayout,
    this.paymentSheetHeaderText,
    this.savedPaymentScreenHeaderText,
    this.primaryButtonColor,
    this.enablePartialLoading,
    this.hideConfirmButton,
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
      'billingDetails': defaultBillingDetails?.toJson(),
      'shippingDetails': shippingDetails?.toJson(),
      'placeholder': placeholder?.toJson(),
      'displaySavedPaymentMethodsCheckbox': displaySavedPaymentMethodsCheckbox,
      'displaySavedPaymentMethods': displaySavedPaymentMethods,
      'paymentSheetHeaderLabel': paymentSheetHeaderLabel,
      'savedPaymentSheetHeaderLabel': savedPaymentSheetHeaderLabel,
      'displayDefaultSavedPaymentIcon': displayDefaultSavedPaymentIcon,
      'netceteraSDKApiKey': netceteraSDKApiKey,
      'disableBranding': disableBranding,
      'defaultView': defaultView,
      'displayPayButton': displayPayButton,
      'stickyPayButton': stickyPayButton,
      'preloadCardElement': preloadCardElement,
      'locale': locale,
      'subscribedEvents': subscribedEvents?.map((e) => e.name).toList(),
      'redirectionInfo': redirectionInfo?.name,
      'alwaysSendCustomerAcceptance': alwaysSendCustomerAcceptance,
      'opensCardScannerAutomatically': opensCardScannerAutomatically,
      'paymentMethodOrder': paymentMethodOrder,
      'splitCardFields': splitCardFields,
      'walletButtonsConfiguration': walletButtonsConfiguration?.toJson(),
      'paymentMethodsConfig': paymentMethodsConfig
          ?.map((e) => e.toJson())
          .toList(),
      'paymentMethodLayout': paymentMethodLayout?.toJson(),
      'paymentSheetHeaderText': paymentSheetHeaderText,
      'savedPaymentScreenHeaderText': savedPaymentScreenHeaderText,
      'primaryButtonColor': primaryButtonColor,
      'enablePartialLoading': enablePartialLoading,
      'hideConfirmButton': hideConfirmButton,
    };
  }
}

/// Enum representing visibility options for wallet buttons.
enum WalletVisibility { shown, hidden }

/// Enum representing visibility of redirection info text.
enum RedirectionInfo { shown, hidden }

/// Enum representing PayPal button types.
enum PayPalButtonType { paypal, checkout, buynow, pay }

/// Enum representing PayPal button sizes.
enum PayPalButtonSize { small, medium, large }

/// Enum representing PayPal button style colors.
enum PayPalButtonStyleType { gold, blue, white, black, silver }

/// A class representing PayPal button style.
class PayPalButtonStyle {
  PayPalButtonStyleType light;
  PayPalButtonStyleType dark;

  PayPalButtonStyle({required this.light, required this.dark});

  Map<String, dynamic> toJson() {
    return {'light': light.name, 'dark': dark.name};
  }
}

/// A class representing Google Pay wallet button configuration.
class GooglePayConfiguration {
  WalletVisibility? visibility;
  GPayButtonType? buttonType;
  GPayButtonStyle? buttonStyle;

  GooglePayConfiguration({
    this.visibility,
    this.buttonType,
    this.buttonStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'visibility': visibility?.name,
      'buttonType': buttonType?.name.toUpperCase(),
      'buttonStyle': buttonStyle?.toJson(),
    };
  }
}

/// A class representing Apple Pay wallet button configuration.
class ApplePayConfiguration {
  WalletVisibility? visibility;
  ApplePayButtonType? buttonType;
  ApplePayButtonStyle? buttonStyle;

  ApplePayConfiguration({
    this.visibility,
    this.buttonType,
    this.buttonStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'visibility': visibility?.name,
      'buttonType': buttonType?.name,
      'buttonStyle': buttonStyle?.toJson(),
    };
  }
}

/// A class representing PayPal wallet button configuration.
class PayPalConfiguration {
  WalletVisibility? visibility;
  PayPalButtonType? buttonType;
  PayPalButtonSize? buttonSize;
  PayPalButtonStyle? buttonStyle;

  PayPalConfiguration({
    this.visibility,
    this.buttonType,
    this.buttonSize,
    this.buttonStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'visibility': visibility?.name,
      'buttonType': buttonType?.name,
      'buttonSize': buttonSize?.name,
      'buttonStyle': buttonStyle?.toJson(),
    };
  }
}

/// A class representing wallet buttons configuration.
class WalletButtonsConfiguration {
  GooglePayConfiguration? googlePay;
  ApplePayConfiguration? applePay;
  PayPalConfiguration? payPal;

  WalletButtonsConfiguration({
    this.googlePay,
    this.applePay,
    this.payPal,
  });

  Map<String, dynamic> toJson() {
    return {
      'googlePay': googlePay?.toJson(),
      'applePay': applePay?.toJson(),
      'payPal': payPal?.toJson(),
    };
  }
}

/// A class representing a payment method configuration item.
class PaymentMethodConfig {
  final String paymentMethod;
  final String? message;

  PaymentMethodConfig({
    required this.paymentMethod,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod,
      if (message != null) 'message': message,
    };
  }
}

/// Enum representing CVC icon display options.
enum CvcIconDisplay { hidden, shown }

/// Enum representing card brand icon display options.
enum CardBrandIconDisplay { hidden, standard, hideGeneric, animated }

/// Enum representing payment method arrangement for tabs.
enum PaymentMethodsArrangement { defaultArrangement, grid }

/// A class representing grouping behavior for saved payment methods.
class GroupingBehavior {
  final bool? displayInSeparateScreen;
  final bool? displayInSeparateSection;
  final bool? groupByPaymentMethods;

  GroupingBehavior({
    this.displayInSeparateScreen,
    this.displayInSeparateSection,
    this.groupByPaymentMethods,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayInSeparateScreen': displayInSeparateScreen,
      'displayInSeparateSection': displayInSeparateSection,
      'groupByPaymentMethods': groupByPaymentMethods,
    };
  }
}

/// A class representing saved payment method customization options.
class SavedMethodCustomization {
  final bool? defaultCollapsed;
  final bool? hideCardExpiry;
  final bool? hideCVCError;
  final CvcIconDisplay? cvcIcon;
  final GroupingBehavior? groupingBehavior;
  final List<String>? hiddenPaymentMethods;

  SavedMethodCustomization({
    this.defaultCollapsed,
    this.hideCardExpiry,
    this.hideCVCError,
    this.cvcIcon,
    this.groupingBehavior,
    this.hiddenPaymentMethods,
  });

  Map<String, dynamic> toJson() {
    return {
      'defaultCollapsed': defaultCollapsed,
      'hideCardExpiry': hideCardExpiry,
      'hideCVCError': hideCVCError,
      'cvcIcon': cvcIcon?.name,
      'groupingBehavior': groupingBehavior?.toJson(),
      'hiddenPaymentMethods': hiddenPaymentMethods,
    };
  }
}

/// A class representing payment method layout configuration.
class PaymentMethodLayout {
  final Layout? type;
  final bool? showOneClickWalletsOnTop;
  final PaymentMethodsArrangement? paymentMethodsArrangementForTabs;
  final bool? defaultCollapsed;
  final bool? radios;
  final bool? spacedAccordionItems;
  final int? maxAccordionItems;
  final CvcIconDisplay? cvcIcon;
  final CardBrandIconDisplay? cardBrandIcon;
  final bool? showCheckedIconForSelection;
  final SavedMethodCustomization? savedMethodCustomization;

  PaymentMethodLayout({
    this.type,
    this.showOneClickWalletsOnTop,
    this.paymentMethodsArrangementForTabs,
    this.defaultCollapsed,
    this.radios,
    this.spacedAccordionItems,
    this.maxAccordionItems,
    this.cvcIcon,
    this.cardBrandIcon,
    this.showCheckedIconForSelection,
    this.savedMethodCustomization,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': layoutToString(type),
      'showOneClickWalletsOnTop': showOneClickWalletsOnTop,
      'paymentMethodsArrangementForTabs':
          paymentMethodsArrangementForTabs?.name == 'defaultArrangement'
              ? 'default'
              : paymentMethodsArrangementForTabs?.name,
      'defaultCollapsed': defaultCollapsed,
      'radios': radios,
      'spacedAccordionItems': spacedAccordionItems,
      'maxAccordionItems': maxAccordionItems,
      'cvcIcon': cvcIcon?.name,
      'cardBrandIcon': cardBrandIcon?.name,
      'showCheckedIconForSelection': showCheckedIconForSelection,
      'savedMethodCustomization': savedMethodCustomization?.toJson(),
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
class Phone {
  String? number;
  String? code;

  Phone({this.number, this.code});

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      number: json['number'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'code': code};
  }
}

class BillingDetails {
  String? email;
  String? name;
  Phone? phone;
  Address? address;

  BillingDetails({this.email, this.name, this.phone, this.address});

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      email: json['email'],
      name: json['name'],
      phone: json['phone'] != null ? Phone.fromJson(json['phone']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone?.toJson(),
      'address': address?.toJson(),
    };
  }
}

/// A class representing shipping details.
class ShippingDetails {
  String? email;
  String? name;
  Phone? phone;
  Address? address;

  ShippingDetails({this.email, this.name, this.phone, this.address});

  factory ShippingDetails.fromJson(Map<String, dynamic> json) {
    return ShippingDetails(
      email: json['email'],
      name: json['name'],
      phone: json['phone'] != null ? Phone.fromJson(json['phone']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone?.toJson(),
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
  late String? firstName;
  late String? lastName;

  Address({
    this.postalCode,
    this.country,
    this.state,
    this.line1,
    this.line2,
    this.city,
    this.firstName,
    this.lastName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      postalCode: json['postalCode'],
      country: json['country'],
      state: json['state'],
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      firstName: json['first_name'],
      lastName: json['last_name'],
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
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}

/// Enum representing different themes.
enum Theme { auto, light, dark, minimal, flatMinimal, brutal, glass, skeu, clay, charcoal, soft }

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
    case Theme.brutal:
      return "Brutal";
    case Theme.glass:
      return "Glass";
    case Theme.skeu:
      return "Skeu";
    case Theme.clay:
      return "Clay";
    case Theme.charcoal:
      return "Charcoal";
    case Theme.soft:
      return "Soft";
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
    case "brutal":
      return Theme.brutal;
    case "glass":
      return Theme.glass;
    case "skeu":
      return Theme.skeu;
    case "clay":
      return Theme.clay;
    case "charcoal":
      return Theme.charcoal;
    case "soft":
      return Theme.soft;
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

/// A class representing logo colors.
class LogoColors {
  final String? backgroundColor;
  final String? selected;
  final String? unselected;

  LogoColors({this.backgroundColor, this.selected, this.unselected});

  factory LogoColors.fromJson(Map<String, dynamic> json) {
    return LogoColors(
      backgroundColor: json['backgroundColor'],
      selected: json['selected'],
      unselected: json['unselected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor,
      'selected': selected,
      'unselected': unselected,
    };
  }
}

/// A class representing logo color type (light/dark).
class LogoColorType {
  final LogoColors? light;
  final LogoColors? dark;

  LogoColorType({this.light, this.dark});

  factory LogoColorType.fromJson(Map<String, dynamic> json) {
    return LogoColorType(
      light: json['light'] != null ? LogoColors.fromJson(json['light']) : null,
      dark: json['dark'] != null ? LogoColors.fromJson(json['dark']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'light': light?.toJson(), 'dark': dark?.toJson()};
  }
}

/// A class representing checked icon colors.
class CheckedIconColors {
  final String? color;
  final String? stroke;

  CheckedIconColors({this.color, this.stroke});

  factory CheckedIconColors.fromJson(Map<String, dynamic> json) {
    return CheckedIconColors(
      color: json['color'],
      stroke: json['stroke'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'color': color, 'stroke': stroke};
  }
}

/// A class representing checked icon color type (light/dark).
class CheckedIconColorType {
  final CheckedIconColors? light;
  final CheckedIconColors? dark;

  CheckedIconColorType({this.light, this.dark});

  factory CheckedIconColorType.fromJson(Map<String, dynamic> json) {
    return CheckedIconColorType(
      light: json['light'] != null ? CheckedIconColors.fromJson(json['light']) : null,
      dark: json['dark'] != null ? CheckedIconColors.fromJson(json['dark']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'light': light?.toJson(), 'dark': dark?.toJson()};
  }
}

/// A class representing checked icon for selection.
class CheckedIconForSelection {
  final CheckedIconColorType? colors;
  final double? size;
  final double? bottom;
  final double? right;

  CheckedIconForSelection({this.colors, this.size, this.bottom, this.right});

  factory CheckedIconForSelection.fromJson(Map<String, dynamic> json) {
    return CheckedIconForSelection(
      colors: json['colors'] != null ? CheckedIconColorType.fromJson(json['colors']) : null,
      size: json['size'],
      bottom: json['bottom'],
      right: json['right'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colors': colors?.toJson(),
      'size': size,
      'bottom': bottom,
      'right': right,
    };
  }
}

/// A class representing logo customization.
class LogoCustomization {
  final double? borderRadius;
  final LogoColorType? colors;
  final CheckedIconForSelection? checkedIconForSelection;

  LogoCustomization({
    this.borderRadius,
    this.colors,
    this.checkedIconForSelection,
  });

  factory LogoCustomization.fromJson(Map<String, dynamic> json) {
    return LogoCustomization(
      borderRadius: json['borderRadius'],
      colors: json['colors'] != null ? LogoColorType.fromJson(json['colors']) : null,
      checkedIconForSelection: json['checkedIconForSelection'] != null
          ? CheckedIconForSelection.fromJson(json['checkedIconForSelection'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borderRadius': borderRadius,
      'colors': colors?.toJson(),
      'checkedIconForSelection': checkedIconForSelection?.toJson(),
    };
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
    Theme? theme,
    LogoCustomization? logo,
  }) {
    themeData = {
      'colors': colors?.toJson(),
      'shapes': shapes?.toJson(),
      'primaryButton': primaryButton?.toJson(),
      'locale': locale,
      // The SDK bundle reads `font` (family/scale/...); `typography` with
      // fontResId/fontSizeSp is the legacy key still read by the iOS plugin.
      'font': font?.toJson(),
      'typography': font != null
          ? {'fontResId': font.family, 'fontSizeSp': font.scale}
          : null,
      'theme': themeToString(theme),
      'logo': logo?.toJson(),
    };
  }

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      colors: json['colors'] != null ? DynamicColors.fromJson(json['colors']) : null,
      shapes: json['shapes'] != null ? Shapes.fromJson(json['shapes']) : null,
      primaryButton: json['primaryButton'] != null ? PrimaryButton.fromJson(json['primaryButton']) : null,
      locale: json['locale'],
      font: json['typography'] != null ? Font.fromJson(json['typography']) : (json['font'] != null ? Font.fromJson(json['font']) : null),
      theme: stringToTheme(json['theme']),
      logo: json['logo'] != null ? LogoCustomization.fromJson(json['logo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return themeData;
  }
}

class Font {
  String? family;
  double? scale;
  double? headingTextSizeAdjust;
  double? subHeadingTextSizeAdjust;
  double? placeholderTextSizeAdjust;
  double? buttonTextSizeAdjust;
  double? errorTextSizeAdjust;
  double? linkTextSizeAdjust;
  double? modalTextSizeAdjust;
  double? cardTextSizeAdjust;

  Font({
    this.family,
    this.scale,
    this.headingTextSizeAdjust,
    this.subHeadingTextSizeAdjust,
    this.placeholderTextSizeAdjust,
    this.buttonTextSizeAdjust,
    this.errorTextSizeAdjust,
    this.linkTextSizeAdjust,
    this.modalTextSizeAdjust,
    this.cardTextSizeAdjust,
  });

  factory Font.fromJson(Map<String, dynamic> json) {
    return Font(
      family: json['family'] ?? json['fontResId'],
      scale: json['scale'] ?? json['fontSizeSp'],
      headingTextSizeAdjust: json['headingTextSizeAdjust'],
      subHeadingTextSizeAdjust: json['subHeadingTextSizeAdjust'],
      placeholderTextSizeAdjust: json['placeholderTextSizeAdjust'],
      buttonTextSizeAdjust: json['buttonTextSizeAdjust'],
      errorTextSizeAdjust: json['errorTextSizeAdjust'],
      linkTextSizeAdjust: json['linkTextSizeAdjust'],
      modalTextSizeAdjust: json['modalTextSizeAdjust'],
      cardTextSizeAdjust: json['cardTextSizeAdjust'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family': family,
      'scale': scale,
      'headingTextSizeAdjust': headingTextSizeAdjust,
      'subHeadingTextSizeAdjust': subHeadingTextSizeAdjust,
      'placeholderTextSizeAdjust': placeholderTextSizeAdjust,
      'buttonTextSizeAdjust': buttonTextSizeAdjust,
      'errorTextSizeAdjust': errorTextSizeAdjust,
      'linkTextSizeAdjust': linkTextSizeAdjust,
      'modalTextSizeAdjust': modalTextSizeAdjust,
      'cardTextSizeAdjust': cardTextSizeAdjust,
    };
  }
}

/// A class representing primary button color type.
class PrimaryButtonColorType {
  final String? background;
  final String? text;
  final String? border;

  PrimaryButtonColorType({this.background, this.text, this.border});

  Map<String, dynamic> toJson() {
    return {
      'background': background,
      'text': text,
      'border': border,
    };
  }
}

/// A class representing primary button colors.
class PrimaryButtonColors {
  final PrimaryButtonColorType? light;
  final PrimaryButtonColorType? dark;

  PrimaryButtonColors({this.light, this.dark});

  Map<String, dynamic> toJson() {
    return {'light': light?.toJson(), 'dark': dark?.toJson()};
  }
}

/// A class representing primary button configurations.
class PrimaryButton {
  Shapes? shapes;
  PrimaryButtonColors? colors;
  double? height;

  PrimaryButton({this.shapes, this.colors, this.height});

  factory PrimaryButton.fromJson(Map<String, dynamic> json) {
    return PrimaryButton(
      shapes: json['shapes'] != null ? Shapes.fromJson(json['shapes']) : null,
      colors: json['colors'] != null
          ? PrimaryButtonColors(
              light: json['colors']['light'] != null
                  ? PrimaryButtonColorType(
                      background: json['colors']['light']['background'],
                      text: json['colors']['light']['text'],
                      border: json['colors']['light']['border'],
                    )
                  : null,
              dark: json['colors']['dark'] != null
                  ? PrimaryButtonColorType(
                      background: json['colors']['dark']['background'],
                      text: json['colors']['dark']['text'],
                      border: json['colors']['dark']['border'],
                    )
                  : null,
            )
          : null,
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shapes': shapes?.toJson(),
      'colors': colors?.toJson(),
      'height': height,
    };
  }
}

/// A class representing shapes configurations.
class Shapes {
  double? borderRadius;
  double? borderWidth;
  Shadow? shadow;
  double? inputHeight;
  double? gap;

  Shapes({
    this.borderRadius,
    this.borderWidth,
    this.shadow,
    this.inputHeight,
    this.gap,
  });

  factory Shapes.fromJson(Map<String, dynamic> json) {
    return Shapes(
      borderRadius: json['borderRadius'],
      borderWidth: json['borderWidth'],
      shadow: json['shadow'] != null ? Shadow.fromJson(json['shadow']) : null,
      inputHeight: json['inputHeight'],
      gap: json['gap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borderRadius': borderRadius,
      'borderWidth': borderWidth,
      'shadow': shadow?.toJson(),
      'inputHeight': inputHeight,
      'gap': gap,
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
      offset: json['offset'] != null ? Offset.fromJson(json['offset']) : null,
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
      light: json['light'] != null ? ColorsObject.fromJson(json['light']) : null,
      dark: json['dark'] != null ? ColorsObject.fromJson(json['dark']) : null,
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
  String? overlay;
  String? selectedComponentBackground;
  String? selectedComponentBorder;
  double? selectedComponentBorderWidth;
  String? selectedComponentDivider;
  String? selectedComponentText;

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
    this.overlay,
    this.selectedComponentBackground,
    this.selectedComponentBorder,
    this.selectedComponentBorderWidth,
    this.selectedComponentDivider,
    this.selectedComponentText,
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
      overlay: json['overlay'],
      selectedComponentBackground: json['selectedComponentBackground'],
      selectedComponentBorder: json['selectedComponentBorder'],
      selectedComponentBorderWidth: json['selectedComponentBorderWidth'],
      selectedComponentDivider: json['selectedComponentDivider'],
      selectedComponentText: json['selectedComponentText'],
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
      'loaderBackground': loaderBackground,
      'loaderForeground': loaderForeground,
      'overlay': overlay,
      'selectedComponentBackground': selectedComponentBackground,
      'selectedComponentBorder': selectedComponentBorder,
      'selectedComponentBorderWidth': selectedComponentBorderWidth,
      'selectedComponentDivider': selectedComponentDivider,
      'selectedComponentText': selectedComponentText,
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
      ephemeralKeySecret: json['ephemeralKeySecret'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'ephemeralKeySecret': ephemeralKeySecret, 'id': id};
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
        orElse: () => GPayButtonStyleType.light,
      ),
      dark: GPayButtonStyleType.values.firstWhere(
        (e) => e.name == json['dark'],
        orElse: () => GPayButtonStyleType.dark,
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
        orElse: () => ApplePayButtonStyleType.white,
      ),
      dark: ApplePayButtonStyleType.values.firstWhere(
        (e) => e.name == json['dark'],
        orElse: () => ApplePayButtonStyleType.black,
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

/// Enum representing subscription events for the payment sheet.
enum SubscriptionEvent {
  paymentMethodInfoCard,
  paymentMethodStatus,
  formStatus,
  paymentMethodInfoBillingAddress,

  /// Emitted by [CvcWidget] unconditionally; listing it in
  /// [Configuration.subscribedEvents] is not required.
  cvcStatus;

  String get name {
    switch (this) {
      case SubscriptionEvent.paymentMethodInfoCard:
        return 'PAYMENT_METHOD_INFO_CARD';
      case SubscriptionEvent.paymentMethodStatus:
        return 'PAYMENT_METHOD_STATUS';
      case SubscriptionEvent.formStatus:
        return 'FORM_STATUS';
      case SubscriptionEvent.paymentMethodInfoBillingAddress:
        return 'PAYMENT_METHOD_INFO_BILLING_ADDRESS';
      case SubscriptionEvent.cvcStatus:
        return 'CVC_STATUS';
    }
  }
}

/// Represents a payment event received from the payment sheet.
class PaymentEvent {
  final String eventName;
  final Map<String, dynamic>? payload;

  PaymentEvent({required this.eventName, this.payload});

  factory PaymentEvent.fromMap(Map<dynamic, dynamic> map) {
    return PaymentEvent(
      eventName: map['eventName'] as String? ?? '',
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'] as Map)
          : null,
    );
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
      paymentToken: map['payment_token'] as String? ?? '',
      paymentMethodId: map['payment_method_id'] as String? ?? '',
      customerId: map['customer_id'] as String? ?? '',
      paymentMethod: PaymentMethodType.fromString(
        map['payment_method_str'] as String? ??
            map['payment_method'] as String? ??
            'unknown',
      ),
      paymentMethodType: map['payment_method_type'] as String? ?? '',
      paymentMethodIssuer: map['payment_method_issuer'] as String? ?? '',
      paymentMethodIssuerCode: map['payment_method_issuer_code'] as String?,
      recurringEnabled: map['recurring_enabled'] as bool? ?? false,
      installmentPaymentEnabled:
          map['installment_payment_enabled'] as bool? ?? false,
      paymentExperience: List<String>.from(
        map['payment_experience'] as List? ?? const [],
      ),
      card: map['card'] != null
          ? Card.fromMap(Map<String, dynamic>.from(map['card'] as Map))
          : null,
      metadata: map['metadata'] as String?,
      created: map['created'] as String? ?? '',
      bank: map['bank'] as String?,
      surchargeDetails: map['surcharge_details'] as String?,
      requiresCvv: map['requires_cvv'] as bool? ?? false,
      lastUsedAt: map['last_used_at'] as String? ?? '',
      defaultPaymentMethodSet:
          map['default_payment_method_set'] as bool? ?? false,
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
      message: _getMessageFromString(map['message']?.toString() ?? ''),
      error: _getErrorFromString(
        map['type']?.toString() ?? '',
        map['message']?.toString() ?? '',
      ),
    );
  }

  /// Converts a status string to a Status enum value.
  static Status _getStatusFromString(String statusString) {
    switch (statusString) {
      case 'completed':
        return Status.completed;
      case 'cancelled':
      case 'canceled':
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
      case 'canceled':
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

/// Represents data passed to [PaymentElementController.onPaymentConfirmButtonClick].
class PaymentRequestData {
  final String? paymentMethodType;

  PaymentRequestData({this.paymentMethodType});

  factory PaymentRequestData.fromMap(Map<dynamic, dynamic> map) {
    return PaymentRequestData(
      paymentMethodType: map['paymentMethodType'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'paymentMethodType': paymentMethodType};
  }
}

/// Event emitted by [CvcWidgetController.onCvcEvent].
class CvcWidgetEvent {
  final String type;
  final Map<String, dynamic> payload;

  CvcWidgetEvent({required this.type, required this.payload});

  factory CvcWidgetEvent.fromMap(Map<dynamic, dynamic> map) {
    return CvcWidgetEvent(
      type: map['type'] as String? ?? '',
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'] as Map)
          : {},
    );
  }
}

/// Controls a PaymentElement widget after it has been created.
class PaymentElementController {
  final String widgetId;
  final void Function(PaymentEvent)? onPaymentEvent;
  final void Function(PaymentResult)? onPaymentResult;
  final Future<bool> Function(PaymentRequestData)? onPaymentConfirmButtonClick;

  PaymentElementController({
    required this.widgetId,
    this.onPaymentEvent,
    this.onPaymentResult,
    this.onPaymentConfirmButtonClick,
  });
}

/// Controls a CvcWidget after it has been created.
class CvcWidgetController {
  final String widgetId;
  final void Function(CvcWidgetEvent)? onCvcEvent;

  CvcWidgetController({
    required this.widgetId,
    this.onCvcEvent,
  });
}
