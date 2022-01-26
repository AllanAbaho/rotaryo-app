import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/fundaccount/mobilemoney/mobile_money.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/text.dart';

class FundAccountPage extends StatefulWidget {
  @override
  _FundAccountPageState createState() => _FundAccountPageState();
}

class _FundAccountPageState extends State<FundAccountPage> {
  int selectedId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppbar(context),
        body: Column(
          children: [
            VSpace.lg,
            MediumText("Add funds", size: FontSizes.s20),
            VSpace.xs,
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
              child: Align(
                child: SmallText(
                  'How would you like to add funds',
                  size: FontSizes.s14,
                  align: TextAlign.center,
                ),
              ),
            ),
            VSpace.lg,
            ...fundMethods
                .map((e) => FundMethodItem(
                      method: e,
                      selected: e.id == selectedId,
                      onSelect: (id) => setState(() {
                        selectedId = id;
                      }),
                    ))
                .toList(),
            VSpace.lg,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: PElevatedbtn(
                'Next',
                onTap: () {
                  Widget next;
                  if (selectedId == 1) {
                    next = FundMobileMoneyRecieptPage(selectedId);
                    Navigator.push(
                      context,
                      PageRouter.fadeThrough(() => next),
                    );
                  } else {
                    next = FundMobileMoneyRecieptPage(selectedId);
                    Navigator.push(
                      context,
                      PageRouter.fadeThrough(() => next),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
              child: Align(
                child: MediumText(
                  'Cancel',
                ),
              ),
            ).onTap(() => Navigator.pop(context)),
            VSpace.lg
          ],
        ));
  }
}

class FundMethodItem extends StatelessWidget {
  final FundMethod method;
  final bool selected;
  final Function(int) onSelect;
  FundMethodItem({
    this.method,
    this.onSelect,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.sm + 3),
      padding: EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.md),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryColor : Color(0xFFC8C4C5),
          ),
          color: selected ? Color(0xFFFFF1F2) : Colors.white),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(selected ? 5 : 1),
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primaryColor : Color(0xFFC8C4C5),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          HSpace.md,
          SmallText(
            method.name,
            size: FontSizes.s16,
          )
        ],
      ),
    ).onTap(() => onSelect(method.id));
  }
}

final fundMethods = [
  FundMethod(name: 'Mobile money', id: 0),
  FundMethod(name: 'Debit card', id: 1),
];

class FundMethod {
  String name;
  int id;
  FundMethod({this.name, this.id});
}
