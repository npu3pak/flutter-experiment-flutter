import 'package:flutter/material.dart';
import 'package:flutter_master/widgets.dart';
import 'package:flutter_master/coordinator.dart';

class RootCoordinator extends Coordinator {
  RootCoordinator({@required channel}) : super(methodChannel: channel);

  handleChannelPush(
    String route, {
    @required NavigationSource source,
  }) {
    switch (route) {
      case "text":
        push(
          TextWidget(onPop: pop),
          source: source,
        );
        break;
      case "browser":
        push(
          BrowserScreenWidget(onPop: pop),
          source: source,
        );
        break;
      case "menu":
        push(
          getMenu(onPop: pop),
          source: source,
        );
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
    push(TextWidget(onPop: pop));
  }

  showBrowser() {
    push(BrowserScreenWidget(onPop: pop));
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
    push(getMenu(onPop: pop));
  }
}
