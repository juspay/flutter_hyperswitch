import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Card, Theme, Placeholder;
import 'package:flutter_hyperswitch/flutter_hyperswitch.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'montserrat'),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Hyperswitch Demo'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Payment Sheet'),
                Tab(text: 'Headless'),
                Tab(text: 'Widgets'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              PaymentSheetTab(endpoint: _endpoint),
              HeadlessTab(endpoint: _endpoint),
              WidgetsTab(endpoint: _endpoint),
            ],
          ),
        ),
      ),
    );
  }

  static String get _endpoint => Platform.isAndroid
      ? "http://10.0.2.2:5252"
      : "http://localhost:5252";
}

Configuration _buildPaymentSheetConfiguration() {
  return Configuration(
    displayDefaultSavedPaymentIcon: false,
    paymentSheetHeaderLabel: "Payment methods",
    savedPaymentSheetHeaderLabel: "Select payment method",
    primaryButtonLabel: "Purchase (\$2.00)",
    displayPayButton: true,
    stickyPayButton: false,
    splitCardFields: true,
    locale: "en",
    subscribedEvents: [
      SubscriptionEvent.formStatus,
      SubscriptionEvent.paymentMethodStatus,
    ],
    walletButtonsConfiguration: WalletButtonsConfiguration(
      googlePay: GooglePayConfiguration(
        visibility: WalletVisibility.hidden,
        buttonType: GPayButtonType.donate,
        buttonStyle: GPayButtonStyle(
          light: GPayButtonStyleType.light,
          dark: GPayButtonStyleType.light,
        ),
      ),
      applePay: ApplePayConfiguration(
        visibility: WalletVisibility.shown,
        buttonType: ApplePayButtonType.donate,
        buttonStyle: ApplePayButtonStyle(
          light: ApplePayButtonStyleType.whiteOutline,
          dark: ApplePayButtonStyleType.whiteOutline,
        ),
      ),
    ),
    paymentMethodLayout: PaymentMethodLayout(
      type: Layout.accordion,
      showOneClickWalletsOnTop: true,
      radios: false,
      maxAccordionItems: 1,
      cvcIcon: CvcIconDisplay.hidden,
      cardBrandIcon: CardBrandIconDisplay.standard,
    ),
    appearance: Appearance(
      theme: Theme.minimal,
      font: Font(
        family: "Montserrat",
        scale: 1.0,
        headingTextSizeAdjust: 1.0,
        buttonTextSizeAdjust: 1.0,
      ),
      colors: DynamicColors(
        dark: ColorsObject(
          primary: "#8DBD00",
          background: "#F5F8F9",
          overlay: "#00000066",
          selectedComponentBackground: "#E0E0E0",
          selectedComponentBorder: "#CCCCCC",
        ),
        light: ColorsObject(
          primary: "#8DBD00",
          background: "#F5F8F9",
          overlay: "#00000033",
          selectedComponentBackground: "#F0F0F0",
          selectedComponentBorder: "#DDDDDD",
        ),
      ),
      shapes: Shapes(borderRadius: 8.0, inputHeight: 48.0, gap: 12.0),
      primaryButton: PrimaryButton(
        shapes: Shapes(borderRadius: 32.0),
        height: 48.0,
        colors: PrimaryButtonColors(
          light: PrimaryButtonColorType(
            background: "#8DBD00",
            text: "#FFFFFF",
            border: "#8DBD00",
          ),
          dark: PrimaryButtonColorType(
            background: "#8DBD00",
            text: "#FFFFFF",
            border: "#8DBD00",
          ),
        ),
      ),
      logo: LogoCustomization(
        borderRadius: 8.0,
        colors: LogoColorType(
          light: LogoColors(
            backgroundColor: "transparent",
            selected: "#8DBD00",
            unselected: "#CCCCCC",
          ),
          dark: LogoColors(
            backgroundColor: "transparent",
            selected: "#8DBD00",
            unselected: "#444444",
          ),
        ),
      ),
    ),
  );
}

String _errorMessage(Object error) {
  return error is HyperswitchException ? error.message : error.toString();
}

String _requireSdkAuthorization(Map<String, dynamic> body) {
  final sdkAuthorization = body['sdkAuthorization'];
  if (sdkAuthorization is! String || sdkAuthorization.trim().isEmpty) {
    throw const FormatException('Payment API did not return sdkAuthorization');
  }
  return sdkAuthorization;
}

Future<String> _fetchUpdatedSdkAuthorization(
  String endpoint,
  String paymentId,
) async {
  final response = await http.post(
    Uri.parse('$endpoint/update-payment'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode({'paymentId': paymentId}),
  );
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200) {
    final error = body['error'];
    final message = error is Map ? error['message'] : null;
    throw Exception(message ?? 'Payment update failed');
  }
  return _requireSdkAuthorization(body);
}

