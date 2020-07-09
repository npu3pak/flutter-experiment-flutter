import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NavigationSource { flutter, nativeApp }

printDebug(Coordinator coordinator, title) {
  print("FLTR: ");
  print("FLTR: ");
  print("FLTR: $title");
  print("FLTR: sources = ${coordinator.sourceStack}");

  var ctxStackWidgets = coordinator.contextStack.map((e) {
    return (e.widget as CoordinatedWidget).contentWidget;
  });
  print("FLTR: contexts = $ctxStackWidgets");

  print("FLTR: ");
  print("FLTR: ");
}

class Coordinator {
  var _clearOnPush = false;
  List<BuildContext> contextStack = [];
  List<NavigationSource> sourceStack = [];
  final MethodChannel methodChannel;

  Coordinator({@required this.methodChannel});

  clear() {
    _clearOnPush = true;
  }

  pop() {
    printDebug(this, "Перед pop");
    var ctx = contextStack.last;
    var source = sourceStack.removeLast();

    if (source == NavigationSource.nativeApp) {
      methodChannel.invokeMethod("pop");
    }
    if (Navigator.canPop(ctx)) {
      Navigator.pop(ctx);
      contextStack.removeLast();
    }

    printDebug(this, "После pop");
  }

  push(Widget widget, {animated = true, source = NavigationSource.flutter}) {
    var route =
        animated ? _getAnimatedRoute(widget) : _getNotAnimatedRoute(widget);
    var ctx = contextStack.last;

    printDebug(
        this, "Перед push. $widget, animated: $animated, source: $source");

    if (_clearOnPush) {
      _clearOnPush = false;
      sourceStack = [source];
      contextStack.clear();
      Navigator.pushAndRemoveUntil(ctx, route, (route) => false);
    } else {
      sourceStack.add(source);
      Navigator.push(ctx, route);
    }
    printDebug(
        this, "После push. $widget, animated: $animated, source: $source");
  }

  MaterialPageRoute _getAnimatedRoute(Widget widget) {
    return MaterialPageRoute(
      builder: (context) {
        return CoordinatedWidget.wrap(widget, this);
      },
    );
  }

  PageRouteBuilder _getNotAnimatedRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        return CoordinatedWidget.wrap(widget, this);
      },
      transitionDuration: Duration(seconds: 0),
    );
  }
}

class CoordinatedWidget extends StatelessWidget {
  final Widget contentWidget;
  final Coordinator coordinator;

  const CoordinatedWidget._(
    this.contentWidget,
    this.coordinator, {
    Key key,
  }) : super(key: key);

  static CoordinatedWidget wrap(
    Widget widget,
    Coordinator coordinator,
  ) {
    if (widget is CoordinatedWidget) {
      return widget;
    } else {
      return CoordinatedWidget._(widget, coordinator);
    }
  }

  @override
  Widget build(BuildContext context) {
    coordinator.contextStack.add(context);
    printDebug(coordinator, "Перед отображением виджета");
    return contentWidget;
  }
}
