import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/marketplace/payloan/account_information.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/banner.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';
import 'package:tumiapesa/utils/extension.dart';

class PayLoanPage extends StatefulWidget {
  @override
  _PayLoanPageState createState() => _PayLoanPageState();
}

class _PayLoanPageState extends State<PayLoanPage> {
  int selectedAId = 0,
      selectedPId = 0,
      selectedOId; // selected account and payment Ids
  bool isVisible = false, isOthers = false;

  final _formLoadKey = GlobalKey<FormState>();
  TextEditingController _narrationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Pay Loan'),
      body: SingleChildScrollView(
        child: Form(
          key: _formLoadKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Column(
              children: [
                VSpace.md,
                TumiaPesaBanner(
                  imgUrl: AppImages.tv,
                  title: 'Pay Loan',
                  subtitle: 'Anytime, anywhere',
                ),
                VSpace.sm,
                SmallText(
                  "Fill in details",
                  align: TextAlign.center,
                ),
                VSpace.md,
                VSpace.lg,
                DropDownTextInputField(
                  labelText: 'Select provider',
                  isOnboardingField: true,
                  onSaved: (value) {},
                  // ignore: prefer_const_literals_to_create_immutables
                  items: [
                    DropDownItem(
                        imgUrl: 'assets/images/bodaboda.png',
                        title: 'Boda Boda Banja',
                        value: '1'),
                  ],
                ),
                VSpace.lg,
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SmallText(
                      'Select account type',
                    ),
                  ),
                ),
                Row(
                  children: accountTypes
                      .map(
                        (e) => RadioItem(
                          item: e,
                          selected: e.id == selectedAId,
                          onSelect: (id) => setState(() {
                            selectedAId = id;
                          }),
                        ),
                      )
                      .toList(),
                ),
                VSpace.md,
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SmallText(
                      'Choose payment type',
                    ),
                  ),
                ),
                ...paymentTypes
                    .map((e) => RadioItem(
                          item: e,
                          selected: e.id == selectedPId,
                          onSelect: (id) => setState(() {
                            selectedPId = id;
                            if (id == 2) {
                              isVisible = true;
                            } else {
                              isVisible = false;
                            }
                          }),
                        ))
                    .toList(),
                Visibility(
                  visible: isVisible,
                  child: Column(
                    children: [
                      VSpace.md,
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SmallText(
                            'Choose Others payment type',
                          ),
                        ),
                      ),
                      ...otherPaymentTypes
                          .map((e) => RadioItem(
                                item: e,
                                selected: e.id == selectedOId,
                                onSelect: (id) => setState(() {
                                  selectedOId = id;
                                  if (id == 3) {
                                    isOthers = true;
                                  } else {
                                    isOthers = false;
                                  }
                                }),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                Visibility(
                  visible: isOthers,
                  child: Column(
                    children: [
                      VSpace.md,
                      TextInputField(
                        labelText: 'Others Narration',
                        controller: _narrationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Others Narration';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                      ),
                    ],
                  ),
                ),
                VSpace.lg,
                PElevatedbtn(
                  'Next',
                  onTap: () async {
                    if (isOthers) {
                      if (_formLoadKey.currentState.validate()) {
                        setState(() {
                          _formLoadKey.currentState.save();
                        });
                        Navigator.push(
                          context,
                          PageRouter.fadeThrough(
                            () => PayloadAccountInformationPage(
                              'Boda Boda Banja',
                              paymentTypes.elementAt(selectedPId).type,
                              otherPaymentTypes.elementAt(selectedOId).type,
                              _narrationController.text,
                            ),
                          ),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        PageRouter.fadeThrough(
                          () => PayloadAccountInformationPage(
                            'Boda Boda Banja',
                            paymentTypes.elementAt(selectedPId).type,
                            paymentTypes.elementAt(selectedPId).type ==
                                    'Other Payments'
                                ? otherPaymentTypes.elementAt(selectedOId).type
                                : '',
                            _narrationController.text.isNotEmpty
                                ? _narrationController.text
                                : '',
                          ),
                        ),
                      );
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: MediumText(
                    'Cancel',
                  ),
                ).onTap(() => Navigator.pop(context)),
                VSpace.lg
              ],
            ),
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

final paymentTypes = [
  Item(id: 0, type: 'Weekly Payments'),
  Item(id: 1, type: 'Tax'),
  Item(id: 2, type: 'Other Payments'),
  Item(id: 3, type: 'Down Payment'),
];

final otherPaymentTypes = [
  Item(id: 0, type: 'Repossession Charges'),
  Item(id: 1, type: 'Penalty'),
  Item(id: 2, type: 'Tin'),
  Item(id: 3, type: 'Others'),
];

final accountTypes = [
  Item(id: 0, type: 'Personal'),
];

class Item {
  final String type;
  final int id;
  Item({this.id, this.type});
}
