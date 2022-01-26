import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';
import 'package:tumiapesa/utils/extension.dart';

class AddFromWalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            SmallText(
              'Available Wallet balance',
              color: Colors.black,
            ),
            MediumText(
              "UGX34,547",
              size: FontSizes.s16,
              color: Colors.black,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Icon(
          PhosphorIcons.caretLeftLight,
          color: Colors.black,
        ).onTap(() => Navigator.maybePop(context)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VSpace.lg,
            SmallText('Add Funds from your'),
            MediumText(
              "Tumia Pesa wallet",
              fontWeight: FontW.bold,
              size: FontSizes.s20,
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
            VSpace(46),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: PElevatedbtn(
                'Add Cash',
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
            ),
            VSpace.lg
          ],
        ),
      ),
    );
  }
}
