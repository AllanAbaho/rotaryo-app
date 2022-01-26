import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/web_view.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class TumiaPesaRecipientPage extends StatefulWidget {
  String accountNumber, accountName;
  int paymentMode;
  @override
  _TumiaPesaRecipientPageState createState() => _TumiaPesaRecipientPageState();

  TumiaPesaRecipientPage(
      this.accountNumber, this.accountName, this.paymentMode);
}

class _TumiaPesaRecipientPageState extends State<TumiaPesaRecipientPage> {
  String senderPhone,
      recipientPhone,
      paymentNetwork,
      reference,
      bulkReference,
      pivotReference,
      version,
      senderAccount,
      pivotReferenceBulk;

  String currencyCode, convertedAmount = '';

  Timer timer;
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  final _formWalletKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _translatedAmountController = TextEditingController();
  bool ignoreTaps = false;
  var format = NumberFormat("###,###", "en_US");
  bool isCard = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.value = TextEditingValue(text: widget.accountName);
    _getCurrency().then((value) {
      currencyCode = value;
      _currencyController.value = TextEditingValue(text: value);
      _translatedAmountController.value =
          TextEditingValue(text: '$currencyCode : ');
    });
    PackageInfo.fromPlatform().then((value) {
      version = '${value.version}+${value.buildNumber}';
    });
    _emailController.value = TextEditingValue(text: 'support@pivotpayts.com');

