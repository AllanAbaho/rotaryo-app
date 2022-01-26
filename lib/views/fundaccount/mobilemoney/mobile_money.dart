import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/web_view.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class FundMobileMoneyRecieptPage extends StatefulWidget {
  int paymentMode;

  FundMobileMoneyRecieptPage(this.paymentMode);

  @override
  State<FundMobileMoneyRecieptPage> createState() =>
      _FundMobileMoneyRecieptPageState();
}

class _FundMobileMoneyRecieptPageState
    extends State<FundMobileMoneyRecieptPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _formFundKey = GlobalKey<FormState>();
  var format = NumberFormat("###,###", "en_US");
  String helperText = '';
  String phone, paymentNetwork, reference, pivotReference;
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _translatedAmountController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String currencyCode, version, fundMethod;
  String convertedAmount = '';
  bool ignoreTaps = false;
  bool isCard = false;

  @override
  void initState() {
    super.initState();
    getUserCurrency().then((value) {
      currencyCode = value.split('|').elementAt(0);
      _currencyController.value = TextEditingValue(text: currencyCode);
      _emailController.value = TextEditingValue(text: 'support@pivotpayts.com');
      _translatedAmountController.value =
          TextEditingValue(text: '$currencyCode : ');
      _phoneNumberController.value =
          TextEditingValue(text: value.split('|').elementAt(1));
      _translatedAmountController.value = TextEditingValue(text: 'UGX : ');
    });

    if (widget.paymentMode == 1) {
      isCard = true;
      _amountController.addListener(() {
        if (!validateInternationalAmount(_amountController.text) &&
            _amountController.text.isNotEmpty) {
          setState(() {
            helperText = 'Amount should only contain digits or decimal point';
          });
        } else {
          setState(() {
            helperText = '';
          });
        }
        _convertTextCurrency(_amountController.text);
      });
      // _amountController.addListener(() {
      //   if (validateInternationalAmount(_amountController.text)) {
      //     _convertTextCurrency(_amountController.text);
      //   }
      // });
    }
    PackageInfo.fromPlatform().then((value) {
      version = '${value.version}+${value.buildNumber}';
    });
  }

  Future<String> getUserCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String values =
        '${prefs.getString('currencyCode')}|${prefs.getString('phoneNumber')}';
    return values;
  }

  Timer timer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context),
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => SingleChildScrollView(
              child: Form(
                key: _formFundKey,
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
                      Visibility(visible: isCard, child: VSpace.md),
                      Visibility(
                        visible: !isCard,
                        child: TextInputField(
                          labelText: 'Enter phone number',
                          controller: _phoneNumberController,
                          onSaved: (value) {},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Phone Number';
                            }
                            if (!validatePhoneNumber(value)) {
                              return 'Phone number is not valid (no spaces allowed)';
                            }
                            return null;
                          },
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            TextInputField(
                              labelText: 'Enter Email Address',
                              controller: _emailController,
                              onSaved: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Email Address';
                                }
                                if (!validateUserEmail(value)) {
                                  return 'Email Address is invalid';
                                }
                                return null;
                              },
                            ),
                            VSpace.md,
                          ],
                        ),
                      ),
                      Visibility(visible: isCard, child: VSpace.md),
                      Visibility(
                        visible: isCard,
                        child: TextInputField(
                          labelText: 'Select Currency',
                          controller: _currencyController,
                          onSaved: (value) {},
                          readOnly: true,
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
                        ),
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Enter Amount',
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {},
                        helperText: helperText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the amount';
                          }
                          if (!isCard) {
                            if (!validateAmount(value)) {
                              return 'Amount should only contain digits';
                            }
                          } else {
                            validateInternationalAmount(value);
                          }
                          return null;
                        },
                      ),
                      // Visibility(visible: isCard, child: VSpace.md),
                      Visibility(
                        visible: isCard,
                        child: TextInputField(
                          labelText: 'Your Wallet will Receive',
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          controller: _translatedAmountController,
                          onTap: () {},
                          onSaved: (value) {},
                        ),
                      ),
                      VSpace.lg,
                      PElevatedbtn(
                        'Next',
                        onTap: () {
                          if (_formFundKey.currentState.validate()) {
                            setState(() {
                              _formFundKey.currentState.save();
                              //_main();
                            });
                            switch (widget.paymentMode) {
                              case 0:
                                _logTransaction();
                                break;
                              case 1:
                                if (convertedAmount.isNotEmpty) {
                                  _logTransaction();
                                }
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

  bool validatePhoneNumber(String text) {
    return RegExp(r"^\+?\d*$").hasMatch(text);
  }

  _logTransaction() async {
    final progress = ProgressHUD.of(_formFundKey.currentContext);
    progress.showWithText('Logging Transaction..');
    setState(() {
      ignoreTaps = true;
    });

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    reference = DateTime.now().millisecondsSinceEpoch.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    switch (widget.paymentMode) {
      case 1:
        paymentNetwork = 'CARD PAYMENT';
        fundMethod = 'CARD';
        break;
      default:
        fundMethod = 'MOBILE MONEY';
        break;
    }
    reference = reference + prefs.getString('userName').toUpperCase();
    String amount;
    convertedAmount.isEmpty
        ? amount = _amountController.text
        : amount = convertedAmount;

    Map data = {
      'phone': _phoneNumberController.text,
      'amount': amount,
      'channel': 'RETAIL_APP',
      'service': 'FUND WALLET',
      'payment_method': fundMethod,
      'payee': prefs.getString('accountNumber'),
      'username': prefs.getString('userName'),
      'customer_name':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'service_provider': paymentNetwork,
      'app_version': version,
      'reference': reference,
      'narration': 'Fund Account',
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
          switch (widget.paymentMode) {
            case 0:
              _topUpCollection(phone, formatted, paymentNetwork,
                  _formFundKey.currentContext);
              break;
            case 1:
              timer = Timer.periodic(
                Duration(seconds: 5),
                (Timer t) => _checkStatusCard(t, reference),
              );
              // ignore: use_build_context_synchronously
              Navigator.push(
                _formFundKey.currentContext,
                PageRouter.fadeScale(
                  () => CardPayment(
                    '$cardPayment$reference&customerReference=${_phoneNumberController.text}&itempaidfor=FUNDWALLET&tranamount=${_amountController.text}&usercurrency=${_currencyController.text}&phoneNumber=${_phoneNumberController.text}&email=${_emailController.text}&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https%3A%2F%2Fpivotpayts.com%2Ftestreturn.php',
                  ),
                ),
              );
              break;
          }
        } else {
          buildDialog(
              _formFundKey.currentContext, '${responseResult['message']}');
        }
      } else {
        buildDialog(_formFundKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      progress.dismiss();
      StylishDialog(
        context: _formFundKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formFundKey.currentContext);
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

  _topUpCollection(
      String _phone, String _date, String telecom, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    setState(() {
      ignoreTaps = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    progress.showWithText('Initiating Collection Request..');
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'accountNumber': _phone,
      'tranAmount': _amountController.text,
      'accountType': 'MOMO',
      'tranType': 'COLLECTION',
      'currency': 'UGX',
      'country': 'UG',
      'collection_method': 'CARD',
      'accountName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'addendum1': 'COLLECTION',
      'addendum2': 'COLLECTION',
      'addendum3': 'FUND WALLET',
      'paymentDate': _date,
      'password': 'EVJ7O9V6Q6',
      'tranSignature': 'testSignature',
      'vendorCode': 'TUMIA_APP',
      'telecom': telecom,
      'commonReference': reference,
      'vendorTranId': reference,
      'tranNarration': 'Fund Wallet',
    };
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
        _collectionPromptDialog(_phone);
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
            _formFundKey.currentContext, '${responseResult['statusDesc']}');
      }
    } else {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      // ignore: use_build_context_synchronously
      buildDialog(_formFundKey.currentContext,
          'Server Error, Response Code ${response.statusCode}');
    }
  }

  _checkStatus(Timer t, String vendorTranId, String tranReference) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'vendorTranId': vendorTranId,
      'tranReference': tranReference,
      'vendorCode': vendorCode,
      'password': vendorPassword,
    };
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
      if (t.tick < 90) {
        if (responseStatus == 'SUCCESS') {
          t.cancel();
          _logResponse(
            responseResult['tran_status'].toString(),
            responseResult['pivot_ref'].toString(),
            responseResult['telecom_id'].toString(),
            reference,
          );
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          buildDialog(
              _formFundKey.currentContext, '${responseResult['reason']}');
        }
      } else {
        t.cancel();
        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0001',
          'Fund Wallet',
          channelDescription: 'Fund Wallet Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await flutterLocalNotificationsPlugin.show(
          randomNumber,
          'Fund Wallet Notification',
          'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
          platformChannelSpecifics,
          payload: 'data',
        );
      }
    } else {
      t.cancel();
      buildDialog(_formFundKey.currentContext,
          'Server Error, Response Code ${response.statusCode}');
    }
  }

  _checkStatusCard(Timer t, String vendorTranId) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'vendorTranId': vendorTranId,
      'vendorCode': vendorCode,
      'password': vendorPassword,
    };
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
      if (t.tick < 90) {
        if (responseStatus == 'SUCCESS') {
          t.cancel();
          _logResponse(
            responseResult['tran_status'].toString(),
            responseResult['pivot_ref'].toString(),
            responseResult['telecom_id'].toString(),
            reference,
          );
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          buildDialog(
              _formFundKey.currentContext, '${responseResult['reason']}');
        }
      } else {
        t.cancel();
        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0001',
          'Fund Wallet',
          channelDescription: 'Fund Wallet Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await flutterLocalNotificationsPlugin.show(
          randomNumber,
          'Fund Wallet Notification',
          'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
          platformChannelSpecifics,
          payload: 'data',
        );
      }
    } else {
      t.cancel();
      buildDialog(_formFundKey.currentContext,
          'Server Error, Response Code ${response.statusCode}');
    }
  }

  _logResponse(
    String tranMessage,
    String pivotReference,
    String telecomId,
    String reference,
  ) async {
    Map data = {
      'reference': reference,
      'pivot_ref': pivotReference,
      'telecom_ref': telecomId,
      'response_message': tranMessage,
      'credit': "true",
    };
    final response =
        await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
    if (response.statusCode == 200) {
      var responseResult = jsonDecode(response.body);
      var responseStatus = responseResult['success'];
      if (responseStatus == true) {
        _updateBalance(responseResult['accountBalance'].toString());
      } else {
        buildDialog(
            _formFundKey.currentContext, '${responseResult['message']}');
      }
    } else {
      buildDialog(_formFundKey.currentContext,
          'Server Error, Response Code ${response.statusCode}');
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
      _formFundKey.currentContext,
      PageRouter.fadeScale(
        () => TransactionSuccessPage(
          body:
              "You have successfully added UGX. ${_amountController.text} to your TUMIA PESA WALLET. Your balance is UGX. ${balance}",
          templateId: 2,
          showStatement: false,
          btnText: 'OK',
        ),
      ),
    );
  }

  bool validateAmount(String text) {
    return RegExp(r"^[0-9]*$").hasMatch(text);
  }

  bool validateInternationalAmount(String text) {
    return RegExp(r"^\d*\.?\d*$").hasMatch(text);
  }

  _collectionPromptDialog(String phone) {
    showDialog(
      barrierDismissible: false,
      context: _formFundKey.currentContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Collection Prompt Sent',
                style: TextStyle(
                  color: Color.fromRGBO(223, 32, 48, 1),
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
                          'Please enter your mobile money pin for a collection prompt sent to the phone number $phone. DO NOT CLOSE THE APP BEFORE YOU ARE NOTIFIED OF TRANSACTION STATUS.',
                          style: TextStyle(fontSize: 14),
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

  _convertTextCurrency(String amountValue) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'baseAmount': amountValue,
      'fromCurrency': _currencyController.text,
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
            // buildDialog(
            //   _formFundKey.currentContext,
            //   'Currency ${_currencyController.text} is not Supported',
            // );
          } else {
            _translatedAmountController.value =
                TextEditingValue(text: 'UGX : ');
          }
        }
      } else {
        buildDialog(_formFundKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      buildDialog(_formFundKey.currentContext,
          'Failed to Connect to Server, Check your internet connection');
    }
  }

  bool validateUserEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
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
