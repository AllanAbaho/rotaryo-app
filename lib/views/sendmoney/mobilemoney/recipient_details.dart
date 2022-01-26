// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';

import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/web_view.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class MobileMoneyRecipientPage extends StatefulWidget {
  String recipientPhoneNumber, recipientName;

  int paymentMode;
  @override
  State<MobileMoneyRecipientPage> createState() =>
      _MobileMoneyRecipientPageState();

  MobileMoneyRecipientPage(
      this.recipientPhoneNumber, this.recipientName, this.paymentMode);
}

class _MobileMoneyRecipientPageState extends State<MobileMoneyRecipientPage> {
  final _formSendKey = GlobalKey<FormState>();

  String senderPhone,
      recipientPhone,
      paymentNetwork,
      reference,
      bulkReference,
      sendMethod,
      pivotReference,
      pivotReferenceBulk,
      version,
      convertedAmount = '';

  Timer timer;
  String currencyCode;
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();
  TextEditingController _translatedAmountController = TextEditingController();
  bool ignoreTaps = false;
  bool isCard = false;

  var format = NumberFormat("###,###", "en_US");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrency().then((value) {
      currencyCode = value;
      _currencyController.value = TextEditingValue(text: value);
      _translatedAmountController.value =
          TextEditingValue(text: '$currencyCode : ');
    });

    PackageInfo.fromPlatform().then((value) {
      version = '${value.version}+${value.buildNumber}';
    });

