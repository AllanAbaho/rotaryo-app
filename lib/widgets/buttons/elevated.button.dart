import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:flutter/material.dart';

/// primary elevated button
class PElevatedbtn extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  /// if child is not we, we want to use it instead of the label
  final Widget child;
  PElevatedbtn(this.label, {this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: context.width,
        height: 54,
        child: ElevatedButton(onPressed: onTap, child: child ?? Text(label)));
  }
}

/// secondary elevated button
class SElevatedbtn extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  /// if child is not we, we want to use it instead of the label
  final Widget child;
  final Color color;
  SElevatedbtn(this.label, {this.color, this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(primary: color ?? AppColors.greyColor),
      child: child ?? Text(label),
    );
  }
}
