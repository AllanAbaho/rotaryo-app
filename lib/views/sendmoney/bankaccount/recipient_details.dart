import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class BankAccountRecipientPage extends StatelessWidget {
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
              MediumText("Recipient", size: FontSizes.s20),
              VSpace.xs,
              SmallText(
                "Input recipient bank details",
                size: FontSizes.s14,
                align: TextAlign.center,
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Enter amount',
                hintText: 'UGX5000',
                onSaved: (value) {},
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Select Bank',
                hintText: 'Access Bank Plc',
                onSaved: (value) {},
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Account Number',
                onSaved: (value) {},
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Account Name',
                hintText: 'EDWARD PETERS',
                onSaved: (value) {},
              ),
              VSpace.lg,
              PElevatedbtn(
                'Next',
                onTap: () async {
                  final paymentMethod = await Navigator.push<PaymentMethod>(
                    context,
                    PageRouter.fadeScale(
                      () => SelectPaymentMethodPage(),
                    ),
                  );
                  if (paymentMethod != null) {
                    final pinValid = await Navigator.push<bool>(
                      context,
                      PageRouter.fadeScale(
                        () => PinPage(),
                      ),
                    );
                    if (pinValid == true) {
                      // do stuff
                    }

                    Navigator.push(
                      context,
                      PageRouter.fadeScale(
                        () => TransactionSuccessPage(
                          body:
                              "You've successfully transferred UGX500 to EDWARD WALMART",
                          templateId: 2,
                        ),
                      ),
                    );
                  }
                },
              ),
              VSpace.lg,
            ],
          ),
        ),
      ),
    );
  }
}
