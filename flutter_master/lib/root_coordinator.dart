import 'package:flutter/material.dart';
import 'package:flutter_master/widgets.dart';
import 'package:flutter_master/coordinator.dart';

class RootCoordinator extends Coordinator {
  RootCoordinator({@required channel}) : super(methodChannel: channel);

  pushFromNative(
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
        push(getMenu(onPop: pop), animated: animated);
        break;
    }
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
    methodChannel.invokeMethod("showFlutterText");
  }

  showBrowserFromNative() {
    methodChannel.invokeMethod("showFlutterBrowser");
  }

  showNative() {
    methodChannel.invokeMethod("showNative");
  }

  showMenu() {
    push(getMenu(onPop: pop), animated: true);
  }
}
