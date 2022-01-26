import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class WithdrawToBank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Withdraw'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SmallText('Withdraw to your'),
            MediumText(
              "Bank Account",
              fontWeight: FontW.bold,
              size: 24,
            ),
            VSpace.md,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: TextInputField(
                labelText: 'Enter amount',
                hintText: 'NGN',
                onSaved: (value) {},
              ),
            ),
            VSpace.md,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: TextInputField(
                labelText: 'Select Bank',
                hintText: 'Access Bank Plc',
                onSaved: (value) {},
              ),
            ),
            VSpace.md,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: TextInputField(
                labelText: 'Account Number',
                onSaved: (value) {},
              ),
            ),
            VSpace.md,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: TextInputField(
                labelText: 'Account Name',
                onSaved: (value) {},
              ),
            ),
            VSpace(46),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: PElevatedbtn(
                'Withdraw',
                onTap: () async {
                  final pinValid = await Navigator.push<bool>(
                      context, PageRouter.fadeScale(() => PinPage()));
                  if (pinValid) {
                    //   do stuff
                  }
                  Navigator.push(
                    context,
                    PageRouter.fadeScale(
                      () => TransactionSuccessPage(
                        title: 'Well done',
                        body:
                            'You’ve successfully cashout out N500 to ***2308 Access bank Plc',
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
