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

  /// Метод показывает предыдущий экран в стеке навигации.
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

  /// Метод показывает  стеке навигации новый экран с переданным виджетом.
  push(Widget widget, {source = NavigationSource.flutter}) {
    var ctx = contextStack.last;
    var route = source == NavigationSource.flutter
        ? _getAnimatedRoute(widget)
        : _getNotAnimatedRoute(widget);

    printDebug(this, "Перед push. $widget, source: $source");

    if (_clearOnPush) {
      _clearOnPush = false;
      sourceStack = [source];
      contextStack.clear();
      Navigator.pushAndRemoveUntil(ctx, route, (route) => false);
    } else {
      sourceStack.add(source);
      Navigator.push(ctx, route);
    }
    printDebug(this, "После push. $widget, source: $source");
  }

  /// Route с анимацией. Нужен чтобы показывать новый виджет Flutter в существующем
  /// окне нативного приложения.
  MaterialPageRoute _getAnimatedRoute(Widget widget) {
    return MaterialPageRoute(
      builder: (context) {
        return CoordinatedWidget.wrap(widget, this);
      },
    );
  }

  /// Route без анимации. Нужен чтобы показывать новый виджет Flutter в новом окне
  /// нативного приложения. Т.к. анимация в данном случае на стороне нативного окна,
  /// виджет должен отрисовываться без анимации.
  PageRouteBuilder _getNotAnimatedRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        return CoordinatedWidget.wrap(widget, this);
      },
      transitionDuration: Duration(seconds: 0),
    );
  }
}

/// Виджет оборачивает виджеты, участвующие в навигации, ловит контекст во время
/// отрисовки и сохраняет его в координаторе.
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
