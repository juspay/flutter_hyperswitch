import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/gestures.dart'
    show OneSequenceGestureRecognizer, EagerGestureRecognizer;
import 'flutter_hyperswitch.dart';
import 'src/widget_registry.dart';

// The native payment form must win the gesture arena (e.g. inside a
// scrollable), otherwise taps on its fields are swallowed by Flutter.
Set<Factory<OneSequenceGestureRecognizer>> _eagerGestureRecognizers() => {
  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
};

Widget _hyperswitchPlatformView(String viewType, String widgetId) {
  final creationParams = <String, dynamic>{'widgetId': widgetId};
  if (Platform.isAndroid) {
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
          ..addOnPlatformViewCreatedListener(
            (id) => WidgetRegistry.onViewCreated(widgetId, id),
          )
          ..create();
      },
    );
  }
  return UiKitView(
    viewType: viewType,
    creationParams: creationParams,
    creationParamsCodec: const StandardMessageCodec(),
    gestureRecognizers: _eagerGestureRecognizers(),
    onPlatformViewCreated: (id) => WidgetRegistry.onViewCreated(widgetId, id),
  );
}

class _PlatformPaymentElement extends StatelessWidget {
  final String widgetId;

  const _PlatformPaymentElement({required this.widgetId});

  @override
  Widget build(BuildContext context) {
    return _hyperswitchPlatformView('hyperswitch_payment_element', widgetId);
  }
}

class _PlatformCvcWidget extends StatelessWidget {
  final String widgetId;

  const _PlatformCvcWidget({required this.widgetId});

  @override
  Widget build(BuildContext context) {
    return _hyperswitchPlatformView('hyperswitch_cvc_widget', widgetId);
  }
}

class PaymentElement extends StatefulWidget {
  final Elements elements;
  final String widgetId;
  final Configuration? configuration;

  /// Receives every event listed in `configuration.subscriptionEvents`.
  final void Function(PaymentEvent)? onChange;
  @Deprecated('Use onChange')
  final void Function(PaymentEvent)? onPaymentEvent;
  final void Function(PaymentResult)? onPaymentResult;
  final Future<bool> Function(PaymentRequestData)? onPaymentConfirmButtonClick;

  /// Fires once the element has loaded. No subscription needed.
  final VoidCallback? onReady;

  /// Fires when focus enters the element, not when moving between its fields.
  final VoidCallback? onFocus;

  /// Fires when focus leaves the element, not when moving between its fields.
  final VoidCallback? onBlur;

  const PaymentElement({
    super.key,
    required this.elements,
    required this.widgetId,
    this.configuration,
    this.onChange,
    @Deprecated('Use onChange') this.onPaymentEvent,
    this.onPaymentResult,
    this.onPaymentConfirmButtonClick,
    this.onReady,
    this.onFocus,
    this.onBlur,
  });

  @override
  State<PaymentElement> createState() => _PaymentElementState();
}

class _PaymentElementState extends State<PaymentElement> {
  @override
  void initState() {
    super.initState();
    WidgetRegistry.register(widget.widgetId, WidgetKind.paymentElement);
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
        /* Callbacks read `widget` when they fire, so a rebuilt widget's new handlers apply.
           Native always awaits the confirm-click answer; with no handler it proceeds. */
        paymentElementController: PaymentElementController(
          widgetId: widget.widgetId,
          onChange: (event) => widget.onChange?.call(event),
          // ignore: deprecated_member_use_from_same_package
          onPaymentEvent: (event) => widget.onPaymentEvent?.call(event),
          onPaymentResult: (result) => widget.onPaymentResult?.call(result),
          onPaymentConfirmButtonClick: (data) async =>
              await widget.onPaymentConfirmButtonClick?.call(data) ?? true,
          onReady: () => widget.onReady?.call(),
          onFocus: () => widget.onFocus?.call(),
          onBlur: () => widget.onBlur?.call(),
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetRegistry.unregister(widget.widgetId);
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

  /// Receives `cvcStatusChange` when it is listed in `configuration.subscriptionEvents`.
  final void Function(PaymentEvent)? onChange;
  @Deprecated('Use onChange')
  // ignore: deprecated_member_use_from_same_package
  final void Function(CvcWidgetEvent)? onCvcEvent;

  /// Fires once the element has loaded. No subscription needed.
  final VoidCallback? onReady;

  /// Fires when focus enters the element, not when moving between its fields.
  final VoidCallback? onFocus;

  /// Fires when focus leaves the element, not when moving between its fields.
  final VoidCallback? onBlur;

  const CvcWidget({
    super.key,
    required this.elements,
    required this.widgetId,
    this.configuration,
    this.onChange,
    @Deprecated('Use onChange') this.onCvcEvent,
    this.onReady,
    this.onFocus,
    this.onBlur,
  });

  @override
  State<CvcWidget> createState() => _CvcWidgetState();
}

class _CvcWidgetState extends State<CvcWidget> {
  @override
  void initState() {
    super.initState();
    WidgetRegistry.register(widget.widgetId, WidgetKind.cvcWidget);
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
        /* Callbacks read `widget` when they fire, so a rebuilt widget's new handlers apply.
           Whether onCvcEvent is set is fixed at creation: it decides the CVC status subscription. */
        cvcWidgetController: CvcWidgetController(
          widgetId: widget.widgetId,
          onChange: (event) => widget.onChange?.call(event),
          // ignore: deprecated_member_use_from_same_package
          onCvcEvent: widget.onCvcEvent == null
              ? null
              // ignore: deprecated_member_use_from_same_package
              : (event) => widget.onCvcEvent?.call(event),
          onReady: () => widget.onReady?.call(),
          onFocus: () => widget.onFocus?.call(),
          onBlur: () => widget.onBlur?.call(),
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetRegistry.unregister(widget.widgetId);
    widget.elements.destroyElement(widget.widgetId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PlatformCvcWidget(widgetId: widget.widgetId);
  }
}
