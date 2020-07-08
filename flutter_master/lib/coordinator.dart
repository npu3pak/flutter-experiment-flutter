import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Coordinator {
  var _clearOnPush = false;
  List<BuildContext> contextStack = [];
  final MethodChannel methodChannel;

  Coordinator({@required this.methodChannel});

  clear() {
    _clearOnPush = true;
  }

  pop() {
    var ctx = contextStack.last;
    if (Navigator.canPop(ctx)) {
      contextStack.removeLast();
      Navigator.pop(ctx);
    } else {
      _clearOnPush = true;
      methodChannel.invokeMethod("pop");
    }
  }

  push(Widget widget, {animated = true}) {
    var route =
        animated ? _getAnimatedRoute(widget) : _getNotAnimatedRoute(widget);
    var ctx = contextStack.last;

    print("Показываем $widget. _clearOnPush=$_clearOnPush");
    if (_clearOnPush) {
      _clearOnPush = false;
      Navigator.pushAndRemoveUntil(ctx, route, (route) => false);
    } else {
      Navigator.push(ctx, route);
    }
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
    return contentWidget;
  }
}
