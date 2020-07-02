import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slave/main.dart' as slave;

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: MainWidget(),
  ));
}

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

enum Route { text, browser }

class _MainWidgetState extends State<MainWidget> {
  var _currentRoute = Route.text;

  @override
  void initState() {
    super.initState();

    var methodChannel = MethodChannel("channel");
    methodChannel.setMethodCallHandler((call) {
      if (call.method == "changeRoute") {
        changeRote(call.arguments);
      }
      return null;
    });
  }

  Future<dynamic> changeRote(String route) async {
    switch (route) {
      case "browser":
        _currentRoute = Route.browser;
        break;
      case "text":
        _currentRoute = Route.text;
        break;
    }
    setState(() {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentRoute) {
      case Route.text:
        return TextScreen();
      case Route.browser:
        return BrowserScreen();
      default:
        return Container();
    }
  }
}

class TextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Screen with text"),
      ),
      body: Center(
        child: Text("Text"),
      ),
    );
  }
}

class BrowserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return slave.MyHomePage(
      title: "Screen with browser",
    );
  }
}
