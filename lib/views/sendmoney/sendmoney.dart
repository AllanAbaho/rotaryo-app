import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/sendmoney/bankaccount/recipient_details.dart';
import 'package:tumiapesa/views/sendmoney/mobilemoney/mobile_money.dart';
import 'package:tumiapesa/views/sendmoney/tumiapesa/tumia_pesa.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/text.dart';

class SendMoneyPage extends StatefulWidget {
  String custName, custNumber;

  SendMoneyPage({this.custName, this.custNumber});

  @override
  _SendMoneyPageState createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  int selectedId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppbar(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              VSpace.lg,
              MediumText("Send money the easy way", size: FontSizes.s20),
              VSpace.xs,
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
                child: Align(
                  child: SmallText(
                    'How would your recipient like to recieve the money',
                    size: FontSizes.s14,
                    align: TextAlign.center,
                  ),
                ),
              ),
              VSpace.lg,
              ...paymentMethods
                  .map((e) => SendMethodItem(
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
                    switch (selectedId) {
                      case 1:
                        next = TumiaPesaPage(
                          custName: widget.custName,
                          custNumber: widget.custNumber,
                        );
                        break;
                      // case 2:
                      //   next = BankAccountRecipientPage();
                      //   break;
                      default:
                        next = MobileMoneyPage(
                          custName: widget.custName,
                          custNumber: widget.custNumber,
                          
                        );
                    }
                    Navigator.push(
                      context,
                      PageRouter.fadeThrough(() => next),
                    );
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
          ),
        ));
  }
}

class SendMethodItem extends StatelessWidget {
  final SendMethod method;
  final bool selected;
  final Function(int) onSelect;
  SendMethodItem({
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

final paymentMethods = [
  SendMethod(name: 'Mobile money', id: 0),
  SendMethod(name: 'Tumia pesa account', id: 1),
  // SendMethod(name: 'Bank account', id: 2),
];

class SendMethod {
  String name;
  int id;
  SendMethod({this.name, this.id});
}
