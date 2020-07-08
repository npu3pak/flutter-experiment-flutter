import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_master/widgets.dart';

class RootCoordinator {
  final MethodChannel channel;
  var _clearOnPush = false;

  List<BuildContext> contextStack = [];

  RootCoordinator({@required this.channel});

  changeRote(
    String route, {
    @required animated,
  }) {
    switch (route) {
      case "text":
        push(TextWidget(onPop: pop), animated: animated);
        break;
      case "browser":
        push(BrowserScreenWidget(onPop: pop), animated: animated);
        break;
      case "menu":
        push(getMenu(), animated: animated);
        break;
    }
  }

  clearRoute(BuildContext context) {
    _clearOnPush = true;
  }

  // Бизнес-логика

  Widget getMenu({onPop}) {
    final menu = MenuWidget(
      onPop: onPop,
      onShowText: showText,
      onShowBrowser: showBrowser,
      onShowMenu: showMenu,
      onShowNative: showNative,
      onShowBrowserFromNative: showBrowserFromNative,
      onShowTextFromNative: showTextFromNative,
    );
    return CoordinatedWidget.wrap(menu, this);
  }

  showText() {
    push(TextWidget(onPop: pop), animated: true);
  }

  showBrowser() {
    push(BrowserScreenWidget(onPop: pop), animated: true);
  }

  showTextFromNative() {
    channel.invokeMethod("showFlutterText");
  }

  showBrowserFromNative() {
    channel.invokeMethod("showFlutterBrowser");
  }

  showNative() {
    channel.invokeMethod("showNative");
  }

  showMenu() {
    push(getMenu(onPop: pop), animated: true);
  }

  // Методы навигации

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

  pop() {
    var ctx = contextStack.last;
    if (Navigator.canPop(ctx)) {
      contextStack.removeLast();
      Navigator.pop(ctx);
    } else {
      _clearOnPush = true;
      channel.invokeMethod("pop");
    }
  }
}

class CoordinatedWidget extends StatelessWidget {
  final Widget contentWidget;
  final RootCoordinator coordinator;

  const CoordinatedWidget._(
    this.contentWidget,
    this.coordinator, {
    Key key,
  }) : super(key: key);

  static CoordinatedWidget wrap(
    Widget widget,
    RootCoordinator coordinator,
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
