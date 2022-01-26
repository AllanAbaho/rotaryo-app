import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/text.dart';

PreferredSizeWidget customAppbar(BuildContext context,
    {String title, bool xIcon = false}) {
  return AppBar(
    title: MediumText(
      title ?? '',
      color: Colors.black,
    ),
    centerTitle: true,
    elevation: 0,
    automaticallyImplyLeading: false,
    leading: Icon(
      !xIcon ? PhosphorIcons.caretLeftLight : PhosphorIcons.xLight,
      color: Colors.black,
    ).onTap(() => Navigator.maybePop(context)),
    backgroundColor: Colors.transparent,
  );
}
