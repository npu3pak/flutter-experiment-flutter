import 'package:flutter/material.dart';
import 'package:flutter_master/child_coordinator.dart';
import 'package:flutter_master/widgets.dart';
import 'package:flutter_master/coordinator.dart';

class RootCoordinator extends Coordinator {
  RootCoordinator({@required channel}) : super(methodChannel: channel) {
    _startChannelListening();
  }

  _startChannelListening() {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "pushRouteFromNative":
          _handleChannelPush(
            call.arguments,
            source: NavigationSource.nativeApp,
          );
          break;
        case "pushRouteFromFlutter":
          _handleChannelPush(
            call.arguments,
            source: NavigationSource.flutter,
          );
          break;
      }
      return null;
    });
  }

  _handleChannelPush(
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
          getMenu(),
          source: source,
        );
        break;
      case "child":
        final childCoordinator = ChildCoordinator();
        push(
          childCoordinator.getInitial(onPop: pop),
          source: source,
        );
        break;
    }
  }

  // Бизнес-логика

  Widget getInitialMenu() {
    final menu = MenuWidget(
      onShowText: showText,
      onShowBrowser: showBrowser,
      onShowMenu: showMenu,
      onShowNative: showNative,
      onShowBrowserFromNative: showBrowserFromNative,
      onShowTextFromNative: showTextFromNative,
      onShowChild: showChild,
    );
    return wrapInitial(menu);
  }

  Widget getMenu() {
    return MenuWidget(
      onPop: pop,
      onShowText: showText,
      onShowBrowser: showBrowser,
      onShowMenu: showMenu,
      onShowNative: showNative,
      onShowBrowserFromNative: showBrowserFromNative,
      onShowTextFromNative: showTextFromNative,
      onShowChild: showChild,
    );
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
    push(getMenu());
  }

  showChild() {
    final childCoordinator = ChildCoordinator();
    push(childCoordinator.getInitial(onPop: pop));
  }
}
