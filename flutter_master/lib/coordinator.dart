import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Источник навигации при показе нового виджета.
enum NavigationSource {
  /// Используется если нужно показать виджет внетри Flutter или из нативного
  /// приложения, если в настоящее время открыто окно Flutter.
  /// В этом случае новый виджет будет показан с анимацией Flutter, а pop()
  /// для этого виджета выполнит навигацию внутри стека Flutter.
  flutter,

  /// Используется если нужно показать виджет из нативного приложения на новом
  /// нативном экране.
  /// В этом случае новый виджет будет показан без анимации Flutter, т.к. нативный
  /// экран и так показывается с анимацией. Метод pop для этого виджета выполнит
  /// выполнит нативный метод pop и затем, если это возможно, pop внутри стека Flutter.
  nativeApp
}

/// Базовый класс, содержащий методы для навигации, и связывающий стек авигации
/// Flutter со стеком нативного приложения.
class Coordinator {
  final MethodChannel methodChannel;
  List<BuildContext> _contextStack = [];
  List<NavigationSource> _sourceStack = [];

  Coordinator({@required this.methodChannel});

  Widget wrapInitial(Widget widget) {
    return Navigator(
      onGenerateRoute: (settings) {
        WidgetBuilder builder = (_) {
          _sourceStack.add(NavigationSource.flutter);
          return CoordinatedWidget.wrap(widget, this);
        };
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }

  NavigatorState get _currentNavigator => Navigator.of(_contextStack.last);

  /// Метод показывает новый экран с переданным виджетом. Виджет добавляется в
  /// стек навигации. В параметре [source] указывается источник навигации.
  push(Widget widget, {source = NavigationSource.flutter}) {
    var route = source == NavigationSource.flutter
        ? FlutterPageRoute(widget: widget, coordinator: this)
        : NativePageRoute(widget: widget, coordinator: this);

    _printDebug(this, "Перед push. $widget, source: $source");

    _sourceStack.add(source);
    _currentNavigator.push(route);

    _printDebug(this, "После push. $widget, source: $source");
  }

  /// Метод показывает предыдущий экран в стеке навигации.
  pop() {
    _printDebug(this, "Перед pop");
    var source = _sourceStack.last;

    if (source == NavigationSource.nativeApp) {
      methodChannel.invokeMethod("pop");
    }
    if (_currentNavigator.canPop()) {
      _currentNavigator.pop();
    }

    _printDebug(this, "После pop в Coordinator");
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
    coordinator._contextStack.add(context);
    _printDebug(coordinator, "Перед отображением виджета");
    return contentWidget;
  }
}

/// Route без анимации. Нужен чтобы показывать новый виджет Flutter в новом окне
/// нативного приложения. Т.к. анимация в данном случае на стороне нативного окна,
/// виджет должен отрисовываться без анимации.
class NativePageRoute extends PageRouteBuilder {
  final Coordinator coordinator;

  NativePageRoute({@required Widget widget, @required this.coordinator})
      : super(
          pageBuilder: (_, __, ___) {
            return CoordinatedWidget.wrap(widget, coordinator);
          },
          transitionDuration: Duration(seconds: 0),
        );

  @override
  bool didPop(result) {
    coordinator._contextStack.removeLast();
    coordinator._sourceStack.removeLast();
    _printDebug(coordinator, "После pop в NativePageRoute");
    return super.didPop(result);
  }
}

/// Route с анимацией. Нужен чтобы показывать новый виджет Flutter в существующем
/// окне нативного приложения.
class FlutterPageRoute extends MaterialPageRoute {
  final Coordinator coordinator;

  FlutterPageRoute({@required Widget widget, @required this.coordinator})
      : super(builder: (_) => CoordinatedWidget.wrap(widget, coordinator));

  @override
  bool didPop(result) {
    coordinator._contextStack.removeLast();
    coordinator._sourceStack.removeLast();
    _printDebug(coordinator, "После pop в FlutterPageRoute");
    return super.didPop(result);
  }
}

_printDebug(Coordinator coordinator, title) {
  print("FLTR: ");
  print("FLTR: ");
  print("FLTR: $title");
  print("FLTR: sources = ${coordinator._sourceStack}");

  var ctxStackWidgets = coordinator._contextStack.map((e) {
    return (e.widget as CoordinatedWidget).contentWidget;
  });
  print("FLTR: contexts = $ctxStackWidgets");

  print("FLTR: ");
  print("FLTR: ");
}