Configuration _buildPaymentElementConfiguration() {
  return Configuration(
    displayDefaultSavedPaymentIcon: false,
    splitCardFields: true,
    hideConfirmButton: true,
    subscribedEvents: [
      SubscriptionEvent.formStatus,
      SubscriptionEvent.paymentMethodStatus,
    ],
    paymentMethodLayout: PaymentMethodLayout(
      type: Layout.accordion,
      radios: false,
      maxAccordionItems: 2,
      defaultCollapsed: true,
      spacedAccordionItems: true,
      cvcIcon: CvcIconDisplay.hidden,
      cardBrandIcon: CardBrandIconDisplay.hideGeneric,
      showCheckedIconForSelection: true,
      savedMethodCustomization: SavedMethodCustomization(
        cvcIcon: CvcIconDisplay.hidden,
        hideCardExpiry: true,
        defaultCollapsed: false,
        groupingBehavior: GroupingBehavior(displayInSeparateScreen: false),
      ),
    ),
    appearance: Appearance(
      theme: Theme.light,
      shapes: Shapes(
        borderRadius: 16.0,
        borderWidth: 1.0,
        inputHeight: 56.0,
        gap: 24.0,
        shadow: Shadow(
          color: '#000000',
          opacity: 0,
          blurRadius: 0,
          intensity: 0,
          offset: Offset(x: 0, y: 0),
        ),
      ),
      primaryButton: PrimaryButton(height: 56.0),
    ),
  );
}

Configuration _buildCvcWidgetConfiguration() {
  return Configuration(
    placeholder: Placeholder(cvv: '123'),
    hideConfirmButton: true,
  );
}

// ─── Tab 1: Payment Sheet ──────────────────────────────────────────────────

class PaymentSheetTab extends StatefulWidget {
  final String endpoint;
  const PaymentSheetTab({super.key, required this.endpoint});

  @override
  State<PaymentSheetTab> createState() => _PaymentSheetTabState();
}

