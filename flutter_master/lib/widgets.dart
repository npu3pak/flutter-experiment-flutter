import 'package:flutter/material.dart';
import 'package:flutter_slave/main.dart' as slave;

class MenuWidget extends StatelessWidget {
  final Function onPop;
  final Function onShowText;
  final Function onShowBrowser;
  final Function onShowTextFromNative;
  final Function onShowBrowserFromNative;
  final Function onShowNative;
  final Function onShowMenu;
  final Function onShowChild;

  const MenuWidget({
    Key key,
    this.onPop,
    @required this.onShowText,
    @required this.onShowBrowser,
    @required this.onShowTextFromNative,
    @required this.onShowBrowserFromNative,
    @required this.onShowNative,
    @required this.onShowMenu,
    @required this.onShowChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onPop,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                child: Text("Text"),
                onPressed: () {
                  onShowText();
                },
              ),
              MaterialButton(
                child: Text("Browser"),
                onPressed: () {
                  onShowBrowser();
                },
              ),
              MaterialButton(
                child: Text("Text From Native"),
                onPressed: () {
                  onShowTextFromNative();
                },
              ),
              MaterialButton(
                child: Text("Browser From Native"),
                onPressed: () {
                  onShowBrowserFromNative();
                },
              ),
              MaterialButton(
                child: Text("Native"),
                onPressed: () {
                  onShowNative();
                },
              ),
              MaterialButton(
                child: Text("Menu"),
                onPressed: () {
                  onShowMenu();
                },
              ),
              MaterialButton(
                child: Text("Child coordinator"),
                onPressed: () {
                  onShowChild();
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
  final Function onPop;

  const TextWidget({
    Key key,
    @required this.onPop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onPop,
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
  final Function onPop;

  const BrowserScreenWidget({
    Key key,
    @required this.onPop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return slave.BrowserWidget(
      onPop: onPop,
    );
  }
}

class ChildRoot extends StatefulWidget {
  final Function onPop;
  final Function onShowNext;

  const ChildRoot({
    Key key,
    @required this.onPop,
    this.onShowNext,
  }) : super(key: key);

  @override
  _ChildRootState createState() => _ChildRootState();
}

class _ChildRootState extends State<ChildRoot> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onPop,
        ),
        title: Text("Child stack"),
      ),
      body: Container(
        color: Colors.amber,
        child: MaterialButton(
          child: Text("Next"),
          onPressed: () {
            widget.onShowNext();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("FLTR: Child disposed");
    super.dispose();
  }
}
