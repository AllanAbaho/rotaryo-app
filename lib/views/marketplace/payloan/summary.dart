import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/beneficiaries/beneficiaries.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/sendmoney/sendmoney.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class LoanSummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
          child: Column(
            children: [
              VSpace.xs,
              MediumText("Summary", size: FontSizes.s20),
              VSpace.xs,
              SmallText(
                "Summary of your payment",
                size: FontSizes.s14,
                align: TextAlign.center,
              ),
              VSpace.md,
              Center(
                child: LocalImage(
                  AppImages.logo,
                  height: 44,
                ),
              ),
              VSpace.lg,
              Container(
                padding: EdgeInsets.all(Insets.lg - 8),
                decoration: BoxDecoration(
                    borderRadius: Corners.lgBorder, color: Color(0xAAFAFAFA)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReceiptItem('Name', 'EDWARD PETERS'),
                    ReceiptItem('Payment type', 'TAX'),
                    ReceiptItem('Number Plate', '8747897497'),
                    ReceiptItem('Loan Amount', 'UGX54,894'),
                  ],
                ),
              ),
              VSpace.sm,
              SmallText('Click next to proceed'),
              VSpace.lg,
              // PElevatedbtn(
              //   'Next',
              //   onTap: () async {
              //     final paymentMethod = await Navigator.push<PaymentMethod>(
              //       context,
              //       PageRouter.fadeScale(
              //         () => SelectPaymentMethodPage(),
              //       ),
              //     );
              //     if (paymentMethod != null) {
              //       final pinValid = await Navigator.push<bool>(
              //         context,
              //         PageRouter.fadeScale(
              //           () => PinPage(),
              //         ),
              //       );
              //       if (pinValid == true) {
              //         // do stuff
              //       }
              //       Navigator.push(
              //         context,
              //         PageRouter.fadeScale(
              //           () => TransactionSuccessPage(
              //             body:
              //                 "You will receive a text message from Boda Boda with payment details",
              //             templateId: 3,
              //           ),
              //         ),
              //       );
              //     }
              //   },
              // ),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                        onPressed: () {},
                        child: MediumText('Add')),
                  ),
                ),
                HSpace.md,
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
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
                        ),
                      child: MediumText('Next'),
                    ),
                  ),
                ),
              ],
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
    );
  }
}

class ReceiptItem extends StatelessWidget {
  final String k, v;
  ReceiptItem(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(k),
          MediumText(
            v,
            fontWeight: FontW.bold,
          ),
        ],
      ),
    );
  }
}
