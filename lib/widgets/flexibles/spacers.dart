import 'package:tumiapesa/styles.dart';
import 'package:flutter/cupertino.dart';

class Space extends StatelessWidget {
  final double width;
  final double height;

  Space(this.width, this.height);

  @override
  Widget build(BuildContext context) => SizedBox(width: width, height: height);
}

class VSpace extends StatelessWidget {
  final double size;

  const VSpace(this.size, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Space(0, size);

  static VSpace get xs => VSpace(Insets.xs);
  static VSpace get sm => VSpace(Insets.sm);
  static VSpace get md => VSpace(Insets.md);
  static VSpace get lg => VSpace(Insets.lg);
  static VSpace get bottom =>
      VSpace(Insets.lg * 3); // bottom offset usually in  a list
}

class HSpace extends StatelessWidget {
  final double size;

  const HSpace(this.size, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Space(size, 0);

  static HSpace get xs => HSpace(Insets.xs);
  static HSpace get sm => HSpace(Insets.sm);
  static HSpace get md => HSpace(Insets.md);
  static HSpace get lg => HSpace(Insets.lg);
}
