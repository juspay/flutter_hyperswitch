/// Tracks mounted Hyperswitch widgets (widgetId → kind + platform view id)
/// so calls can be validated before crossing the platform channel.
library;

enum WidgetKind { paymentElement, cvcWidget }

class WidgetRegistry {
  WidgetRegistry._();

  static final Map<String, WidgetKind> _kinds = {};
  static final Map<String, int> _viewIds = {};

  static void register(String widgetId, WidgetKind kind) {
    _kinds[widgetId] = kind;
  }

  static void onViewCreated(String widgetId, int viewId) {
    _viewIds[widgetId] = viewId;
  }

  static void unregister(String widgetId) {
    _kinds.remove(widgetId);
    _viewIds.remove(widgetId);
  }

  static WidgetKind? kindOf(String widgetId) => _kinds[widgetId];

  /// True once the platform view for [widgetId] exists on the native side.
  static bool isMounted(String widgetId) => _viewIds.containsKey(widgetId);
}
