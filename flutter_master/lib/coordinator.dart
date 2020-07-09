import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum WidgetSource { flutter, nativeApp }

class Coordinator {
  var _clearOnPush = false;
  List<BuildContext> _contextStack = [];
  List<WidgetSource> _sourceStack = [];
  final MethodChannel methodChannel;

  Coordinator({@required this.methodChannel});

  clear() {
    _clearOnPush = true;
  }

  pop() {
    print("FLTR: ==========");
    print("FLTR: Перед POP");
    print("FLTR: sources = $_sourceStack");
    print("FLTR: contexts = $_contextStack");
    var ctx = _contextStack.last;
    var source = _sourceStack.last;

    if (source == WidgetSource.flutter) {
      _contextStack.removeLast();
      _sourceStack.removeLast();
      Navigator.pop(ctx);
    } else {
      _sourceStack.removeLast();
      methodChannel.invokeMethod("pop");
    }
    print("FLTR: После POP");
    print("FLTR: sources = $_sourceStack");
    print("FLTR: contexts = $_contextStack");
  }

  push(Widget widget, {animated = true, source = WidgetSource.flutter}) {
    var route =
        animated ? _getAnimatedRoute(widget) : _getNotAnimatedRoute(widget);
    var ctx = _contextStack.last;

    print("Показываем $widget. _clearOnPush=$_clearOnPush");
    if (_clearOnPush) {
      _clearOnPush = false;
      _sourceStack = [source];
      _contextStack.clear();
      Navigator.pushAndRemoveUntil(ctx, route, (route) => false);
    } else {
      _sourceStack.add(source);
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
    coordinator._contextStack.add(context);
    return contentWidget;
  }
}
