import 'package:flutter/material.dart';
import 'package:flutter_master/coordinator.dart';
import 'package:flutter_master/widgets.dart';

class ChildCoordinator extends Coordinator {
  Function onParentPop;

  Widget getInitial({Function onPop}) {
    onParentPop = onPop;
    return wrapInitial(ChildRoot(
      onPop: onPop,
      onShowNext: showNext,
    ));
  }

  showNext() {
    push(ChildRoot(
      onPop: onParentPop,
      onShowNext: showNext,
    ));
  }
}