    _phoneNumberController.value =
        TextEditingValue(text: widget.recipientPhoneNumber);
    _emailController.value = TextEditingValue(text: 'support@pivotpayts.com');
    _recipientController.value = TextEditingValue(text: widget.recipientName);

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
              key: _formSendKey,
              child: SingleChildScrollView(
                child: ProgressHUD(
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
                        VSpace.md,
                        TextInputField(
                          labelText: 'Enter recipient Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the recipient Name';
                            }
                            return null;
                          },
                          controller: _recipientController,
                          onSaved: (value) {},
                        ),
                        VSpace.md,
                        TextInputField(
                          labelText: 'Enter recipient phone number',
                          readOnly: true,
                          controller: _phoneNumberController,
                          onSaved: (value) {},
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
                            readOnly: true,
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
                          hintText: '500,000',
                          keyboardType: TextInputType.number,
                          helperText: 'Enter the Amount',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the amount';
                            }
                            return null;
                          },
                          controller: _amountController,
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
                        VSpace.md,
                        TextInputField(
                          labelText: 'Narration',
                          hintText: 'Narration',
                          controller: _descriptionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Narration';
                            }
                            return null;
                          },
                          helperText: '*required',
                          onSaved: (value) {},
                        ),
                        VSpace.lg,
                        PElevatedbtn(
                          'Next',
                          onTap: () {
                            if (_formSendKey.currentState.validate()) {
                              setState(() {
                                _formSendKey.currentState.save();
                                //_main();
                              });
                              switch (widget.paymentMode) {
                                case 1:
                                  _logTransaction(context, widget.paymentMode);
                                  break;
                                default:
                                  _logTransaction(context, widget.paymentMode);
                                  break;
                              }
                            }
                          },
                        ),
                        VSpace.lg,
                      ],
                    ),
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
    String service;
    progress.showWithText('Logging Transaction...');
    setState(() {
      ignoreTaps = true;
    });

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    reference = DateTime.now().millisecondsSinceEpoch.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String senderAccount = prefs.getString('accountNumber');
    recipientPhone = _phoneNumberController.text;
    if (recipientPhone.startsWith('+')) {
      recipientPhone = recipientPhone.replaceAll('+', '');
    }
    if (recipientPhone.startsWith('0')) {
      recipientPhone = recipientPhone.replaceFirst('0', '256');
    }
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
    switch (paymentMode) {
      case 0:
        paymentNetwork = 'TUMIA WALLET';
        service = 'SEND MONEY';
        sendMethod = 'WALLET';
        break;
      case 1:
        paymentNetwork = 'CARD PAYMENT';
        service = 'SEND MONEY';
        sendMethod = 'CARD';
        break;
      case 2:
        service = 'SEND MONEY';
        sendMethod = 'MOBILE MONEY';
        break;
    }
    reference = reference + prefs.getString('userName').toUpperCase();
    Map data = {
      'phone': senderPhone,
      'amount': _amountController.text,
      'channel': 'RETAIL_APP',
      'service': service,
      'payment_method': sendMethod,
      'payee': recipientPhone,
      'username': prefs.getString('userName'),
      'customer_name': _recipientController.text,
      'service_provider': paymentNetwork,
      'app_version': version,
      'reference': reference,
      'narration': _descriptionController.text
//          'TUMIA PESA : You have sent ${_currencyController.text}. ${_amountController.text} to ${_recipientController.text} trans Ref. $reference on $formatted via $paymentNetwork payments.',
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
            case 0:
              // ignore: use_build_context_synchronously
              _logResponseWallet(senderAccount, reference, 'SUCCESS', context);
              break;
            case 1:
              timer = Timer.periodic(
                Duration(seconds: 5),
                (Timer t) => _checkStatusCard(t, reference),
              );
              // ignore: use_build_context_synchronously
              Navigator.push(
                _formSendKey.currentContext,
                PageRouter.fadeScale(
                  () => CardPayment(
                    '$cardPayment$reference&customerReference=${_phoneNumberController.text}&itempaidfor=SENDMONEY&tranamount=${_amountController.text}&usercurrency=${_currencyController.text}&phoneNumber=${_phoneNumberController.text}&email=support@pivotpayts.com&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https%3A%2F%2Fpivotpayts.com%2Ftestreturn.php',
                  ),
                ),
              );
              break;
          }
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          // ignore: use_build_context_synchronously
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Send Money',
            channelDescription: 'Send Money Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Send Money Notification',
            responseResult['message'].toString(),
            platformChannelSpecifics,
            payload: 'data',
          );

          buildDialog(_formSendKey.currentContext,
              'Failed to log transaction, Error: ${responseResult['message'].toString()}');
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        // ignore: use_build_context_synchronously
        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0002',
          'Send Money',
          channelDescription: 'Send Money Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await FlutterLocalNotificationsPlugin().show(
          randomNumber,
          'Send Money Notification',
          response.statusCode.toString(),
          platformChannelSpecifics,
          payload: 'data',
        );
        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code: ${response.statusCode}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });
      buildDialog(
        _formSendKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
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
    try {
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
              false,
            );
          }
          if (responseStatus == 'FAILED') {
            t.cancel();
            // ignore: use_build_context_synchronously
            WidgetsFlutterBinding.ensureInitialized();
            await NotificationService().init();

            const AndroidNotificationDetails androidPlatformChannelSpecifics =
                AndroidNotificationDetails(
              '0002',
              'Send Money',
              channelDescription: 'Send Money Channel',
            );

            const NotificationDetails platformChannelSpecifics =
                NotificationDetails(android: androidPlatformChannelSpecifics);

            const int MAX = 1000000;
            final int randomNumber = Random().nextInt(MAX);
            await FlutterLocalNotificationsPlugin().show(
              randomNumber,
              'Send Money Notification',
              responseResult['reason'].toString(),
              platformChannelSpecifics,
              payload: 'data',
            );

            StylishDialog(
              context: context,
              alertType: StylishDialogType.ERROR,
              titleText: 'Sorry',
              dismissOnTouchOutside: false,
              confirmButton: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouter.fadeScale(() => HomePage()),
                  );
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
                  'Failed to process Transaction, Error ${responseResult['reason'].toString()}',
            ).show();
          }
        } else {
          t.cancel();
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Send Money',
            channelDescription: 'Send Money Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Send Money Notification',
            'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
            platformChannelSpecifics,
            payload: 'data',
          );
        }
      } else {
        t.cancel();
        // ignore: use_build_context_synchronously
        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0002',
          'Send Money',
          channelDescription: 'Send Money Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await FlutterLocalNotificationsPlugin().show(
          randomNumber,
          'Send Money Notification',
          'Sending Money Failed Network Response',
          platformChannelSpecifics,
          payload: 'data',
        );

        StylishDialog(
          context: context,
          alertType: StylishDialogType.ERROR,
          titleText: 'Sorry',
          dismissOnTouchOutside: false,
          confirmButton: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouter.fadeScale(() => HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
            ),
            child: SmallText(
              'Okay',
            ),
          ),
          animationLoop: true,
          contentText: 'Server Error, Response Code ${response.statusCode}',
        ).show();
      }
    } catch (e) {
      t.cancel();
      StylishDialog(
        context: context,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              PageRouter.fadeScale(() => HomePage()),
            );
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
            'Failed to Connect to Server, please check your internet connection.',
      ).show();
    }
  }

  _logResponseWallet(
    String senderAccount,
    String reference,
    String tranMessage,
    BuildContext context,
  ) async {
    final progress = ProgressHUD.of(context);
    progress.showWithText('Processing Transaction, Please wait ...');
    setState(() {
      ignoreTaps = true;
    });

    Map data = {
      'reference': reference,
      'response_message': tranMessage,
      'senderAccount': senderAccount,
      'credit': "false",
    };

    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          _logTransactionBulk();
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Send Money',
            channelDescription: 'Send Money Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Send Money Notification',
            responseResult['message'].toString(),
            platformChannelSpecifics,
            payload: 'data',
          );

          StylishDialog(
            context: context,
            alertType: StylishDialogType.ERROR,
            titleText: 'Sorry',
            dismissOnTouchOutside: false,
            confirmButton: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouter.fadeScale(() => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
              ),
              child: SmallText(
                'Okay',
              ),
            ),
            animationLoop: true,
            contentText: responseResult['message'].toString(),
          ).show();
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0002',
          'Send Money',
          channelDescription: 'Send Money Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await FlutterLocalNotificationsPlugin().show(
          randomNumber,
          'Send Money Notification',
          response.statusCode.toString(),
          platformChannelSpecifics,
          payload: 'data',
        );

        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });
      StylishDialog(
        context: context,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              PageRouter.fadeScale(() => HomePage()),
            );
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
            'Failed to Connect to Server, please check your internet connection.',
      ).show();
    }
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

  // _currencyConversionDialog(String amount) {
  //   showDialog(
  //     context: _formSendKey.currentContext,
  //     builder: (context) => AlertDialog(
  //       title: Container(
  //         width: 500,
  //         height: 170,
  //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             const Text(
  //               'Currency conversion',
  //               style: TextStyle(
  //                 color: Color.fromRGBO(223, 32, 48, 1),
  //               ),
  //             ),
  //             Divider(
  //               color: Color.fromRGBO(223, 32, 48, 1),
  //             ),
  //             Column(
  //               children: [
  //                 Row(
  //                   children: [
  //                     Column(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       // ignore: prefer_const_literals_to_create_immutables
  //                       children: [
  //                         Text(
  //                           'You are sending',
  //                           style: TextStyle(fontSize: 12),
  //                         ),
  //                         Text(
  //                           'Recipient will recieve',
  //                           style: TextStyle(fontSize: 12),
  //                         )
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       width: 5,
  //                     ),
  //                     Column(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       children: [
  //                         Text(
  //                           '${_currencyController.text}. ${_amountController.text}',
  //                           style: TextStyle(
  //                               fontSize: 12, fontWeight: FontWeight.bold),
  //                         ),
  //                         Text(
  //                           'UGX. $amount',
  //                           style: TextStyle(
  //                               fontSize: 12, fontWeight: FontWeight.bold),
  //                         )
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 20,
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.pop(_formSendKey.currentContext);
  //                   },
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       Text(
  //                         'Cancel',
  //                         style: TextStyle(
  //                             fontSize: 16, fontWeight: FontWeight.bold),
  //                       ),
  //                       Container(
  //                         width: 1,
  //                         height: 20,
  //                         color: Colors.black,
  //                       ),
  //                       GestureDetector(
  //                         onTap: () {
  //                           Navigator.pop(context);
  //                           _logTransaction(_formSendKey.currentContext,
  //                               widget.paymentMode);
  //                         },
  //                         child: Text(
  //                           'Confirm',
  //                           style: TextStyle(
  //                               fontSize: 16,
  //                               color: Color.fromRGBO(
  //                                 223,
  //                                 32,
  //                                 48,
  //                                 1,
  //                               ),
  //                               fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
              _formSendKey.currentContext,
              'Currency $currencyCode is not Supported',
            );
          } else {
            _translatedAmountController.value =
                TextEditingValue(text: '$currencyCode : ');
          }
        }
      } else {
        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      StylishDialog(
        context: _formSendKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formSendKey.currentContext);
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
      'tranNarration': _recipientController.text,
    };
    String auth = stringToBase64.encode('admin:secret123');
    try {
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

          buildDialog(_formSendKey.currentContext,
              'Failed to initiate Collection Request, Error: ${responseResult['statusDesc']}');
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code: ${response.statusCode}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });
      StylishDialog(
        context: _formSendKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formSendKey.currentContext);
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

  _collectionPromptDialog(String phone) {
    showDialog(
      barrierDismissible: false,
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
                  color: Color.fromRGBO(223, 32, 48, 1),
                  fontSize: 17,
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
                          'Please enter your mobile money pin for a collection prompt sent to the phone number $phone to complete the transaction. DO NOT CLOSE THE APP BEFORE YOU ARE NOTIFIED OF TRANSACTION STATUS.',
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
    String auth = stringToBase64.encode('admin:secret123');
    try {
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
              false,
            );
          }
          if (responseStatus == 'FAILED') {
            t.cancel();
            buildDialog(_formSendKey.currentContext,
                responseResult['reason'].toString());
          }
        } else {
          t.cancel();
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Send Money',
            channelDescription: 'Send Money Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Send Money Notification',
            'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
            platformChannelSpecifics,
            payload: 'data',
          );
        }
      } else {
        t.cancel();
        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      t.cancel();
      StylishDialog(
        context: _formSendKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formSendKey.currentContext);
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

  _logResponse(
    String tranMessage,
    String pivotReference,
    String telecomId,
    String reference,
    bool isPayment,
  ) async {
    Map data = {
      'reference': reference,
      'pivot_ref': pivotReference,
      'telecom_ref': telecomId,
      'response_message': tranMessage,
      'credit': "false",
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          if (isPayment) {
            _updateBalance(responseResult['accountBalance'].toString());
            // ignore: use_build_context_synchronously
          } else {
            _logTransactionBulk();
          }
        } else {
          buildDialog(_formSendKey.currentContext,
              responseResult['message'].toString());
        }
      } else {
        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      StylishDialog(
        context: _formSendKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formSendKey.currentContext);
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
              "You've successfully transferred ${_currencyController.text}. ${_amountController.text} to ${_recipientController.text}",
          templateId: 2,
          receipient: _phoneNumberController.text,
          name: _recipientController.text,
          narration: _descriptionController.text,
        ),
      ),
    );
  }

  _logTransactionBulk() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    String receiveMethod, service;
    bulkReference = DateTime.now().millisecondsSinceEpoch.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recipientPhone = _phoneNumberController.text;
    if (recipientPhone.startsWith('+')) {
      recipientPhone = recipientPhone.replaceAll('+', '');
    }
    if (recipientPhone.startsWith('0')) {
      recipientPhone = recipientPhone.replaceFirst('0', '256');
    }
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
    service = 'RECEIVE MONEY';
    receiveMethod = 'MOBILE MONEY';

    bulkReference = bulkReference + prefs.getString('userName').toUpperCase();
    if (!paymentNetwork.contains('CARD PAYMENT')) {
      convertedAmount = _amountController.text;
    }
    Map data = {
      'phone': senderPhone,
      'amount': convertedAmount,
      'channel': 'RETAIL_APP',
      'service': service,
      'payment_method': receiveMethod,
      'payee': recipientPhone,
      'username': prefs.getString('userName'),
      'customer_name': _recipientController.text,
      'service_provider': paymentNetwork,
      'app_version': version,
      'reference': bulkReference,
      'narration': _descriptionController.text
      //'TUMIA PESA : You have sent ${_currencyController.text}. ${_amountController.text} to ${_recipientController.text} trans Ref. $reference on $formatted via $paymentNetwork payments.',
    };

    try {
      final response = await http
          .post(Uri.parse('${tumiaApi}log_transaction.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          _sendBulkPayment(formatted, paymentNetwork);
        } else {
          buildDialog(_formSendKey.currentContext,
              responseResult['message'].toString());
        }
      } else {
        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      StylishDialog(
        context: _formSendKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formSendKey.currentContext);
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

  _sendBulkPayment(String _date, String telecom) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    if (!paymentNetwork.contains('CARD PAYMENT')) {
      convertedAmount = _amountController.text;
    }
    Map data = {
      'accountNumber': recipientPhone,
      'tranAmount': convertedAmount,
      'accountType': 'MOMO',
      'tranType': 'DISBURSEMENT',
      'currency': 'UGX',
      'country': 'UG',
      'accountName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'addendum1': 'BULKPAYMENT',
      'addendum2': 'BULKPAYMENT',
      'addendum3': 'SEND MONEY',
      'collection_method': sendMethod,
      'paymentDate': _date,
      'password': 'EVJ7O9V6Q6',
      'tranSignature': 'testSignature',
      'vendorCode': 'TUMIA_APP',
      'telecom': telecom,
      'commonReference': reference,
      'vendorTranId': bulkReference,
      'tranNarration': _recipientController.text,
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
        if (responseStatus == '200') {
          pivotReferenceBulk = responseResult['tranReference'].toString();
          timer = Timer.periodic(
            Duration(seconds: 5),
            (Timer t) => _checkStatusBulk(t, bulkReference, pivotReferenceBulk),
          );
        } else {
          // ignore: use_build_context_synchronously
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Send Money',
            channelDescription: 'Send Money Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Send Money Notification',
            responseResult['statusDesc'].toString(),
            platformChannelSpecifics,
            payload: 'data',
          );

          buildDialog(_formSendKey.currentContext,
              responseResult['statusDesc'].toString());
        }
      } else {
        // ignore: use_build_context_synchronously
        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0002',
          'Send Money',
          channelDescription: 'Send Money Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await FlutterLocalNotificationsPlugin().show(
          randomNumber,
          'Send Money Notification',
          'Sending Money Failed, Server Error Response Code: ${response.statusCode}',
          platformChannelSpecifics,
          payload: 'data',
        );

        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      StylishDialog(
        context: _formSendKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formSendKey.currentContext);
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

  _checkStatusBulk(Timer t, String vendorTranId, String tranReference) async {
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
            vendorTranId,
            true,
          );
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          // ignore: use_build_context_synchronously
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Send Money',
            channelDescription: 'Send Money Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Send Money Notification',
            responseResult['reason'].toString(),
            platformChannelSpecifics,
            payload: 'data',
          );

          buildDialog(_formSendKey.currentContext,
              'Sending Money Failed ${responseResult['reason']}');
        }
      } else {
        t.cancel();
        // ignore: use_build_context_synchronously
        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0002',
          'Send Money',
          channelDescription: 'Send Money Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await FlutterLocalNotificationsPlugin().show(
          randomNumber,
          'Send Money Notification',
          'Failed to process transaction, ${response.statusCode.toString()}',
          platformChannelSpecifics,
          payload: 'data',
        );
        buildDialog(_formSendKey.currentContext,
            'Server Error, Response Code: ${response.statusCode}');
      }
    } catch (e) {
      t.cancel();
      StylishDialog(
        context: _formSendKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formSendKey.currentContext);
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
}
