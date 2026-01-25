import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Card, Theme;
import 'package:flutter/material.dart' as material;
import 'package:flutter_hyperswitch/flutter_hyperswitch.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _endpoint = Platform.isAndroid
      ? "http://10.0.2.2:5252"
      : "http://localhost:5252";
  final _hyper = FlutterHyperswitch();

  Session? _sessionId;
  SavedSession? _savedSessionId;

  String _statusText = '';
  String _defaultPaymentMethodText = '';
  String _confirmStatusText = '';

  bool _isInitialized = false;
  bool _showChangeButton = false;
  int _confirmState = 0;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    final response = await http.get(
      Uri.parse("$_endpoint/create-payment-intent"),
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      _hyper.init(HyperConfig(publishableKey: responseBody['publishableKey']));
      try {
        _sessionId = await _hyper.initPaymentSession(
          PaymentMethodParams(
            clientSecret: responseBody['clientSecret'],
            configuration: Configuration(
              displayDefaultSavedPaymentIcon: false,
              paymentSheetHeaderLabel: "Payment methods",
              savedPaymentSheetHeaderLabel: "Select payment method",
              primaryButtonLabel: "Purchase (\$2.00)",
              appearance: Appearance(
                layout: Layout.spacedAccordion,
                googlePay: GPayParams(
                  buttonType: GPayButtonType.donate,
                  buttonStyle: GPayButtonStyle(
                    light: GPayButtonStyleType.light,
                    dark: GPayButtonStyleType.light,
                  ),
                ),
                applePay: ApplePayParams(
                  buttonType: ApplePayButtonType.donate,
                  buttonStyle: ApplePayButtonStyle(
                    light: ApplePayButtonStyleType.whiteOutline,
                    dark: ApplePayButtonStyleType.whiteOutline,
                  ),
                ),
                font: Font(family: "Montserrat"),
                colors: DynamicColors(
                  dark: ColorsObject(primary: "#8DBD00", background: "#F5F8F9"),
                  light: ColorsObject(
                    primary: "#8DBD00",
                    background: "#F5F8F9",
                  ),
                ),
                primaryButton: PrimaryButton(
                  shapes: Shapes(borderRadius: 32.0),
                ),
              ),
            ),
          ),
        );
      } catch (ex) {
        setState(() {
          _statusText = (ex as HyperswitchException).message;
        });
      }
      setState(() {
        _isInitialized = _sessionId != null;
        _statusText = _isInitialized
            ? _statusText
            : "initPaymentSession failed";
      });
    } else {
      setState(() {
        _statusText = "API Call Failed";
      });
    }
  }

  Future<void> _initializeHeadless() async {
    if (_sessionId == null) {
      setState(() {
        _defaultPaymentMethodText = "SessionId is empty";
        _statusText = "";
      });
      return;
    }
    try {
      _savedSessionId = await _hyper.getCustomerSavedPaymentMethods(
        _sessionId!,
      );
      final paymentMethod = await _hyper.getCustomerLastUsedPaymentMethodData(
        _savedSessionId!,
      );
      if (paymentMethod is PaymentMethod) {
        if (paymentMethod.paymentMethod == PaymentMethodType.card) {
          final card = paymentMethod.card!;
          _setDefaultPaymentMethodText(
            "${card.nickName}  ${card.last4Digits}  ${card.expiryMonth}/${card.expiryYear}",
            true,
          );
          _showChangeButton = true;
        } else if (paymentMethod.paymentMethod == PaymentMethodType.wallet) {
          _showChangeButton = true;
          _setDefaultPaymentMethodText(paymentMethod.paymentMethodType, true);
        }
      } else if (paymentMethod is PaymentMethodError) {
        _setDefaultPaymentMethodText(paymentMethod.message, false);
      } else {
        _setDefaultPaymentMethodText(
          "getCustomerDefaultSavedPaymentMethodData failed",
          false,
        );
      }
    } catch (error) {
      _handleError(error, 1);
    }
  }

  Future<void> _confirmPayment() async {
    // setState(() {
    //   _confirmState = 1;
    // });
    try {
      if (_savedSessionId != null) {
        final confirmWithCustomerDefaultPaymentMethodResponse = await _hyper
            .confirmWithLastUsedPaymentMethod(_savedSessionId!);
        final message = confirmWithCustomerDefaultPaymentMethodResponse.message;
        if (message != null) {
          _setConfirmStatusText(
            "${confirmWithCustomerDefaultPaymentMethodResponse.status.name}\n${message.name}",
          );
        } else {
          _setConfirmStatusText(
            "${confirmWithCustomerDefaultPaymentMethodResponse.status.name}\n${confirmWithCustomerDefaultPaymentMethodResponse.error.message}",
          );
        }
      } else {
        _setConfirmStatusText("SavedSession is empty");
      }
    } catch (error) {
      _handleError(error, 2);
    } finally {
      setState(() {
        _showChangeButton = false;
        _defaultPaymentMethodText = '';
        _confirmState = 0;
        _initPlatformState();
      });
    }
  }

  Future<void> _presentPaymentSheet(bool isHeadless) async {
    setState(() {
      _isInitialized = false;
    });
    if (_sessionId == null) {
      _setStatusText("SessionId is empty");
      return;
    }
    try {
      final presentPaymentSheetResponse = await _hyper.presentPaymentSheet(
        _sessionId!,
      );
      if (isHeadless) {
        _setConfirmStatusText(
          _buildMessage(
            presentPaymentSheetResponse.status.name,
            presentPaymentSheetResponse.message,
            presentPaymentSheetResponse.error.message,
          ),
        );
      } else {
        _setStatusText(
          _buildMessage(
            presentPaymentSheetResponse.status.name,
            presentPaymentSheetResponse.message,
            presentPaymentSheetResponse.error.message,
          ),
        );
      }
      if (presentPaymentSheetResponse.status != Status.cancelled) {
        setState(() {
          _showChangeButton = false;
          _defaultPaymentMethodText = '';
          _confirmState = 0;
          _initPlatformState();
        });
      }
      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      _handleError(error, 0);
    }
  }

  String _buildMessage(String status, Result? message, String error) {
    if (message != null) {
      return "$status\n${message.name}";
    } else {
      return "$status\n$error";
    }
  }

  void _handleError(dynamic error, int flow) {
    final errorMessage = error is HyperswitchException
        ? error.message
        : error.toString();
    if (flow == 0) {
      _setStatusText(errorMessage);
    } else if (flow == 1) {
      _setDefaultPaymentMethodText(errorMessage, false);
    } else if (flow == 2) {
      _setConfirmStatusText(errorMessage);
    }
  }

  void _setStatusText(String text) {
    setState(() {
      _statusText = text;
    });
  }

  void _setDefaultPaymentMethodText(String text, bool show) {
    setState(() {
      _defaultPaymentMethodText = text;
      _confirmStatusText = '';
      if (show) {
        _confirmState = 2;
      }
    });
  }

  void _setConfirmStatusText(String text) {
    setState(() {
      _confirmStatusText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'montserrat'),
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [_buildHeadlessSdkExample(), _buildPaymentSheetExample()],
        ),
      ),
    );
  }

  Widget _buildHeadlessSdkExample() {
    return Expanded(
      child: material.Card(
        elevation: 4,
        margin: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "Headless SDK Example",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _isInitialized ? _initializeHeadless : null,
                  child: Text(
                    _isInitialized ? "Initialize Headless" : "Loading ...",
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Text(_defaultPaymentMethodText)),
                  if (_showChangeButton)
                    TextButton(
                      onPressed: () {
                        _presentPaymentSheet(true);
                      },
                      child: const Text("Change"),
                    ),
                ],
              ),
              if (_confirmState > 0)
                Center(
                  child: ElevatedButton(
                    onPressed: _confirmState == 2 ? _confirmPayment : null,
                    child: Text(
                      _confirmState == 1 ? "Processing ..." : "Confirm Payment",
                    ),
                  ),
                ),
              if (_confirmStatusText.isNotEmpty)
                Center(child: Text(_confirmStatusText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSheetExample() {
    return Expanded(
      child: material.Card(
        elevation: 4,
        margin: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "Payment Sheet Example",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _isInitialized
                      ? () {
                          _presentPaymentSheet(false);
                        }
                      : null,
                  child: Text(
                    _isInitialized ? "Open Payment Sheet" : "Loading ...",
                  ),
                ),
              ),
              Center(child: Text(_statusText)),
            ],
          ),
        ),
      ),
    );
  }
}
