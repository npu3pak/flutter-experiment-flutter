import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_master/coordinator.dart';

final channel = MethodChannel("channel");
final rootCoordinator = RootCoordinator(channel: channel);

main() {
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
    // Слушаем канал после старта приложения
    startChannelListening(context);
    return rootCoordinator.getMenu();
  }
}

startChannelListening(BuildContext context) {
  channel.setMethodCallHandler((call) {
    switch (call.method) {
      case "pushRoute":
        rootCoordinator.changeRote(
          call.arguments,
          animated: false,
        );
        break;
      case "pushRouteAnimated":
        rootCoordinator.changeRote(
          call.arguments,
          animated: true,
        );
        break;
      case "clearRoute":
        rootCoordinator.clearRoute(context);
        break;
    }
    return null;
  });
}
