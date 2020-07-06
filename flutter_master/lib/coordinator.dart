import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_master/widgets.dart';

class RootCoordinator {
  final _methodChannel = MethodChannel("channel");
  var _clearOnPush = false;

  listenChannel() {
    _methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "changeRoute":
          _changeRote(call.arguments, animated: false);
          break;
        case "changeRouteAnimated":
          _changeRote(call.arguments, animated: true);
          break;
        case "clearRoute":
          _clearOnPush = true;
          break;
      }
      return null;
    });
  }

  _changeRote(
    String route, {
    @required BuildContext ctx,
    animated = true,
  }) {
    switch (route) {
      case "text":
        push(TextWidget(onPop: pop), ctx, animated: animated);
        break;
      case "browser":
        push(BrowserScreenWidget(), ctx, animated: animated);
        break;
      case "menu":
        push(getMenu(), ctx, animated: animated);
        break;
    }
  }

  // Бизнес-логика

  Widget getMenu() {
    return MenuWidget(
      onShowText: showText,
      onShowBrowser: showBrowser,
      onShowMenu: showMenu,
      onShowNative: showNative,
    );
  }

  showText(BuildContext ctx) {
    push(TextWidget(onPop: pop), ctx, animated: true);
  }

  showBrowser(BuildContext ctx) {
    push(BrowserScreenWidget(onPop: pop), ctx, animated: true);
  }

  showMenu(BuildContext ctx) {
    push(getMenu(), ctx, animated: true);
  }

  showNative(BuildContext ctx) {
    _methodChannel.invokeMethod("showNative");
  }

  // Методы навигации

  push(Widget widget, BuildContext context, {animated = true}) {
    var route =
        animated ? _getAnimatedRoute(widget) : _getNotAnimatedRoute(widget);

    if (_clearOnPush) {
      _clearOnPush = false;
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    } else {
      Navigator.push(context, route);
    }
  }

  MaterialPageRoute _getAnimatedRoute(Widget widget) {
    return MaterialPageRoute(
      builder: (context) {
        return widget;
      },
    );
  }

  PageRouteBuilder _getNotAnimatedRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        return widget;
      },
      transitionDuration: Duration(seconds: 0),
    );
  }

  pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _clearOnPush = true;
      _methodChannel.invokeMethod("pop");
    }
  }
}
