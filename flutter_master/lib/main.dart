import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_master/root_coordinator.dart';

final channel = MethodChannel("channel");
RootCoordinator rootCoordinator;

main() {
  print("FLTR: runApp");
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
  @override
  Widget build(BuildContext context) {
    // Создаем координатор после старта приложения.
    rootCoordinator = RootCoordinator(channel: channel);
    return rootCoordinator.getInitialMenu();
  }
}
