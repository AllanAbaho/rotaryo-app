import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

extension ContextExtension on BuildContext {
  double getHeight({double factor = 1}) {
    assert(factor != null && factor != 0);
    return MediaQuery.of(this).size.height * factor;
  }

  double getWidth({double factor = 1}) {
    assert(factor != null && factor != 0);
    return MediaQuery.of(this).size.width * factor;
  }

  double get height => getHeight();
  double get width => getWidth();
}


extension ClickableExtension on Widget {
  Widget onTap(void Function() action, {bool opaque = true}) {
    return GestureDetector(
      behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onTap: action,
      child: this,
    );
  }
}
