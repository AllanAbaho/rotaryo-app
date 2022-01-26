import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/text.dart';

class ManageCardsPage extends StatefulWidget {
  @override
  _ManageCardsPageState createState() => _ManageCardsPageState();
}

class _ManageCardsPageState extends State<ManageCardsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Manage cards'),
      body: Column(
        children: [
          VSpace.md,
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: SmallText('Cards'),
            ),
          ),
          VSpace.md,
          ...List.generate(
            2,
            (i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: _CardListItem(
                name: 'FIRST BANK - VISA',
              ),
            ),
          ),
          Spacer(),
          MediumText(
            'Freeze TUMIA CARD',
            color: Colors.red,
          ),
          VSpace.lg,
        ],
      ),
    );
  }
}

class _CardListItem extends StatelessWidget {
  final String name;
  _CardListItem({
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 60,
      margin: EdgeInsets.only(bottom: Insets.md),
      padding: EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFFAFAFA),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        MediumText(name),
        ImageIcon(
          AssetImage(AppIcons.trash),
          size: 18,
          color: Colors.red,
        ),
      ]),
    );
  }
}
