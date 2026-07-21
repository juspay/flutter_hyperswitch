import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/gestures.dart'
    show OneSequenceGestureRecognizer, EagerGestureRecognizer;
import 'flutter_hyperswitch.dart';

// The native payment form must win the gesture arena (e.g. inside a
// scrollable), otherwise taps on its fields are swallowed by Flutter.
Set<Factory<OneSequenceGestureRecognizer>> _eagerGestureRecognizers() => {
  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
};

Widget _androidPlatformView(String viewType, String widgetId) {
  final creationParams = <String, dynamic>{'widgetId': widgetId};
  return PlatformViewLink(
    viewType: viewType,
    surfaceFactory: (context, controller) {
      return AndroidViewSurface(
        controller: controller as AndroidViewController,
        gestureRecognizers: _eagerGestureRecognizers(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    },
    onCreatePlatformView: (params) {
      return PlatformViewsService.initExpensiveAndroidView(
        id: params.id,
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      )
        ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
        ..create();
    },
  );
}

class _PlatformPaymentElement extends StatelessWidget {
  final String widgetId;

  const _PlatformPaymentElement({required this.widgetId});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return _androidPlatformView('hyperswitch_payment_element', widgetId);
    }
    // TODO(ios): restore UiKitView once the iOS plugin registers the
    // 'hyperswitch_payment_element' platform view factory.
    throw UnsupportedError(
      'PaymentElement is currently supported on Android only',
    );
  }
}

class _PlatformCvcWidget extends StatelessWidget {
  final String widgetId;

  const _PlatformCvcWidget({required this.widgetId});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return _androidPlatformView('hyperswitch_cvc_widget', widgetId);
    }
    // TODO(ios): restore UiKitView once the iOS plugin registers the
    // 'hyperswitch_cvc_widget' platform view factory.
    throw UnsupportedError('CvcWidget is currently supported on Android only');
  }
}

class PaymentElement extends StatefulWidget {
  final Elements elements;
  final String widgetId;
  final Configuration? configuration;
  final void Function(PaymentEvent)? onPaymentEvent;
  final void Function(PaymentResult)? onPaymentResult;
  final Future<bool> Function(PaymentRequestData)? onPaymentConfirmButtonClick;

  const PaymentElement({
    super.key,
    required this.elements,
    required this.widgetId,
    this.configuration,
    this.onPaymentEvent,
    this.onPaymentResult,
    this.onPaymentConfirmButtonClick,
  });

  @override
  State<PaymentElement> createState() => _PaymentElementState();
}

class _PaymentElementState extends State<PaymentElement> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createElement();
    });
  }

  Future<void> _createElement() async {
    try {
      await widget.elements.createElement(
        type: 'paymentElement',
        widgetId: widget.widgetId,
        configuration: widget.configuration,
        paymentElementController: PaymentElementController(
          widgetId: widget.widgetId,
          onPaymentEvent: widget.onPaymentEvent,
          onPaymentResult: widget.onPaymentResult,
          onPaymentConfirmButtonClick: widget.onPaymentConfirmButtonClick,
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    widget.elements.destroyElement(widget.widgetId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PlatformPaymentElement(widgetId: widget.widgetId);
  }
}

class CvcWidget extends StatefulWidget {
  final Elements elements;
  final String widgetId;
  final Configuration? configuration;
  final void Function(CvcWidgetEvent)? onCvcEvent;

  const CvcWidget({
    super.key,
    required this.elements,
    required this.widgetId,
    this.configuration,
    this.onCvcEvent,
  });

  @override
  State<CvcWidget> createState() => _CvcWidgetState();
}

class _CvcWidgetState extends State<CvcWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createElement();
    });
  }

  Future<void> _createElement() async {
    try {
      await widget.elements.createElement(
        type: 'cvcWidget',
        widgetId: widget.widgetId,
        configuration: widget.configuration,
        cvcWidgetController: CvcWidgetController(
          widgetId: widget.widgetId,
          onCvcEvent: widget.onCvcEvent,
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    widget.elements.destroyElement(widget.widgetId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PlatformCvcWidget(widgetId: widget.widgetId);
  }
}