class _PaymentSheetTabState extends State<PaymentSheetTab> {
  final _hyper = FlutterHyperswitch();
  Session? _sessionId;
  bool _isInitialized = false;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _isInitialized = false;
      _statusText = '';
    });
    try {
      final response = await http.get(
        Uri.parse("${widget.endpoint}/create-payment-intent"),
      );
      if (response.statusCode != 200) {
        setState(() => _statusText = "API Call Failed");
        return;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _hyper.init(
        HyperConfig(
          publishableKey: body['publishableKey'],
          profileId: body['profileId'] as String?,
        ),
      );
      final sdkAuth = _requireSdkAuthorization(body);
      _sessionId = await _hyper.initPaymentSession(
        PaymentSessionConfiguration(sdkAuthorization: sdkAuth),
      );
      setState(() {
        _isInitialized = _sessionId != null;
      });
    } catch (error) {
      setState(() => _statusText = _errorMessage(error));
    }
  }

  Future<void> _presentSheet() async {
    if (_sessionId == null) return;
    setState(() => _isInitialized = false);
    try {
      final result = await _hyper.presentPaymentSheet(
        _sessionId!,
        _buildPaymentSheetConfiguration(),
        (event) {
          debugPrint("PaymentEvent: ${event.eventName} payload=${event.payload}");
        },
      );
      setState(() {
        _statusText = "${result.status.name}\n${result.message?.name ?? result.error.message}";
      });
      if (result.status != Status.cancelled) {
        _init();
      } else {
        setState(() => _isInitialized = true);
      }
    } catch (error) {
      setState(() => _statusText = _errorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Payment Sheet Example",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isInitialized ? _presentSheet : null,
              child: Text(_isInitialized ? "Open Payment Sheet" : "Loading ..."),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _init,
              child: const Text("Reload Client Secret"),
            ),
            const SizedBox(height: 16),
            Text(_statusText),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 2: Headless + CvcWidget ─────────────────────────────────────────────

class HeadlessTab extends StatefulWidget {
  final String endpoint;
  const HeadlessTab({super.key, required this.endpoint});

  @override
  State<HeadlessTab> createState() => _HeadlessTabState();
}

class _HeadlessTabState extends State<HeadlessTab> {
  final _hyper = FlutterHyperswitch();
  Elements? _elements;
  String? _sdkAuthorization;
  String? _paymentId;
  SavedSession? _savedSession;
  String _statusText = '';
  String _resultText = '';
  String _paymentMethodText = '';
  bool _isInitialized = false;
  bool _isUpdatingIntent = false;
  bool _showConfirm = false;

  final String _cvcWidgetId = 'cvc_headless_1';

  Future<void> _init() async {
    setState(() {
      _isInitialized = false;
      _statusText = '';
      _resultText = '';
      _paymentMethodText = '';
      _showConfirm = false;
    });
    try {
      final response = await http.get(
        Uri.parse("${widget.endpoint}/create-payment-intent"),
      );
      if (response.statusCode != 200) {
        setState(() => _statusText = "API Call Failed");
        return;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _hyper.init(
        HyperConfig(
          publishableKey: body['publishableKey'],
          profileId: body['profileId'] as String?,
        ),
      );
      final sdkAuth = _requireSdkAuthorization(body);
      final paymentId = body['paymentId'];
      if (paymentId is! String || paymentId.isEmpty) {
        throw const FormatException('Payment API did not return paymentId');
      }
      _sdkAuthorization = sdkAuth;
      _paymentId = paymentId;
      _elements = await _hyper.elements(
        PaymentSessionConfiguration(sdkAuthorization: sdkAuth),
      );
      _savedSession = await _hyper.getCustomerSavedPaymentMethods(
        Session(sdkAuth),
      );
      final pm = await _hyper.getCustomerLastUsedPaymentMethodData(_savedSession!);
      if (pm is PaymentMethod) {
        if (pm.paymentMethod == PaymentMethodType.card) {
          final card = pm.card!;
          setState(() {
            _paymentMethodText =
                "${card.nickName}  ${card.last4Digits}  ${card.expiryMonth}/${card.expiryYear}";
            _showConfirm = true;
          });
        } else {
          setState(() {
            _paymentMethodText = pm.paymentMethodType;
            _showConfirm = true;
          });
        }
      } else if (pm is PaymentMethodError) {
        setState(() => _statusText = pm.message);
      }
      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      setState(() => _statusText = _errorMessage(error));
    }
  }

  Future<void> _confirm() async {
    try {
      final result = await _elements!.confirmWithLastUsedPaymentMethod(
        widgetId: _cvcWidgetId,
      );
      setState(() {
        _resultText =
            "${result.status.name}\n${result.message?.name ?? result.error.message}";
      });
    } catch (error) {
      setState(() => _resultText = _errorMessage(error));
    }
  }

  Future<void> _updateIntent() async {
    final elements = _elements;
    final paymentId = _paymentId;
    if (elements == null || paymentId == null) return;
    setState(() => _isUpdatingIntent = true);
    try {
      final session = await elements.updateIntent(() async {
        final sdkAuthorization = await _fetchUpdatedSdkAuthorization(
          widget.endpoint,
          paymentId,
        );
        return PaymentSessionConfiguration(sdkAuthorization: sdkAuthorization);
      });
      _sdkAuthorization = session.sessionData;
      setState(() => _statusText = 'Intent updated');
    } catch (error) {
      setState(() => _statusText = _errorMessage(error));
    } finally {
      setState(() => _isUpdatingIntent = false);
    }
  }

  Future<void> _change() async {
    if (_sdkAuthorization == null) return;
    try {
      final result = await _hyper.presentPaymentSheet(
        Session(_sdkAuthorization!),
        _buildPaymentSheetConfiguration(),
        (event) {
          debugPrint("PaymentEvent: ${event.eventName} payload=${event.payload}");
        },
      );
      setState(() {
        _resultText =
            "${result.status.name}\n${result.message?.name ?? result.error.message}";
      });
      if (result.status != Status.cancelled) {
        _init();
      }
    } catch (error) {
      setState(() => _statusText = _errorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Headless SDK Example",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isInitialized ? null : _init,
              child: Text(_isInitialized ? "Initialized" : "Initialize"),
            ),
            const SizedBox(height: 16),
            if (_isInitialized && _elements != null) ...[
              if (_paymentMethodText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Text(_paymentMethodText)),
                      if (_showConfirm)
                        TextButton(
                          onPressed: _change,
                          child: const Text("Change"),
                        ),
                    ],
                  ),
                ),
              const Text(
                "CVC Widget",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: CvcWidget(
                  elements: _elements!,
                  widgetId: _cvcWidgetId,
                  configuration: _buildCvcWidgetConfiguration(),
                  onCvcEvent: (event) {
                    debugPrint("CVCWidget event: ${event.type} payload=${event.payload}");
                  },
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isUpdatingIntent ? null : _updateIntent,
                child: Text(
                  _isUpdatingIntent ? 'Updating Intent...' : 'Update Intent',
                ),
              ),
              const SizedBox(height: 16),
              if (_showConfirm)
                ElevatedButton(
                  onPressed: _confirm,
                  child: const Text("Confirm Payment"),
                ),
              const SizedBox(height: 16),
              if (_resultText.isNotEmpty)
                Text(_resultText, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
            if (_statusText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_statusText),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 3: Widgets (PaymentElement) ────────────────────────────────────────

class WidgetsTab extends StatefulWidget {
  final String endpoint;
  const WidgetsTab({super.key, required this.endpoint});

  @override
  State<WidgetsTab> createState() => _WidgetsTabState();
}

class _WidgetsTabState extends State<WidgetsTab> {
  final _hyper = FlutterHyperswitch();
  Elements? _elements;
  String? _paymentId;
  String _statusText = '';
  String _resultText = '';
  bool _isInitializing = false;
  bool _isUpdatingIntent = false;
  bool _elementsReady = false;

  final String _paymentElementId = 'pe_widgets_1';

  Future<void> _init() async {
    setState(() {
      _isInitializing = true;
      _statusText = '';
      _resultText = '';
      _elementsReady = false;
    });
    try {
      final response = await http.get(
        Uri.parse("${widget.endpoint}/create-payment-intent"),
      );
      if (response.statusCode != 200) {
        setState(() {
          _statusText = "API Call Failed";
          _isInitializing = false;
        });
        return;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _hyper.init(
        HyperConfig(
          publishableKey: body['publishableKey'],
          profileId: body['profileId'] as String?,
        ),
      );
      final sdkAuth = _requireSdkAuthorization(body);
      final paymentId = body['paymentId'];
      if (paymentId is! String || paymentId.isEmpty) {
        throw const FormatException('Payment API did not return paymentId');
      }
      _paymentId = paymentId;
      _elements = await _hyper.elements(
        PaymentSessionConfiguration(sdkAuthorization: sdkAuth),
      );
      setState(() {
        _elementsReady = true;
      });
    } catch (error) {
      setState(() => _statusText = _errorMessage(error));
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _confirmPayment() async {
    if (_elements == null) return;
    try {
      final result = await _elements!.confirmPayment(_paymentElementId);
      setState(() {
        _resultText =
            "${result.status.name}\n${result.message?.name ?? result.error.message}";
      });
    } catch (error) {
      setState(() => _resultText = "Confirm failed: $error");
    }
  }

  Future<void> _updateIntent() async {
    final elements = _elements;
    final paymentId = _paymentId;
    if (elements == null || paymentId == null) return;
    setState(() => _isUpdatingIntent = true);
    try {
      await elements.updateIntent(() async {
        final sdkAuthorization = await _fetchUpdatedSdkAuthorization(
          widget.endpoint,
          paymentId,
        );
        return PaymentSessionConfiguration(sdkAuthorization: sdkAuthorization);
      });
      setState(() => _statusText = 'Intent updated');
    } catch (error) {
      setState(() => _statusText = _errorMessage(error));
    } finally {
      setState(() => _isUpdatingIntent = false);
    }
  }

  Future<void> _dispose() async {
    await _elements?.destroyElement(_paymentElementId);
    await _elements?.dispose();
    _elements = null;
    if (mounted) {
      setState(() {
        _elementsReady = false;
        _statusText = '';
        _resultText = '';
      });
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isInitializing ? null : _init,
              child: Text(
                _isInitializing
                    ? "Initializing..."
                    : _elementsReady
                        ? "Re-initialize"
                        : "Initialize Elements",
              ),
            ),
            const SizedBox(height: 12),
            if (_elementsReady && _elements != null) ...[
              const Text(
                "Payment Element",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: PaymentElement(
                  elements: _elements!,
                  widgetId: _paymentElementId,
                  configuration: _buildPaymentElementConfiguration(),
                  onPaymentEvent: (event) {
                    debugPrint(
                      "PaymentElement event: ${event.eventName} payload=${event.payload}",
                    );
                  },
                  onPaymentResult: (result) {
                    setState(() {
                      _resultText =
                          "${result.status.name}\n${result.message?.name ?? result.error.message}";
                    });
                  },
                  onPaymentConfirmButtonClick: (data) async {
                    debugPrint(
                      "Payment confirm button click: ${data.paymentMethodType}",
                    );
                    return true;
                  },
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isUpdatingIntent ? null : _updateIntent,
                child: Text(
                  _isUpdatingIntent ? 'Updating Intent...' : 'Update Intent',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _confirmPayment,
                child: const Text("Confirm Payment"),
              ),
              const Divider(height: 32),
              TextButton(
                onPressed: _dispose,
                child: const Text("Dispose Elements"),
              ),
            ],
            if (_statusText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_statusText),
              ),
            if (_resultText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _resultText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
