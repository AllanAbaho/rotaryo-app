import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';
import 'package:tumiapesa/utils/extension.dart';

class AddFromMobileMoneyPage extends StatelessWidget {
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
              SmallText('Add Funds from'),
              MediumText(
                "Mobile Money",
                fontWeight: FontW.bold,
                size: FontSizes.s20,
              ),
              VSpace.lg,
              TextInputField(
                labelText: 'Enter Mobile money number',
                onSaved: (value) {},
              ),
              VSpace.md,
              TextInputField(
                labelText: 'Enter Amount',
                onSaved: (value) {},
              ),
              VSpace.lg,
              Align(
                alignment: Alignment.centerLeft,
                child: SmallText(
                  'Confirm with mobile money 4-Digit pin',
                ),
              ),
              VSpace.sm,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                child: PinInputField(),
              ),
              VSpace.lg,
              PElevatedbtn(
                'Next',
                onTap: () async {
                  Navigator.push(
                    context,
                    PageRouter.fadeScale(
                      () => TransactionSuccessPage(
                        title: 'Kudos!',
                        body: "You've added UGX500 to your Tumia pesa card",
                      ),
                    ),
                  );
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
              VSpace.lg
            ],
          ),
        ),
      ),
    );
  }
}
