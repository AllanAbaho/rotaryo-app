// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:tumiapesa/utils/apis.dart';
import 'package:intl/intl.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/mobilemoney/recipient_details.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class MobileMoneyPage extends StatefulWidget {
  final Function next;
  String custName, custNumber;
  MobileMoneyPage({this.next, this.custName, this.custNumber});

  @override
  _MobileMoneyPageState createState() => _MobileMoneyPageState();
}

class _MobileMoneyPageState extends State<MobileMoneyPage> {
  int selectedId = 0;
  String version;
  final _formPhoneKey = GlobalKey<FormState>();
  String phone, paymentNetwork;
  TextEditingController _phoneNumberController = TextEditingController();
  bool ignoreTaps = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.custNumber != null) {
      _phoneNumberController.value = TextEditingValue(text: widget.custNumber);
    }
    PackageInfo.fromPlatform().then((value) {
      version = '${value.version}+${value.buildNumber}';
    });
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
              key: _formPhoneKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                  child: Column(
                    children: [
                      VSpace.lg,
                      MediumText("We're almost there!", size: FontSizes.s20),
                      VSpace.lg,
                      VSpace.sm,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SmallText('Supported Networks'),
                      ),
                      VSpace.md,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: paymentMethods
                            .map(
                              (e) => PaymentMethodItem(
                                method: e,
                                // selected: e.id == selectedId,
                                // onSelect: (id) => setState(() {
                                //   selectedId = id;
                                // }),
                              ),
                            )
                            .toList(),
                      ),
                      VSpace.lg,
                      GestureDetector(
                        onTap: () {
                          var contactNumber = openContactBook();
                          contactNumber.then((value) {
                            setState(() {
                              _phoneNumberController.value =
                                  TextEditingValue(text: value);
                            });
                          });
                        },
                        child: Row(
                          children: [
                            LocalImage(
                              AppImages.phoneIcon,
                              height: 36,
                            ),
                            HSpace.md,
                            Expanded(
                              child: SmallText('Select from Contact List'),
                            ),
                          ],
                        ),
                      ),
                      VSpace.lg,
                      Row(
                        children: [
                          Expanded(
                            child: TextInputField(
                              labelText: 'Enter recipent phone number',
                              controller: _phoneNumberController,
                              onSaved: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the recipient phone number';
                                }
                                if (!validatePhone(value)) {
                                  return 'Invalid phone number';
                                }

                                return null;
                              },
                            ),
                          ),
                          HSpace.md,
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formPhoneKey.currentState.validate()) {
                                  setState(() {
                                    _formPhoneKey.currentState.save();
                                  });

                                  _validatePhoneNumber(
                                    _phoneNumberController.text,
                                    context,
                                  );
                                }
                              },
                              // onPressed: () => widget.next == null
                              //     ? Navigator.push(
                              //         context,
                              //         PageRouter.fadeScale(
                              //           () => MobileMoneyRecipientPage(),
                              //         ),
                              //       )
                              //     : widget.next(),
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

  bool validatePhone(String text) {
    return RegExp(r"^\+?\d*$").hasMatch(text);
  }

  _validatePhoneNumber(String phone, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    setState(() {
      ignoreTaps = true;
    });
    progress.showWithText('Validating Phone Number...');
    phone = _phoneNumberController.text;
    if (phone.startsWith('+')) {
      phone = phone.replaceAll('+', '');
    }
    if (phone.startsWith('0')) {
      phone = phone.replaceFirst('0', '256');
    }
    if (phone.startsWith('25670') ||
        phone.startsWith('25675') ||
        phone.startsWith('25674')) {
      paymentNetwork = 'AIRTEL';
    } else {
      paymentNetwork = 'MTN';
    }
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'accountNumber': phone,
      'accountType': 'MOMO',
      'password': 'OIZWVA6QI7',
      'appVersion': version,
      'checkoutMode': 'TUMIAWALLET',
      'addendum3': 'SEND MONEY',
      'vendorCode': 'TUMIA_APP',
      'telecom': paymentNetwork,
    };
    String auth = stringToBase64.encode('admin:secret123');

    try {
      final response = await http.post(
        Uri.parse(validatePhoneNumber),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['statusCode'];
        if (responseStatus == '200') {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });
          _showDialog(phone, responseResult['accountName'].toString());
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });
          // ignore: use_build_context_synchronously
          buildDialog(
              _formPhoneKey.currentContext, 'Invalid Phone Number Supplied');
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(_formPhoneKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(_formPhoneKey.currentContext,
          'Failed to Connect to Server, Check your internet connection');
    }
  }

  Future<String> openContactBook() async {
    Contact contact = await ContactPicker().selectContact();
    if (contact != null) {
      var phoneNumber = contact.phoneNumber.number
          .toString()
          .replaceAll(new RegExp(r"\s+"), "");
      return phoneNumber;
    }
    return "";
  }

  _showDialog(String phone, String accountName) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Phone Number Verification',
                style: TextStyle(
                  color: Color.fromRGBO(223, 32, 48, 1),
                  fontSize: 16,
                ),
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
                          'Confirm Recipient details: Phone number ${phone} registered in the name: ${accountName}',
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
                              final int paymentMode = value.id;
                              if (value.id == 1) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  PageRouter.fadeScale(
                                    () => MobileMoneyRecipientPage(
                                      phone,
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
                                    () => MobileMoneyRecipientPage(
                                      phone,
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
                                          () => MobileMoneyRecipientPage(
                                            _phoneNumberController.text,
                                            accountName,
                                            paymentMode,
                                          ),
                                        ),
                                      );
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
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
        ),
        child: SmallText(
          'Okay',
        ),
      ),
      animationLoop: true,
      contentText: dialogMessage,
    ).show();
  }
}

class PaymentMethodItem extends StatelessWidget {
  final MMPaymentMethod method;
  PaymentMethodItem({
    this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: method.id == 0 ? Colors.yellow : AppColors.primaryColor,
        ),
      ),
      child: LocalImage(
        method.imgUrl,
        height: 36,
      ),
    );
    // .onTap(() => onSelect(method.id));
  }
}

final paymentMethods = [
  MMPaymentMethod(id: 0, imgUrl: AppImages.mtn),
  MMPaymentMethod(id: 1, imgUrl: AppImages.airtel),
];

class MMPaymentMethod {
  int id;
  String imgUrl;
  MMPaymentMethod({this.id, this.imgUrl});
}
