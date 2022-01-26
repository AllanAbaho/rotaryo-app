import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/pin/pin2.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/text.dart';

import 'mobilemoney/recipient_details.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  @override
  _SelectPaymentMethodPageState createState() =>
      _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  int selectedId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppbar(context),
        body: Column(
          children: [
            VSpace.lg,
            MediumText("Just a little bit more", size: FontSizes.s20),
            VSpace.xs,
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
              child: Align(
                child: SmallText(
                  'Where should we take the money from',
                  size: FontSizes.s14,
                  align: TextAlign.center,
                ),
              ),
            ),
            VSpace.lg,
            ...paymentMethods
                .map((e) => PaymentMethodItem(
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
                'Confirm',
                onTap: () {
                  // if (selectedId != 1) {
                  Navigator.pop(
                    context,
                    paymentMethods.firstWhere((e) => e.id == selectedId),
                  );
                  // Navigator.push(
                  //   context,
                  //   PageRouter.fadeScale(() => PinPage()),
                  // );
                  // } else {
                  //   Navigator.push(
                  //     context,
                  //     PageRouter.fadeScale(() => DebitCardPage()),
                  //   );
                  // }
                  //  Navigator.push(context, PageRouter.fadeScale(
                  //                                ()=>DebitCardPage()
                  //                              ));
                  // Navigator.pop(context,
                  //     paymentMethods.firstWhere((e) => e.id == selectedId));
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
            ),
            VSpace.lg
          ],
        ));
  }
}

class PaymentMethodItem extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final Function(int) onSelect;
  PaymentMethodItem({
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
      ),
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

final paymentMethods = [
  PaymentMethod(name: 'My tumia pesa wallet', id: 0),
  PaymentMethod(name: 'My debit card', id: 1),
  PaymentMethod(name: 'Mobile money', id: 2),
];

class PaymentMethod {
  String name;
  int id;
  PaymentMethod({this.name, this.id});
}
