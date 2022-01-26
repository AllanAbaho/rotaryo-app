import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/text.dart';

enum Pin2State { otp, authentication }

class Pin2Page extends StatefulWidget {
  final Pin2State state;
  Pin2Page({this.state = Pin2State.authentication});

  @override
  _Pin2PageState createState() => _Pin2PageState();
}

class _Pin2PageState extends State<Pin2Page> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Scaffold(
        appBar: customAppbar(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              VSpace.lg,
              MediumText(
               "Just a little bit more"
              ),
              VSpace.lg,
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
                child: Align(
                  child: SmallText(
                   'Confirm with 4-Digit pin'
                  ),
                ),
              ),
              VSpace.sm,
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg + 24),
                child: PinInputField(),
              ),
              VSpace.md,
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
                child: Align(
                  child: Text('Forgot PIN?')
                ),
              ),
              VSpace.sm,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                child: PElevatedbtn(
                  state == Pin2State.otp ? 'Next' : 'Confirm',
                  onTap: () {
              //  Navigator.push(
              //             context,
              //             PageRouter.fadeScale(
              //               () => TransactionSuccessPage(
              //                 body:
              //                     "You've successfully added fund to you TUMIA PESA WALLET",
              //                 templateId: 2,
              //                 showStatement: false,
              //                 btnText: 'OK',
              //               ),
              //             ),
              //           );
                  },
                  
                      // return true if pin is valid

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
