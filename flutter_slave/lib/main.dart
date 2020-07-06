import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BrowserWidget(
        onPop: (context) => {},
      ),
    );
  }
}

class BrowserWidget extends StatefulWidget {
  final Function(BuildContext context) onPop;

  BrowserWidget({
    Key key,
    this.onPop,
  }) : super(key: key);

  @override
  _BrowserWidgetState createState() => _BrowserWidgetState();
}

class _BrowserWidgetState extends State<BrowserWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onPop(context);
          },
        ),
        title: Text("Browser"),
      ),
      body: WebViewPlus(initialUrl: 'https://ya.ru'),
    );
  }
}
