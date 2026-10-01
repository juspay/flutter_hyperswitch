/// Event names the deprecated callbacks (`onPaymentEvent`, `onCvcEvent`, and the sheet callback
/// of a configuration still on `subscribedEvents`) were built against, before the camelCase
/// rename. `onChange` always receives the camelCase names.
library;

import '../types.dart';

const Map<String, String> _legacyEventNames = {
  'cardDetailsChange': 'PAYMENT_METHOD_INFO_CARD',
  'paymentMethodChange': 'PAYMENT_METHOD_STATUS',
  'formStatusChange': 'FORM_STATUS',
  'billingDetailsChange': 'PAYMENT_METHOD_INFO_BILLING_ADDRESS',
  'cvcStatusChange': 'CVC_STATUS',
};

String legacyEventName(String eventName) =>
    _legacyEventNames[eventName] ?? eventName;

/// True when only the deprecated `subscribedEvents` is set: such a configuration predates the
/// rename, so the sheet callback keeps receiving the legacy event names.
bool usesLegacySubscription(Configuration? configuration) =>
    configuration != null &&
    // ignore: deprecated_member_use_from_same_package
    configuration.subscribedEvents != null &&
    configuration.subscriptionEvents == null;
