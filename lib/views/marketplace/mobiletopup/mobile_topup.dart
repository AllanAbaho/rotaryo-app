import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/mobilemoney/mobile_money.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/banner.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';
import 'package:tumiapesa/utils/extension.dart';

class MobileTopupPage extends StatefulWidget {
  @override
  _MobileTopupPageState createState() => _MobileTopupPageState();
}

class _MobileTopupPageState extends State<MobileTopupPage> {
  int selectedOpt = 0;
  Future<void> next() => Navigator.push(
        context,
        PageRouter.fadeScale(
          () => TransactionSuccessPage(
            body: "Mobile top-up successful",
            templateId: 4,
            imgUrl: AppImages.mtn,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Mobile top up'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
          child: Column(
            children: [
              VSpace.md,
              TumiaPesaBanner(
                imgUrl: AppImages.sim,
                title: 'Mobile',
                subtitle: 'Top-up',
              ),
              VSpace.lg,
              Row(
                children: options
                    .map((e) => RadioItem(
                          item: e,
                          selected: e.id == selectedOpt,
                          onSelect: (id) => setState(() {
                            selectedOpt = id;
                          }),
                        ))
                    .toList(),
              ),
              VSpace.md,
             DropDownTextInputField(
                labelText: 'Select provider',
                isOnboardingField: true,
                onSaved: (value) {},
                // prefixIcon: Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: LocalImage(
                //     AppImages.bodaboda,
                //     height: 10,
                //   ),
                // ),
               items: [
                  DropDownItem(imgUrl: 'assets/images/mtn.png', title: 'MTN', value: '1'),
                  DropDownItem(imgUrl: 'assets/images/airtel.png', title: 'Airtel', value: '2'),
               
                ],
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Enter recipient phone number',
                onSaved: (value) {},
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Enter  amount',
                onSaved: (value) {},
              ),
              VSpace.lg,
              PElevatedbtn(
                'Top-Up',
                onTap: () async {
                  final paymentMethod = await Navigator.push<PaymentMethod>(
                    context,
                    PageRouter.fadeThrough(
                      () => SelectPaymentMethodPage(),
                    ),
                  );

                  if (paymentMethod.id == 1) {
                    await Navigator.push(
                      context,
                      PageRouter.fadeThrough(
                        () => DebitCardPage(
                          next: () => next(),
                        ),
                      ),
                    );
                  } else if (paymentMethod.id == 2) {
                    await Navigator.push(
                      context,
                      PageRouter.fadeThrough(
                        () => MobileMoneyPage(
                          next: () async {
                            final pinValid = await Navigator.push<bool>(
                              context,
                              PageRouter.fadeThrough(
                                () => PinPage(),
                              ),
                            );
                            if (pinValid) {}
                            next();
                          },
                        ),
                      ),
                    );
                  } else {
                    final pinValid = await Navigator.push<bool>(
                      context,
                      PageRouter.fadeThrough(
                        () => PinPage(),
                      ),
                    );
                    if (pinValid) {}
                    next();
                  }
                },
              ),
              VSpace.lg
            ],
          ),
        ),
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final Item item;
  final bool selected;
  final Function(int) onSelect;
  RadioItem({this.item, this.selected = false, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.5),
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primaryColor : Color(0xFFC8C4C5),
                )),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryColor : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          HSpace.md,
          SmallText(
            item.type,
            size: FontSizes.s14,
          )
        ],
      ),
    ).onTap(() => onSelect(item.id));
  }
}

final options = [
  Item(id: 0, type: 'Airtime'),
  Item(id: 1, type: 'Data'),
];

class Item {
  final String type;
  final int id;
  Item({this.id, this.type});
}
