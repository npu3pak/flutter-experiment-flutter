import 'package:flutter/material.dart';
import 'package:flutter_master/coordinator.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DebugWidget(),
    ),
  );
}

class DebugWidget extends StatelessWidget {
  final rootCoordinator = RootCoordinator();

  @override
  Widget build(BuildContext context) {
    rootCoordinator.listenChannel();
    return rootCoordinator.getMenu();
  }
}