    if (widget.paymentMode == 1) {
      isCard = true;
      _amountController.addListener(() {
        _convertTextCurrency(_amountController.text, _currencyController.text);
      });
      _currencyController.addListener(() {
        _convertTextCurrency(_amountController.text, _currencyController.text);
      });
    }
  }

  Future<String> _getCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currencyCode');
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
              key: _formWalletKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                  child: Column(
                    children: [
                      MediumText("We're almost there!", size: FontSizes.s20),
                      SmallText(
                        "Fill in details",
                        size: FontSizes.s14,
                        align: TextAlign.center,
                      ),
                      Visibility(visible: false, child: VSpace.md),
                      Visibility(
                        visible: false,
                        child: TextInputField(
                          labelText: 'Enter recipient phone number',
                          onSaved: (value) {},
                          controller: _phoneNumberController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the recipient Phone Number';
                            }
                            return null;
                          },
                        ),
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Enter recipient Name',
                        onSaved: (value) {},
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the recipient Name';
                          }
                          return null;
                        },
                      ),
                      Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            TextInputField(
                              labelText: 'Enter your email address',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the your Email Address';
                                }
                                return null;
                              },
                              controller: _emailController,
                              onSaved: (value) {},
                            ),
                          ],
                        ),
                      ),
                      Visibility(visible: isCard, child: VSpace.md),
                      Visibility(
                        visible: isCard,
                        child: TextInputField(
                          labelText: 'Select currency',
                          hintText: 'UGX',
                          controller: _currencyController,
                          onTap: () {
                            showCurrencyPicker(
                              context: context,
                              showFlag: true,
                              showCurrencyName: true,
                              showCurrencyCode: true,
                              onSelect: (Currency currency) {
                                setState(() {
                                  currencyCode = currency.code;
                                  _currencyController.value =
                                      TextEditingValue(text: currencyCode);
                                });
                              },
                            );
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the currency';
                            }
                            return null;
                          },
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'You are sending',
                        controller: _amountController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the amount';
                          }
                          return null;
                        },
                        helperText: '*Enter the Amount',
                        onSaved: (value) {},
                      ),
                      Visibility(visible: isCard, child: VSpace.md),
                      Visibility(
                        visible: isCard,
                        child: TextInputField(
                          labelText: 'They will receive',
                          readOnly: true,
                          controller: _translatedAmountController,
                          onTap: () {},
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.lg,
                      PElevatedbtn(
                        'Next',
                        onTap: () {
                          if (_formWalletKey.currentState.validate()) {
                            setState(() {
                              _formWalletKey.currentState.save();
                            });

                            switch (widget.paymentMode) {
                              case 1:
                                _logTransaction(_formWalletKey.currentContext,
                                    widget.paymentMode);
                                break;
                              default:
                                _logTransaction(_formWalletKey.currentContext,
                                    widget.paymentMode);
                                break;
                            }
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Insets.lg, vertical: 10),
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
            ),
          ),
        ),
      ),
    );
  }

  _logTransaction(BuildContext context, int paymentMode) async {
    final progress = ProgressHUD.of(context);
    progress.showWithText('Logging Transaction...');
    setState(() {
      ignoreTaps = true;
    });
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    String sendMethod = "";
    reference = DateTime.now().millisecondsSinceEpoch.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    senderAccount = prefs.getString('accountNumber');
    recipientPhone = prefs.getString('phoneNumber');
    if (recipientPhone.startsWith('+')) {
      recipientPhone = recipientPhone.replaceAll('+', '');
    }
    if (recipientPhone.startsWith('0')) {
      recipientPhone = recipientPhone.replaceFirst('0', '256');
    }
    _phoneNumberController.value = TextEditingValue(text: recipientPhone);
    senderPhone = prefs.getString('phoneNumber');
    if (senderPhone.startsWith('+')) {
      senderPhone = senderPhone.replaceAll('+', '');
    }
    if (senderPhone.startsWith('0')) {
      senderPhone = senderPhone.replaceFirst('0', '256');
    }
    if (senderPhone.startsWith('25670') ||
        senderPhone.startsWith('25675') ||
        senderPhone.startsWith('25674')) {
      paymentNetwork = 'AIRTEL';
    } else {
      paymentNetwork = 'MTN';
    }
    reference = reference + prefs.getString('userName').toUpperCase();

    switch (paymentMode) {
      case 0:
        paymentNetwork = 'TUMIA WALLET';
        sendMethod = 'WALLET';
        break;
      case 1:
        paymentNetwork = 'CARD PAYMENT';
        sendMethod = 'CARD';
        break;
      case 2:
        sendMethod = 'MOBILE MONEY';
        break;
    }
    Map data = {
      'phone': senderPhone,
      'amount': _amountController.text,
      'channel': 'RETAIL_APP',
      'service': 'SEND WALLET',
      'payment_method': sendMethod,
      'payee': widget.accountNumber,
      'username': prefs.getString('userName'),
      'customer_name': _fullNameController.text,
      'service_provider': paymentNetwork,
      'app_version': version,
      'reference': reference,
      'narration': _fullNameController.text
//          'TUMIA PESA : You have sent UGX. ${_amountController.text} to ${_fullNameController.text} trans Ref. $reference on $formatted via $paymentNetwork payments.',
    };
    try {
      final response = await http
          .post(Uri.parse('${tumiaApi}log_transaction.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          switch (paymentMode) {
            case 2:
              // ignore: use_build_context_synchronously
              _topUpCollection(formatted, paymentNetwork, context);
              break;
            case 1:
              timer = Timer.periodic(
                Duration(seconds: 5),
                (Timer t) => _checkStatusCard(t, reference),
              );
              // ignore: use_build_context_synchronously
              Navigator.push(
                _formWalletKey.currentContext,
                PageRouter.fadeScale(
                  () => CardPayment(
                    '$cardPayment$reference&customerReference=${_phoneNumberController.text}&itempaidfor=SENDMONEY&tranamount=${_amountController.text}&usercurrency=${_currencyController.text}&phoneNumber=${_phoneNumberController.text}&email=support@pivotpayts.com&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https%3A%2F%2Fpivotpayts.com%2Ftestreturn.php',
                  ),
                ),
              );
              break;
            case 0:
              _logResponseWallet(
                senderAccount,
                reference,
                widget.accountNumber,
                'SUCCESS',
              );
              break;
          }
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
            _formWalletKey.currentContext,
            responseResult['message'].toString(),
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(_formWalletKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(_formWalletKey.currentContext,
          'Failed to Connect to Server, Check your internet connection');
    }
  }

  _checkStatusCard(Timer t, String vendorTranId) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'vendorTranId': vendorTranId,
      'vendorCode': vendorCode,
      'password': vendorPassword,
    };
    try {
      String auth = stringToBase64.encode('admin:secret123');
      final response = await http.post(
        Uri.parse(paymentStatus),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['tran_status'];
        if (responseStatus == 'SUCCESS') {
          t.cancel();
          _logResponse(
              responseResult['tran_status'].toString(),
              responseResult['pivot_ref'].toString(),
              responseResult['telecom_id'].toString(),
              reference,
              widget.accountNumber);
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          buildDialog(_formWalletKey.currentContext,
              responseResult['reason'].toString());
        }
      } else {
        t.cancel();
        buildDialog(_formWalletKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      t.cancel();
      buildDialog(_formWalletKey.currentContext,
          'Failed to Connect to Server, Check your internet connection');
    }
  }

  _convertTextCurrency(String amountValue, String currencyCode) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'baseAmount': amountValue,
      'fromCurrency': currencyCode,
      'toCurrency': 'UGX',
      'vendorCode': 'TUMIA_APP',
    };
    String auth = stringToBase64.encode('admin:secret123');
    try {
      final response = await http.post(
        Uri.parse(currencyConversion),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['convertedAmount'];
        if (responseStatus != null) {
          _translatedAmountController.value = TextEditingValue(
              text:
                  'UGX : ${format.format(double.parse(responseResult['convertedAmount'].toString()).round()).toString()}');
          String currencyAmount = responseResult['convertedAmount'].toString();
          double doubleAmount = double.parse(currencyAmount);
          int intAmount = doubleAmount.round();
          convertedAmount = intAmount.toString();
        } else {
          if (amountValue.isNotEmpty) {
            buildDialog(
              _formWalletKey.currentContext,
              'Currency $currencyCode is not Supported',
            );
          } else {
            _translatedAmountController.value =
                TextEditingValue(text: '$currencyCode : ');
          }
        }
      } else {
        buildDialog(_formWalletKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      StylishDialog(
        context: _formWalletKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formWalletKey.currentContext);
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
          ),
          child: SmallText(
            'Okay',
          ),
        ),
        animationLoop: true,
        contentText:
            'Failed to Connect to Server, Check your internet connection',
      ).show();
    }
  }

  _topUpCollection(String _date, String telecom, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    progress.showWithText('Initiating Collection Request..');
    setState(() {
      ignoreTaps = true;
    });

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'accountNumber': senderPhone,
      'tranAmount': _amountController.text,
      'accountType': 'MOMO',
      'tranType': 'COLLECTION',
      'currency': 'UGX',
      'country': 'UG',
      'accountName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'addendum1': 'COLLECTION',
      'addendum2': 'COLLECTION',
      'addendum3': 'SEND MONEY',
      'paymentDate': _date,
      'password': 'EVJ7O9V6Q6',
      'tranSignature': 'testSignature',
      'vendorCode': 'TUMIA_APP',
      'telecom': telecom,
      'commonReference': reference,
      'vendorTranId': reference,
      'tranNarration': _fullNameController.text,
    };
    try {
      String auth = stringToBase64.encode('admin:secret123');
      final response = await http.post(
        Uri.parse(payments),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['statusCode'];
        if (responseStatus == 'PENDING') {
          pivotReference = responseResult['tranReference'].toString();
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          timer = Timer.periodic(
            Duration(seconds: 5),
            (Timer t) => _checkStatus(t, reference, pivotReference),
          );
          _collectionPromptDialog(senderPhone);
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
              _formWalletKey.currentContext, "${responseResult['statusDesc']}");
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(_formWalletKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      buildDialog(_formWalletKey.currentContext,
          'Failed to Connect to Server, Please check your internet connection.');
    }
  }

  _collectionPromptDialog(String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pin Prompt Sent',
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
                          'Please enter your mobile money pin for a collection prompt sent to the phone number $phone to complete the transaction. DO NOT CLOSE THE APP BEFORE YOU ARE NOTIFIED OF TRANSACTION STATUS.',
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
                      Navigator.push(
                        context,
                        PageRouter.fadeScale(() => HomePage()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  _checkStatus(Timer t, String vendorTranId, String tranReference) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'vendorTranId': vendorTranId,
      'tranReference': tranReference,
      'vendorCode': vendorCode,
      'password': vendorPassword,
    };
    try {
      String auth = stringToBase64.encode('admin:secret123');
      final response = await http.post(
        Uri.parse(paymentStatus),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['tran_status'];
        if (responseStatus == 'SUCCESS') {
          t.cancel();
          _logResponse(
              responseResult['tran_status'].toString(),
              responseResult['pivot_ref'].toString(),
              responseResult['telecom_id'].toString(),
              reference,
              widget.accountNumber);
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          buildDialog(
              _formWalletKey.currentContext, "${responseResult['reason']}");
        }
      } else {
        t.cancel();
        buildDialog(_formWalletKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      buildDialog(_formWalletKey.currentContext,
          'Failed to Connect to Server, Please check your internet Connection');
    }
  }

  _logResponse(
    String tranMessage,
    String pivotReference,
    String telecomId,
    String reference,
    String accountNumber,
  ) async {
    Map data = {
      'reference': reference,
      'pivot_ref': pivotReference,
      'telecom_ref': telecomId,
      'accountNumber': accountNumber,
      'response_message': tranMessage,
      'credit': "true",
    };

    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            PageRouter.fadeScale(
              () => TransactionSuccessPage(
                body:
                    "You've successfully transferred UGX. ${_amountController.text} to ${_fullNameController.text}",
                templateId: 2,
              ),
            ),
          );
        } else {
          buildDialog(
              _formWalletKey.currentContext, "${responseResult['message']}");
        }
      } else {
        buildDialog(_formWalletKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      buildDialog(_formWalletKey.currentContext,
          'Failed to Connect to Server, Please check your internet Connection');
    }
  }

  _logResponseWallet(
    String senderAccount,
    String reference,
    String accountNumber,
    String tranMessage,
  ) async {
    Map data = {
      'reference': reference,
      'accountNumber': accountNumber,
      'response_message': tranMessage,
      'senderAccount': senderAccount,
      'credit': "true",
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          _updateBalance(responseResult['accountBalance'].toString());
        } else {
          buildDialog(
              _formWalletKey.currentContext, "${responseResult['message']}");
        }
      } else {
        buildDialog(_formWalletKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      buildDialog(_formWalletKey.currentContext,
          'Failed to Connect to Server, Please check your internet connection');
    }
  }

  _updateBalance(String balance) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
      'accountBalance',
      balance,
    );
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      PageRouter.fadeScale(
        () => TransactionSuccessPage(
          body:
              "You've successfully transferred UGX. ${_amountController.text} to ${_fullNameController.text}",
          templateId: 2,
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

class ReceiptItem extends StatelessWidget {
  final String k, v;
  ReceiptItem(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.xs),
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
