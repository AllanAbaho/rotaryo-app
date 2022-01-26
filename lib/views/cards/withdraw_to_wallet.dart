import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class WithdrawToWalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Withdraw'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VSpace.lg,
            SmallText('Withdraw to your'),
            MediumText(
              "Tumia Pesa wallet",
              fontWeight: FontW.bold,
              size: 24,
            ),
            VSpace.lg,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: TextInputField(
                labelText: 'Enter amount',
                hintText: 'UGX',
                onSaved: (value) {},
              ),
            ),
            VSpace.md,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'You currently have '),
                    TextSpan(
                      text: 'UGX56,789',
                      style: TextStyles.h3,
                    ),
                    TextSpan(text: ' on your Tumia pesa  Visa card'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyles.caption,
              ),
            ),
            VSpace(46),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: PElevatedbtn(
                'Withdraw',
                onTap: () async {
                  Navigator.push(
                    context,
                    PageRouter.fadeScale(
                      () => TransactionSuccessPage(
                        title: 'Kudos!',
                        body:
                            "You've withdrawn UGX500 to your Tumia pesa Wallet",
                      ),
                    ),
                  );
                },
              ),
            ),
            VSpace.lg
          ],
        ),
      ),
    );
  }
}
