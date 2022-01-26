import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class DebitCardPage extends StatefulWidget {
  final Function next;
  DebitCardPage({this.next});

  @override
  _DebitCardPageState createState() => _DebitCardPageState();
}

class _DebitCardPageState extends State<DebitCardPage> {
  bool save = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
          child: Column(
            children: [
              VSpace.lg,
              MediumText("We're almost there!", size: FontSizes.s20),
              VSpace.xs,
              SmallText(
                "Fill in details",
                size: FontSizes.s14,
                align: TextAlign.center,
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Amount',
                hintText: 'UGX500',
                onSaved: (value) {},
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Enter Card number',
                hintText: '12345672',
                onSaved: (value) {},
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: LocalImage(
                    AppImages.mastercard,
                    width: 4,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              VSpace.md,
              Row(
                children: [
                  Expanded(
                    child: TextInputField(
                      labelText: 'Enter CVV',
                      hintText: '123',
                      onSaved: (value) {},
                    ),
                  ),
                  HSpace.md,
                  Expanded(
                    child: TextInputField(
                      labelText: 'Expiry date',
                      hintText: 'MM/YY',
                      onSaved: (value) {},
                    ),
                  ),
                ],
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Enter Name on card',
                hintText: 'JAMES PHILEMON',
                onSaved: (value) {},
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallText('Save card details'),
                  Switch(
                    value: save,
                    onChanged: (value) => setState(
                      () {
                        save = !save;
                      },
                    ),
                    activeColor: AppColors.primaryColor,
                  )
                ],
              ),
              VSpace.lg,
              PElevatedbtn(
                'Next',
                onTap: () async {
                  final pinValid = await Navigator.push<bool>(
                    context,
                    PageRouter.fadeScale(
                      () => PinPage(state: PinState.otp),
                    ),
                  );
                  if (pinValid == true) {
                    // do stuff
                  }
                  widget.next == null
                      ? Navigator.push(
                          context,
                          PageRouter.fadeScale(
                            () => TransactionSuccessPage(
                              body:
                                  "You've successfully added fund to you TUMIA PESA WALLET",
                              templateId: 2,
                              showStatement: false,
                              btnText: 'OK',
                            ),
                          ),
                        )
                      : widget.next();
                },
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
              VSpace.lg,
            ],
          ),
        ),
      ),
    );
  }
}
