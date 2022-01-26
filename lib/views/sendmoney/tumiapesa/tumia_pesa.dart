// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/sendmoney/tumiapesa/recipient_details.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class TumiaPesaPage extends StatefulWidget {
  String custName, custNumber;

  TumiaPesaPage({this.custName, this.custNumber});
  @override
  _TumiaPesaPageState createState() => _TumiaPesaPageState();
}

class _TumiaPesaPageState extends State<TumiaPesaPage> {
  final _formTumiaKey = GlobalKey<FormState>();
  Timer timer;
  bool ignoreTaps = false;

  TextEditingController _tumiaAccountNumber = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.custNumber != null) {
      _tumiaAccountNumber.value = TextEditingValue(text: widget.custNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context),
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Form(
              key: _formTumiaKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                  child: Column(
                    children: [
                      MediumText("We're almost there!", size: FontSizes.s20),
                      SmallText(
                        "Confirm recipent",
                        size: FontSizes.s14,
                        align: TextAlign.center,
                      ),
                      VSpace.lg,
                      Row(
                        children: [
                          Expanded(
                            child: TextInputField(
                              controller: _tumiaAccountNumber,
                              labelText: 'Enter TUMIA PESA account number',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the Tumia Account Number';
                                }
                                if (!validateSpecialCharacters(value)) {
                                  return 'Please remove space or special characters';
                                }

                                return null;
                              },
                              onSaved: (value) {},
                            ),
                          ),
                          HSpace.md,
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formTumiaKey.currentState.validate()) {
                                  setState(() {
                                    _formTumiaKey.currentState.save();
                                  });
                                  _verifyAccount();
                                }
                              },
                              child: MediumText('Verify'),
                            ),
                          )
                        ],
                      ),
                      VSpace.lg
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool validateSpecialCharacters(String text) {
    return RegExp(r"^(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(text);
  }

  _verifyAccount() async {
    final progress = ProgressHUD.of(_formTumiaKey.currentContext);
    progress.showWithText('Validating Tumia Account...');
    setState(() {
      ignoreTaps = true;
    });

    Map data = {'username': _tumiaAccountNumber.text};

    try {
      final response =
          await http.post(Uri.parse('${citrusBridgeApi}queryAccountDetails'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(data));
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['status'];
        if (responseStatus == 'SUCCESS') {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          _showDialog(_tumiaAccountNumber.text,
              responseResult['name'].toString().toUpperCase());
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(_formTumiaKey.currentContext,
              responseResult['message'].toString());
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(_formTumiaKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(_formTumiaKey.currentContext,
          'Failed to Connect to Server, Check your internet connection');
    }
  }

  _showDialog(String accountNumber, String accountName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tumia Account Verification',
                style: TextStyle(
                    color: Color.fromRGBO(223, 32, 48, 1), fontSize: 16),
              ),
              Divider(
                color: Color.fromRGBO(223, 32, 48, 1),
              ),
              Column(
                children: [
                  Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Flexible(
                        child: Text(
                          'Confirm Recipient details: Account Number ${accountNumber} registered in the name: $accountName',
                          style: TextStyle(fontSize: 13),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.black,
                        ),
                        GestureDetector(
                          onTap: () {
                            final paymentMethod = Navigator.push<PaymentMethod>(
                              context,
                              PageRouter.fadeThrough(
                                () => SelectPaymentMethodPage(),
                              ),
                            );

                            paymentMethod.then((value) {
                              int paymentMode = value.id;
                              if (value.id == 1) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  PageRouter.fadeScale(
                                    () => TumiaPesaRecipientPage(
                                      accountNumber,
                                      accountName,
                                      paymentMode,
                                    ),
                                  ),
                                );
                              } else if (value.id == 2) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  PageRouter.fadeScale(
                                    () => TumiaPesaRecipientPage(
                                      accountNumber,
                                      accountName,
                                      paymentMode,
                                    ),
                                  ),
                                );
                              } else {
                                final pinValid = Navigator.push<bool>(
                                  context,
                                  PageRouter.fadeThrough(
                                    () => PinPage(),
                                  ),
                                );
                                pinValid.then(
                                  (value) {
                                    if (value) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        PageRouter.fadeScale(
                                          () => TumiaPesaRecipientPage(
                                            accountNumber,
                                            accountName,
                                            paymentMode,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              }
                            });
                          },
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(
                                  223,
                                  32,
                                  48,
                                  1,
                                ),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildDialog(BuildContext context, String dialogMessage) {
    return StylishDialog(
      context: context,
      alertType: StylishDialogType.ERROR,
      titleText: 'Sorry',
      dismissOnTouchOutside: false,
      confirmButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: SmallText(
          'Okay',
        ),
      ),
      animationLoop: true,
      contentText: dialogMessage,
    ).show();
  }
}
