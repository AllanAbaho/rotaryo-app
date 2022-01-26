import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/debitcard/web_view.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/marketplace/payloan/summary.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class PayloadAccountInformationPage extends StatefulWidget {
  String loanProvider, paymentType, otherPaymentType, othersNarration;

  PayloadAccountInformationPage(this.loanProvider, this.paymentType,
      this.otherPaymentType, this.othersNarration);

  @override
  State<PayloadAccountInformationPage> createState() =>
      _PayloadAccountInformationPageState();
}

class _PayloadAccountInformationPageState
    extends State<PayloadAccountInformationPage> {
  final _formLoanKey = GlobalKey<FormState>();
  String senderPhone,
      recipientPhone,
      paymentNetwork,
      reference,
      pivotReference,
      version,
      pivotTranRef,
      telecomRef,
      responseMessage,
      formatted,
      txnReference,
      jwdata,
      proposalNumber,
      productType,
      productCode,
      proposalCode,
      customerNumber,
      customerName,
      tranCharge;

  double totalAmount;
  Timer timer;

  String currencyCode, convertedAmount = '';

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _plateNumberController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();
  bool ignoreTaps = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrency().then((value) {
      currencyCode = value;
      _currencyController.value = TextEditingValue(text: value);
    });
    PackageInfo.fromPlatform().then((value) {
      version = '${value.version}+${value.buildNumber}';
    });
    _emailController.value = TextEditingValue(text: 'support@pivotpayts.com');
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
              key: _formLoanKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                  child: Column(
                    children: [
                      VSpace.xs,
                      MediumText('Account Information', size: FontSizes.s20),
                      VSpace.xs,
                      SmallText(
                        'We’re finishing up your payment',
                        size: FontSizes.s14,
                        align: TextAlign.center,
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Full Name',
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Full Name';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Phone Number',
                        onSaved: (value) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Phone Number';
                          }
                          return null;
                        },
                        controller: _phoneNumberController,
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Number plate/Proposal Number',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Number plate/Proposal Number';
                          }
                          return null;
                        },
                        controller: _plateNumberController,
                        onSaved: (value) {},
                      ),
                      VSpace.md,
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
                            VSpace.md
                          ],
                        ),
                      ),
                      TextInputField(
                        labelText: 'Select currency',
                        hintText: 'UGX',
                        controller: _currencyController,
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
                        onSaved: (value) {},
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Enter Desired Amount',
                        hintText: 'UGX',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the amount';
                          }
                          return null;
                        },
                        controller: _amountController,
                        onSaved: (value) {},
                      ),
                      VSpace.lg,
                      PElevatedbtn('Confirm', onTap: () {
                        if (_formLoanKey.currentState.validate()) {
                          setState(() {
                            _formLoanKey.currentState.save();
                          });
                          _validatePlateNumber(
                            _plateNumberController.text,
                            context,
                          );
                        }
                      }
                          //  => Navigator.push(
                          //   context,
                          //   PageRouter.fadeThrough(
                          //     () => LoanSummaryPage(),
                          //   ),
                          // ),
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
            ),
          ),
        ),
      ),
    );
  }

  _currencyConversionDialog(String amount, int paymentMode) {
    showDialog(
      context: _formLoanKey.currentContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Currency conversion',
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
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Text(
                            'You are sending',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Recipient will recieve',
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_currencyController.text}. ${_amountController.text}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'UGX. $amount',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(_formLoanKey.currentContext);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.black,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _logTransaction(
                                _formLoanKey.currentContext, paymentMode);
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

  _checkStatusCard(Timer t, String vendorTranId, int paymentMode) async {
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
            _processTransaction(paymentMode);
          }
          if (responseStatus == 'FAILED') {
            t.cancel();
            buildDialog(
              _formLoanKey.currentContext,
              "${responseResult['reason']}",
            );
          }
        } else {
          t.cancel();
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0003',
            'Loan Payment',
            channelDescription: 'Loan Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Loan Payment Notification',
            'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
            platformChannelSpecifics,
            payload: 'data',
          );
        }
      } else {
        t.cancel();
        buildDialog(
          _formLoanKey.currentContext,
          'Response Time out',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _convertCurrency(String amount, int paymentMode) async {
    final progress = ProgressHUD.of(_formLoanKey.currentContext);
    progress.showWithText('Converting Currency...');
    setState(() {
      ignoreTaps = true;
    });

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'baseAmount': _amountController.text,
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
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          String currencyAmount = responseResult['convertedAmount'].toString();
          double doubleAmount = double.parse(currencyAmount);
          int intAmount = doubleAmount.round();
          convertedAmount = intAmount.toString();
          _currencyConversionDialog(convertedAmount, paymentMode);
        } else {
          buildDialog(
            _formLoanKey.currentContext,
            'Currency ${_currencyController.text} is not Supported',
          );
        }
      } else {
        buildDialog(
          _formLoanKey.currentContext,
          'Currency Conversion failed ${response.body}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _validatePlateNumber(String meterNumber, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    progress.showWithText('Verifying Plate Number...');
    setState(() {
      ignoreTaps = true;
    });

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'search_input': meterNumber,
      'channel': 'tumiaApp',
      'merchant': 'BODA_BANJA',
      'amount': _amountController.text
    };
    String auth = stringToBase64.encode('admin:secret123');
    try {
      final response = await http.post(
        Uri.parse('${bodaBodaBanja}vehicleInfo'),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['status'];
        if (responseStatus == '200') {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          jwdata = responseResult['lan'].toString();
          proposalNumber = responseResult['proposal_no'].toString();
          proposalCode = responseResult['proposal_no'].toString();
          productCode = responseResult['product_code'].toString();
          productType = responseResult['product_type'].toString();
          customerName = responseResult['customer_name'].toString();
          customerNumber = responseResult['mobile_no'].toString();
          tranCharge = responseResult['trancharge'].toString();
          totalAmount = double.parse(_amountController.text) +
              double.parse(responseResult['trancharge'].toString());
          // ignore: use_build_context_synchronously
          _showDialog();
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
            _formLoanKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formLoanKey.currentContext,
          'Plate Number search failed ${response.body}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
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
        child: SmallText(
          'Okay',
        ),
      ),
      animationLoop: true,
      contentText: dialogMessage,
    ).show();
  }

  // ignore: always_declare_return_types
  _showDialog() {
    showDialog(
      context: _formLoanKey.currentContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Boda Boda Banja Information',
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
                          'Confirm payment of UGX. ${_amountController.text} for: Plate number ${_plateNumberController.text} customer name: $customerName Charge UGX. $tranCharge',
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
                                Navigator.push(
                                  context,
                                  PageRouter.fadeThrough(
                                    () => DebitCardPage(
                                      next: () {
                                        Navigator.push(
                                          context,
                                          PageRouter.fadeScale(
                                            () => TransactionSuccessPage(
                                              body:
                                                  "Your Metre token is: 65783567856t739856785783569856.9PT",
                                              templateId: 4,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              } else if (value.id == 2) {
                                Navigator.pop(context);
                                _logTransaction(context, paymentMode);
                              } else {
                                Navigator.pop(context);
                                final pinValid = Navigator.push<bool>(
                                  context,
                                  PageRouter.fadeThrough(
                                    () => PinPage(),
                                  ),
                                );
                                pinValid.then(
                                  (value) {
                                    if (value) {
                                      _logTransaction(context, paymentMode);
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

  _logTransaction(BuildContext context, int paymentMode) async {
    final progress = ProgressHUD.of(_formLoanKey.currentContext);
    progress.showWithText('Logging Transaction...');
    setState(() {
      ignoreTaps = true;
    });

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    formatted = formatter.format(now);
    String service;
    reference = DateTime.now().millisecondsSinceEpoch.toString();
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

    switch (paymentMode) {
      case 0:
        paymentNetwork = 'WALLET PAYMENT';
        service = 'WALLET PAYMENT';
        break;
      case 1:
        paymentNetwork = 'CARD PAYMENT';
        service = 'LOAN PAYMENT';
        break;
      case 2:
        service = 'TOP UP';
        break;
    }
    reference = reference + prefs.getString('userName').toUpperCase();
    Map data = {
      'phone': senderPhone,
      'amount': totalAmount.toString(),
      'channel': 'RETAIL_APP',
      'service': service,
      'payment_method': paymentNetwork,
      'payee': recipientPhone,
      'username': prefs.getString('userName'),
      'customer_name': customerName,
      'service_provider': paymentNetwork,
      'app_version': version,
      'reference': reference,
      'narration': widget.loanProvider
      //'TUMIA PESA : You have paid UGX.${_amountController.text} to $widget.loanProvider trans Ref. $reference on $formatted via $paymentNetwork payments.',
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
              _topUpCollection(formatted, paymentNetwork, paymentMode);
              break;
            case 0:
              _logResponseWallet(
                  prefs.get('accountNumber').toString(),
                  reference,
                  'SUCCESS',
                  _formLoanKey.currentContext,
                  paymentMode);
              break;
            case 1:
              timer = Timer.periodic(
                Duration(seconds: 5),
                (Timer t) => _checkStatusCard(t, reference, paymentMode),
              );
              // ignore: use_build_context_synchronously
              Navigator.push(
                _formLoanKey.currentContext,
                PageRouter.fadeScale(
                  () => CardPayment(
                    '$cardPayment$reference&customerReference=${_phoneNumberController.text}&itempaidfor=FUNDWALLET&tranamount=${_amountController.text}&usercurrency=${_currencyController.text}&phoneNumber=${_phoneNumberController.text}&email=support@pivotpayts.com&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https%3A%2F%2Fpivotpayts.com%2Ftestreturn.php',
                  ),
                ),
              );
              break;
          }
          ;
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
            _formLoanKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formLoanKey.currentContext,
          'Logging Transaction failed ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _logResponseWallet(String senderAccount, String reference, String tranMessage,
      BuildContext context, int paymentMode) async {
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
          print(response.statusCode);

          _processTransaction(paymentMode);
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
            _formLoanKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formLoanKey.currentContext,
          'Sending Money Failed ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _topUpCollection(String _date, String telecom, int paymentMode) async {
    final progress = ProgressHUD.of(_formLoanKey.currentContext);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    progress.showWithText('Initiating Collection Request..');
    setState(() {
      ignoreTaps = true;
    });

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'accountNumber': senderPhone,
      'tranAmount': totalAmount.toString(),
      'accountType': 'MOMO',
      'tranType': 'COLLECTION',
      'currency': 'UGX',
      'country': 'UG',
      'accountName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'addendum1': 'COLLECTION',
      'addendum2': 'COLLECTION',
      'addendum3': 'LOAN PAYMENT',
      'paymentDate': _date,
      'password': 'EVJ7O9V6Q6',
      'tranSignature': 'testSignature',
      'vendorCode': 'TUMIA_APP',
      'telecom': telecom,
      'commonReference': reference,
      'vendorTranId': reference,
      'tranNarration': widget.loanProvider,
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
            (Timer t) =>
                _checkStatus(t, reference, pivotReference, paymentMode),
          );
          _collectionPromptDialog(senderPhone);
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
              _formLoanKey.currentContext, "${responseResult['statusDesc']}");
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(_formLoanKey.currentContext,
            'Sending Money Failed ${response.body}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _collectionPromptDialog(String phone) {
    showDialog(
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
                          'Please enter your mobile money pin for a collection prompt sent to the phone number $phone',
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

  _checkStatus(Timer t, String vendorTranId, String tranReference,
      int paymentMode) async {
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
            responseMessage = responseResult['tran_status'].toString();
            pivotTranRef = responseResult['pivot_ref'].toString();
            telecomRef = responseResult['telecom_id'].toString();
            _processTransaction(paymentMode);
          }
          if (responseStatus == 'FAILED') {
            t.cancel();
            buildDialog(
              _formLoanKey.currentContext,
              "${responseResult['reason']}",
            );
          }
        } else {
          t.cancel();
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0003',
            'Loan Payment',
            channelDescription: 'Loan Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Loan Payment Notification',
            'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
            platformChannelSpecifics,
            payload: 'data',
          );
        }
      } else {
        t.cancel();
        buildDialog(
          _formLoanKey.currentContext,
          'Collection failed ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _processTransaction(int paymentMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String narration;
    if (widget.paymentType == 'Other Payments') {
      if (widget.otherPaymentType == 'Others') {
        narration = widget.othersNarration;
      } else {
        narration = widget.otherPaymentType;
      }
    } else {
      narration = widget.paymentType;
    }
    Map data = {
      'reference': _plateNumberController.text,
      'amount': totalAmount.toString(),
      'channel': 'tumiaApp',
      'merchant': 'BODA_BANJA',
      'checkoutmode': 'TUMIAWALLET',
      'phonenumber': recipientPhone,
      'jwdata': jwdata,
      'agentId': senderPhone,
      'trancharge': tranCharge,
      'proposalNumber': proposalNumber,
      'customerName': customerName,
      'phonenumber': _phoneNumberController.text,
      'product_code': productCode,
      'product_type': productType,
      'location': 'Retail App',
      'createdby': prefs.getString('userName'),
      'commonReference': reference,
      'createdby': 'tumiaApp',
      'paymentNarration': narration,
    };
    String auth = stringToBase64.encode('admin:secret123');
    try {
      final response = await http.post(
        Uri.parse('${bodaBodaBanja}logTransaction'),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['code'];
        if (responseStatus == '200') {
          txnReference = responseResult['transObj']['txn_reference'].toString();
          _updatePayment(txnReference, paymentMode);
        } else {
          buildDialog(
            _formLoanKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formLoanKey.currentContext,
          'Loan Payment Failed ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _updatePayment(String vendorTranId, int paymentMode) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'amount': totalAmount.toString(),
      'external_ref': vendorTranId,
      'status': 'SUCCESS',
      'network_ref': ''
    };
    String auth = stringToBase64.encode('admin:secret123');
    try {
      final response = await http.post(
        Uri.parse('${bodaBodaBanja}updateTransaction'),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['code'];
        if (responseStatus == '200') {
          switch (paymentMode) {
            case 0:
              _logResponseLoan(
                'SUCCESS',
                reference,
              );
              break;
            default:
              _logResponse(
                responseMessage,
                pivotReference,
                telecomRef,
                reference,
              );
              break;
          }
        }
        if (responseStatus == 'FAILED') {
          buildDialog(
            _formLoanKey.currentContext,
            "${responseResult['reason']}",
          );
        }
      } else {
        buildDialog(
          _formLoanKey.currentContext,
          'Transaction Update Failed ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _logResponseLoan(
    String tranMessage,
    String reference,
  ) async {
    Map data = {
      'reference': reference,
      'response_message': tranMessage,
      'credit': "false",
      'merchant': widget.loanProvider
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
            _formLoanKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formLoanKey.currentContext,
          'Sending Money Failed ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
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
          body: 'Your Transaction was successfully processed',
          templateId: 3,
          transactionRef: txnReference,
          plateNumber: _plateNumberController.text,
          amount: _amountController.text,
          charge: tranCharge,
          paymentType: widget.loanProvider,
          name: _fullNameController.text,
          dateTime: formatted,
          agentId: recipientPhone,
        ),
      ),
    );
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
      'credit': "false",
      'merchant': widget.loanProvider
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
                body: 'Your Transaction was successfully processed',
                templateId: 3,
                transactionRef: txnReference,
                plateNumber: _plateNumberController.text,
                amount: _amountController.text,
                charge: tranCharge,
                paymentType: widget.loanProvider,
                name: _fullNameController.text,
                dateTime: formatted,
                agentId: recipientPhone,
              ),
            ),
          );
        } else {
          buildDialog(
            _formLoanKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formLoanKey.currentContext,
          'Sending Money Failed ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formLoanKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }
}
