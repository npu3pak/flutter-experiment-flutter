import 'package:flutter/material.dart';
import 'package:flutter_slave/main.dart' as slave;

class MenuWidget extends StatelessWidget {
  final Function(BuildContext ctx) onShowText;
  final Function(BuildContext ctx) onShowBrowser;
  final Function(BuildContext ctx) onShowNative;
  final Function(BuildContext ctx) onShowMenu;

  const MenuWidget({
    Key key,
    this.onShowText,
    this.onShowBrowser,
    this.onShowNative,
    this.onShowMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                child: Text("Text"),
                onPressed: () {
                  onShowText(context);
                },
              ),
              MaterialButton(
                child: Text("Browser"),
                onPressed: () {
                  onShowBrowser(context);
                },
              ),
              MaterialButton(
                child: Text("Native"),
                onPressed: () {
                  onShowNative(context);
                },
              ),
              MaterialButton(
                child: Text("Menu"),
                onPressed: () {
                  onShowMenu(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final Function(BuildContext context) onPop;

  const TextWidget({Key key, this.onPop}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            onPop(context);
          },
        ),
        title: Text("Screen with text"),
      ),
      body: Center(
        child: Text("Text"),
      ),
    );
  }
}

class BrowserScreenWidget extends StatelessWidget {
  final Function(BuildContext context) onPop;

  const BrowserScreenWidget({Key key, this.onPop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return slave.BrowserWidget(
      onPop: onPop,
    );
  }
}
