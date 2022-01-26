import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/models/bills.dart';
import 'package:tumiapesa/storage/database_helper.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:tumiapesa/utils/notifications.dart';

import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/debitcard/web_view.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/mobilemoney/mobile_money.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/sendmoney/sendmoney.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/banner.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class ElectricityPage extends StatefulWidget {
  @override
  _ElectricityPageState createState() => _ElectricityPageState();

  static _ElectricityPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_ElectricityPageState>();
}

class _ElectricityPageState extends State<ElectricityPage> {
  final _formEleKey = GlobalKey<FormState>();
  String senderPhone,
      recipientPhone,
      paymentNetwork,
      reference,
      pivotReference,
      pivotTranRef,
      dealer,
      agent,
      pivot,
      authCode,
      telecomRef,
      version,
      responseMessage,
      utility,
      billUtility,
      totalAmount,
      pivotServiceFee,
      txnCharge,
      txnReference,
      jwdata,
      powerToken,
      customerCode,
      units,
      userType,
      electricityFee,
      taxFee,
      serviceFee,
      meter_name,
      pivotTranCharge;

  String currencyCode, convertedAmount = '';

  Timer timer;
  var format = NumberFormat("###,###", "en_US");

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _meterNumberController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();
  TextEditingController _translatedAmountController = TextEditingController();
  bool ignoreTaps = false;

  bool _isNWSC = false;
  set isNWSC(bool value) => setState(() => _isNWSC = value);

  String _myCustomerCode = '';
  set myCustomerCode(String value) => setState(() => _myCustomerCode = value);

  List<Bill> _waterBills;
  set waterBills(List<Bill> res) => setState(() => _waterBills = res);

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
    _emailController.value = TextEditingValue(text: 'support@pivotpayts.com');

    _amountController.addListener(() {
      _convertTextCurrency(_amountController.text, _currencyController.text);
    });
    _currencyController.addListener(() {
      _convertTextCurrency(_amountController.text, _currencyController.text);
    });

    PackageInfo.fromPlatform().then((value) {
      version = '${value.version}+${value.buildNumber}';
    });
  }

  Future<String> _getCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currencyCode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Utilities'),
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Form(
              key: _formEleKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                  child: Column(
                    children: [
                      VSpace.md,
                      TumiaPesaBanner(
                        imgUrl: AppImages.flash,
                        title: 'Utilities',
                        subtitle: 'Made easy',
                      ),
                      VSpace.sm,
                      SmallText(
                        "Get your Utility Bills tokens with no stress",
                        align: TextAlign.center,
                      ),
                      VSpace.md,
                      DropDownTextInputField(
                        labelText: 'Select provider',
                        isOnboardingField: true,

                        onSaved: (value) {
                          utility = value.title;
                          customerCode = value.value;
                        },
                        // ignore: prefer_const_literals_to_create_immutables
                        items: [
                          DropDownItem(
                            imgUrl: 'assets/images/wenreco.png',
                            title: 'Wenreco',
                            value: '2',
                          ),
                          DropDownItem(
                            imgUrl: 'assets/images/umeme.jpeg',
                            title: 'Umeme Yaka',
                            value: '4372347',
                          ),
                          DropDownItem(
                            imgUrl: 'assets/images/umeme.jpeg',
                            title: 'Umeme Postpaid',
                            value: '4372346',
                          ),
                          DropDownItem(
                            imgUrl: 'assets/images/nwsc.png',
                            title: 'NWSC',
                            value: '249',
                          ),
                        ],
                      ),
                      VSpace.md,
                      Visibility(
                        visible: _isNWSC,
                        child: Column(
                          children: [
                            NationalWaterLocations(waterBills: _waterBills),
                            VSpace.md,
                          ],
                        ),
                      ),
                      TextInputField(
                        labelText: 'Enter Meter Number',
                        controller: _meterNumberController,
                        onSaved: (value) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Meter Name';
                          }
                          return null;
                        },
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
                        labelText: 'You are Paying..',
                        controller: _amountController,
                        helperText: 'Enter Amount',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Desired Amount';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Utlity is Receiving..',
                        readOnly: true,
                        controller: _translatedAmountController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Desired Amount';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                      ),
                      VSpace.md,
                      TextInputField(
                        labelText: 'Enter Phone Number',
                        controller: _phoneNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Phone Number';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                      ),
                      VSpace.md,
                      VSpace.lg,
                      PElevatedbtn(
                        'Check',
                        onTap: () {
                          if (_formEleKey.currentState.validate()) {
                            setState(() {
                              _formEleKey.currentState.save();
                            });
                            print("$utility : is your utility!");
                            if (utility == 'Wenreco') {
                              billUtility = 'WENRECO';
                              _validateMeterNumber(
                                _meterNumberController.text,
                                context,
                              );
                            } else {
                              if (utility == 'NWSC') {
                                billUtility = 'NWSC';
                                validateMeter(
                                  _amountController.text,
                                  _myCustomerCode,
                                  'NWSC',
                                  _meterNumberController.text,
                                  context,
                                  'NWSC',
                                );
                              } else {
                                billUtility = 'UMEME';
                                validateMeter(
                                  _amountController.text,
                                  customerCode,
                                  'UMEME',
                                  _meterNumberController.text,
                                  context,
                                  'UMEME',
                                );
                              }
                            }
                          }
                        },
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

  _validateMeterNumber(String meterNumber, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    progress.showWithText('Verifying Meter...');
    setState(() {
      ignoreTaps = true;
    });
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'meternumber': meterNumber,
      'channel': 'tumiaApp',
      'merchant': 'WENReCo',
    };
    String auth = stringToBase64.encode('admin:secret123');
    try {
      final response = await http.post(
        Uri.parse('${wenreco}meterInfo'),
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
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          jwdata = responseResult['jwdata'].toString();
          // ignore: use_build_context_synchronously
          _showDialog(
            responseResult['data']['balance'].toString(),
            responseResult['data']['username'].toString(),
          );
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formEleKey.currentContext,
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

  validateMeter(
    String amount,
    String customerCode,
    String tvProvider,
    String decoderNumber,
    BuildContext context,
    String package,
  ) async {
    final progress = ProgressHUD.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    progress.showWithText('Verifying Meter Number...');
    setState(() {
      ignoreTaps = true;
    });
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String stringToHash = '$decoderNumber${tvProvider}TUMIA_APP';
    var key = utf8.encode(merchantSecret);
    var bytes = utf8.encode(stringToHash);

    var hmacSha512 = Hmac(sha512, key);
    Digest sha512Result = hmacSha512.convert(bytes);
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formatted = formatter.format(now);
    String reference = DateTime.now().millisecondsSinceEpoch.toString();
    reference = reference + prefs.getString('userName').toUpperCase();
    Map data = {
      'customerReference': decoderNumber,
      'billerCode': tvProvider,
      'appVersion': version,
      'checkoutMode': 'TUMIAWALLET',
      'merchantCode': vendorCode,
      'merchantPassword': vendorPassword,
      'customerType': 'PREPAID',
      'customerCategory': customerCode,
      'amount': amount,
      'requestReference': reference,
      'requestSignature': base64.encode(sha512Result.bytes),
    };
    String auth = stringToBase64.encode('admin:secret123');

    try {
      final response = await http.post(
        Uri.parse('${billPayments}validateReference'),
        headers: {
          HttpHeaders.authorizationHeader: 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['responseCode'];
        if (responseStatus == '200') {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          String outstanding = responseResult['outstandingBalance'].toString();
          if (outstanding.length > 2) {
            outstanding = outstanding.substring(0, outstanding.length - 2);
            if (outstanding.isEmpty) {
              outstanding = '0';
            }
          }
          authCode = responseResult['authCode'].toString();
          pivotServiceFee = responseResult['serviceFee'].toString();
          serviceFee = responseResult['service_fee'].toString();
          pivotTranCharge = responseResult['tran_charge'].toString();
          txnCharge = responseResult['transactionCharge'].toString();
          dealer = responseResult['dealer_commission'].toString();
          agent = responseResult['agent_commission'].toString();
          pivot = responseResult['pivot_commission'].toString();

          double total =
              double.parse(serviceFee) + double.parse(pivotTranCharge);
          totalAmount = total.toString();
          // ignore: use_build_context_synchronously
          _showDialogMeter(
            decoderNumber,
            outstanding,
            responseResult['customerName'].toString(),
            amount,
            tvProvider,
            package,
            customerCode,
          );
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['responseDescription']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _showDialogMeter(
    String meterNumber,
    String balance,
    String accountName,
    String amount,
    String utility,
    String package,
    String customerCode,
  ) {
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
                'Meter Verification',
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
                          'Confirm payment for: Meter number $meterNumber username: $accountName and outstanding balance of UGX. ${format.format(double.parse(balance).round())}',
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
                                _logTransactionMeter(
                                  paymentMode,
                                  accountName,
                                  amount,
                                  utility,
                                  package,
                                  meterNumber,
                                  customerCode,
                                );
                              } else if (value.id == 2) {
                                Navigator.pop(context);
                                _logTransactionMeter(
                                  paymentMode,
                                  accountName,
                                  amount,
                                  utility,
                                  package,
                                  meterNumber,
                                  customerCode,
                                );
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
                                      _logTransactionMeter(
                                        paymentMode,
                                        accountName,
                                        amount,
                                        utility,
                                        package,
                                        meterNumber,
                                        customerCode,
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

  // ignore: always_declare_return_types
  _showDialog(String balance, String accountName) {
    showDialog(
      barrierDismissible: false,
      context: _formEleKey.currentContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Meter Verification',
                style: TextStyle(
                  fontSize: 16,
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
                          'Confirm payment for: Meter number ${_meterNumberController.text} username: $accountName and outstanding balance of UGX. ${format.format(double.parse(balance).round())}',
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
                                _logTransaction(paymentMode);
                              } else if (value.id == 2) {
                                Navigator.pop(context);
                                _logTransaction(paymentMode);
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
                                      _logTransaction(paymentMode);
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

  _logTransactionMeter(
    int paymentMode,
    String customerName,
    String amount,
    String utility,
    String package,
    String meterNumber,
    String customerCode,
  ) async {
    final progress = ProgressHUD.of(_formEleKey.currentContext);
    progress.showWithText('Logging Transaction...');
    setState(() {
      ignoreTaps = true;
    });

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    String paymentMobileNetwork, paymentNetwork;
    reference = DateTime.now().millisecondsSinceEpoch.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      paymentMobileNetwork = 'AIRTEL';
    } else {
      paymentMobileNetwork = 'MTN';
    }
    switch (paymentMode) {
      case 0:
        paymentNetwork = 'WALLET';
        paymentMobileNetwork = 'TUMIA WALLET';
        break;
      case 1:
        paymentNetwork = 'CARD';
        paymentMobileNetwork = 'CARD';
        break;
      case 2:
        paymentNetwork = 'MOBILE MONEY';
        break;
    }
    reference = reference + prefs.getString('userName').toUpperCase();
    Map data = {
      'phone': senderPhone,
      'amount': amount,
      'channel': 'RETAIL_APP',
      'service': 'BILL PAYMENT',
      'payment_method': paymentNetwork,
      'payee': package,
      'bill_utility': billUtility,
      'username': prefs.getString('userName'),
      'customer_name': customerName,
      'service_provider': paymentMobileNetwork,
      'app_version': version,
      'reference': reference,
      'narration': utility
      //'TUMIA PESA : You have paid UGX.${_amountController.text} to $utility trans Ref. $reference on $formatted via $paymentNetwork payments.',
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
              _topUpCollectionMeter(
                formatted,
                paymentMobileNetwork,
                paymentMode,
                amount,
                utility,
                meterNumber,
                customerName,
                customerCode,
              );
              break;
            case 0:
              // ignore: use_build_context_synchronously
              _processTransactionMeter(
                paymentMode,
                meterNumber,
                utility,
                customerCode,
                customerName,
                amount,
              );

              Navigator.push(
                _formEleKey.currentContext,
                PageRouter.fadeScale(
                  () => HomePage(),
                ),
              );
              break;
            case 1:
              timer = Timer.periodic(
                Duration(seconds: 5),
                (Timer t) => _checkStatusCardMeter(
                  t,
                  reference,
                  paymentMode,
                  meterNumber,
                  amount,
                  utility,
                  customerName,
                  customerCode,
                ),
              );
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                PageRouter.fadeScale(
                  () => CardPayment(
                    '$cardPayment$reference&customerReference=${senderPhone}&itempaidfor=FUNDWALLET&tranamount=${amount}&usercurrency=UGX&phoneNumber=${senderPhone}&email=support@pivotpayts.com&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https%3A%2F%2Fpivotpayts.com%2Ftestreturn.php',
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

          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Please check your internet connection',
      );
    }
  }

  _checkStatusCardMeter(
    Timer t,
    String vendorTranId,
    int paymentMode,
    String meterNumber,
    String amount,
    String utility,
    String customerName,
    String customerCode,
  ) async {
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
          // ignore: use_build_context_synchronously
          _processTransactionMeter(
            paymentMode,
            meterNumber,
            utility,
            customerCode,
            customerName,
            amount,
          );
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['reason']}",
          );
        }
      } else {
        t.cancel();
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response code ${response.statusCode}',
        );
      }
    } catch (e) {
      t.cancel();
      buildDialog(
        _formEleKey.currentContext,
        'Faile to connect to Server, Please check your Internet Connection',
      );
    }
  }

  _topUpCollectionMeter(
    String _date,
    String telecom,
    int paymentMode,
    String amount,
    String utility,
    String meterNumber,
    String accountName,
    String customerCategory,
  ) async {
    final progress = ProgressHUD.of(_formEleKey.currentContext);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    progress.showWithText('Initiating Collection Request..');
    setState(() {
      ignoreTaps = true;
    });

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'accountNumber': senderPhone,
      'tranAmount': amount,
      'accountType': 'MOMO',
      'tranType': 'COLLECTION',
      'currency': 'UGX',
      'country': 'UG',
      'accountName':
          '${prefs.getString('secondName')} ${prefs.getString('firstName')}',
      'addendum1': 'COLLECTION',
      'addendum2': 'COLLECTION',
      'addendum3': 'BILL PAYMENT',
      'paymentDate': _date,
      'password': 'EVJ7O9V6Q6',
      'tranSignature': 'testSignature',
      'vendorCode': 'TUMIA_APP',
      'telecom': telecom,
      'commonReference': reference,
      'vendorTranId': reference,
      'tranNarration': utility,
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
            (Timer t) => _checkStatusMeter(
              t,
              reference,
              pivotReference,
              paymentMode,
              meterNumber,
              amount,
              utility,
              accountName,
              customerCategory,
            ),
          );
          _collectionPromptDialog(senderPhone);
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['statusDesc']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Please check your Internet Connection',
      );
    }
  }

  _checkStatusMeter(
    Timer t,
    String vendorTranId,
    String tranReference,
    int paymentMode,
    String meterNumber,
    String amount,
    String tvProvider,
    String accountName,
    String customerCategory,
  ) async {
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
        if (responseStatus == 'SUCCESS') {
          t.cancel();
          responseMessage = responseResult['tran_status'].toString();
          pivotTranRef = responseResult['pivot_ref'].toString();
          telecomRef = responseResult['telecom_id'].toString();
          _processTransactionMeter(paymentMode, meterNumber, tvProvider,
              customerCategory, accountName, amount);
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['reason']}",
          );
        }
      } else {
        t.cancel();
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      t.cancel();
      buildDialog(
        _formEleKey.currentContext,
        'Failed to connect to server, Please check your internet Connection',
      );
    }
  }

  _processTransactionMeter(
    int paymentMode,
    String decoderNumber,
    String tvProvider,
    String customerCategory,
    String accountName,
    String amount,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    String merchantSecret = 'CZKGZ9JO2T4VG4ODPMZF';
    String stringToHash =
        '$decoderNumber${accountName}PREPAID${tvProvider}TUMIA_APPPAYBILL$senderPhone${reference}${amount}UGXUGATUMIAWALLET';
    var key = utf8.encode(merchantSecret);
    var bytes = utf8.encode(stringToHash);

    var hmacSha512 = Hmac(sha512, key);
    Digest sha512Result = hmacSha512.convert(bytes);
    Map data = {
      'customerName': accountName,
      'tranAmount': amount,
      'customerCategory': customerCategory,
      'transactionType': 'PAYBILL',
      'customerType': 'PREPAID',
      'tranCharge': pivotTranCharge,
      'checkoutMode': 'TUMIAWALLET',
      'customerPhoneNumber': senderPhone,
      'billerCode': tvProvider,
      'countryCode': 'UGA',
      'agentId': senderPhone,
      'servicefee': serviceFee,
      'customerReference': decoderNumber,
      'addendum': authCode,
      'paymentDate': formatted,
      'currency': 'UGX',
      'merchantCode': 'TUMIA_APP',
      'merchantPassword': 'EVJ7O9V6Q6',
      'merchantTranReference': reference,
      'commonReference': reference,
      'requestReference': reference,
      'requestSignature': base64.encode(sha512Result.bytes),
    };

    String auth = stringToBase64.encode('admin:secret123');
    try {
      final response = await http.post(
        Uri.parse('${billPayments}postTransaction'),
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
          txnReference = responseResult['pivotTranReference'].toString();
          switch (paymentMode) {
            case 0:
              // ignore: use_build_context_synchronously
              _logResponseUtilityMeter(
                'SUCCESS',
                reference,
                txnReference,
              );
              break;
            default:
              // ignore: use_build_context_synchronously
              _logResponseMeter(
                responseMessage,
                pivotReference,
                telecomRef,
                reference,
                accountName,
              );
              break;
          }
        } else {
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['statusDescription']}",
          );
        }
      } else {
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Please check your Internet Connection',
      );
    }
  }

  _logResponseMeter(
    String tranMessage,
    String pivotReference,
    String telecomId,
    String reference,
    String customerName,
  ) async {
    Map data = {
      'reference': reference,
      'pivot_ref': pivotReference,
      'telecom_ref': telecomId,
      'bill_utility': billUtility,
      'response_message': tranMessage,
      'credit': "false",
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        final responseResult = jsonDecode(response.body);
        final responseStatus = responseResult['success'];
        if (responseStatus == true) {
          // ignore: use_build_context_synchronously
          _updateBalanceMeter(
            responseResult['accountBalance'].toString(),
            utility,
          );
        } else {
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        final responseResult = jsonDecode(response.body);
        final responseStatus = responseResult['success'];
        if (responseStatus == true) {
          // ignore: use_build_context_synchronously
          _updateBalanceMeter(
            responseResult['accountBalance'].toString(),
            utility,
          );
        } else {
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formEleKey.currentContext,
          'Failed to connect to Server, Please check your internet Connection',
        );
      }
    }
  }

  _updateBalanceMeter(String balance, String utility) async {
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
          body: "Your $utility payment was successful",
          templateId: 2,
          imgUrl: AppImages.dstv,
        ),
      ),
    );
  }

  _logResponseUtilityMeter(
    String tranMessage,
    String reference,
    String pivotReference,
  ) async {
    Map data = {
      'reference': reference,
      'response_message': tranMessage,
      'pivot_ref': pivotReference,
      'bill_utility': billUtility,
      'credit': "false",
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          // ignore: use_build_context_synchronously
          _updateBalanceMeter(
            responseResult['accountBalance'].toString(),
            utility,
          );
        } else {
          setState(() {
            ignoreTaps = false;
          });
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Please check your Internet Connection',
      );
    }
  }

  _logTransaction(int paymentMode) async {
    final progress = ProgressHUD.of(_formEleKey.currentContext);
    progress.showWithText('Logging Transaction...');
    setState(() {
      ignoreTaps = true;
    });

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    String paymentMobileNetwork;
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
      paymentMobileNetwork = 'AIRTEL';
    } else {
      paymentMobileNetwork = 'MTN';
    }
    switch (paymentMode) {
      case 0:
        paymentNetwork = 'WALLET';
        paymentMobileNetwork = 'TUMIA WALLET';
        break;
      case 1:
        paymentNetwork = 'CARD';
        paymentMobileNetwork = 'CARD';
        break;
      case 2:
        paymentNetwork = 'MOBILE MONEY';
        break;
    }
    reference = reference + prefs.getString('userName').toUpperCase();
    Map data = {
      'phone': senderPhone,
      'amount': _amountController.text,
      'channel': 'RETAIL_APP',
      'service': 'BILL PAYMENT',
      'payment_method': paymentNetwork,
      'payee': recipientPhone,
      'bill_utility': billUtility,
      'username': prefs.getString('userName'),
      'customer_name': utility,
      'service_provider': paymentMobileNetwork,
      'app_version': version,
      'reference': reference,
      'narration': utility
      //'TUMIA PESA : You have paid UGX.${_amountController.text} to $utility trans Ref. $reference on $formatted via $paymentNetwork payments.',
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
              _topUpCollection(formatted, paymentMobileNetwork, paymentMode);
              break;
            case 0:
              _processTransaction(paymentMode);
              // ignore: use_build_context_synchronously
              Navigator.push(
                _formEleKey.currentContext,
                PageRouter.fadeScale(
                  () => HomePage(),
                ),
              );
              break;
            case 1:
              timer = Timer.periodic(
                Duration(seconds: 5),
                (Timer t) => _checkStatusCard(t, reference, paymentMode),
              );
              // ignore: use_build_context_synchronously
              Navigator.push(
                _formEleKey.currentContext,
                PageRouter.fadeScale(
                  () => CardPayment(
                    '$cardPayment$reference&customerReference=${_phoneNumberController.text}&itempaidfor=FUNDWALLET&tranamount=${_amountController.text}&usercurrency=${_currencyController.text}&phoneNumber=${_phoneNumberController.text}&email=support@pivotpayts.com&tranId=$reference&password=EVJ7O9V6Q6&vendorKey=KVZQK4ZS7G2B29051EQ9&returnUrl=https%3A%2F%2Fpivotpayts.com%2F&pivotId=$reference&requestSignature=testSignature&redirectUrl=https%3A%2F%2Fpivotpayts.com%2Ftestreturn.php',
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

          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Internet, Please check your Internet Connecion',
      );
    }
  }

  _topUpCollection(String _date, String telecom, int paymentMode) async {
    final progress = ProgressHUD.of(_formEleKey.currentContext);
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
      'addendum3': 'BILL PAYMENT',
      'paymentDate': _date,
      'password': 'EVJ7O9V6Q6',
      'tranSignature': 'testSignature',
      'vendorCode': 'TUMIA_APP',
      'telecom': telecom,
      'commonReference': reference,
      'vendorTranId': reference,
      'tranNarration': utility,
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
            _formEleKey.currentContext,
            "${responseResult['statusDesc']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.body}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(_formEleKey.currentContext,
          'Failed to Connect to Server, Please check your internet Connection');
    }
  }

  _collectionPromptDialog(String phone) {
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
        if (t.tick < 90) {
          if (responseStatus == 'SUCCESS') {
            t.cancel();
            responseMessage = responseResult['tran_status'].toString();
            pivotTranRef = responseResult['pivot_ref'].toString();
            telecomRef = responseResult['telecom_id'].toString();
            _processTransaction(paymentMode);
          }
          if (responseStatus == 'FAILED') {
            setState(() {
              ignoreTaps = false;
            });
            t.cancel();
            buildDialog(
              _formEleKey.currentContext,
              "${responseResult['reason']}",
            );
          }
        } else {
          setState(() {
            ignoreTaps = false;
          });
          t.cancel();
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Utility Payment',
            channelDescription: 'Utility Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Utility Payment Notification',
            'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
            platformChannelSpecifics,
            payload: 'data',
          );
        }
      } else {
        setState(() {
          ignoreTaps = false;
        });
        t.cancel();
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      t.cancel();
      buildDialog(
        _formEleKey.currentContext,
        'Failed to connect to Server, Please check your Internet Connection',
      );
    }
  }

  _processTransaction(int paymentMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'meternumber': _meterNumberController.text,
      'amount': _amountController.text,
      'channel': 'tumiaApp',
      'merchant': 'WENReCo',
      'checkoutmode': 'TUMIAWALLET',
      'phonenumber': recipientPhone,
      'jwdata': jwdata,
      'agentId': senderPhone,
      'appVersion': version,
      'commonReference': reference,
      'createdby': 'tumiaApp',
    };
    try {
      String auth = stringToBase64.encode('admin:secret123');
      final response = await http.post(
        Uri.parse('${wenreco}logTransaction'),
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
          _updatePayment(txnReference, reference, paymentMode);
        } else {
          setState(() {
            ignoreTaps = false;
          });
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(
          _formEleKey.currentContext,
          'Server error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Please check your internet Connection',
      );
    }
  }

  _updatePayment(
      String vendorTranId, String tranReference, int paymentMode) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'amount': _amountController.text,
      'commonReference': tranReference,
      'external_ref': vendorTranId,
      'status': 'SUCCESS',
      'network': ''
    };
    try {
      String auth = stringToBase64.encode('admin:secret123');
      final response = await http.post(
        Uri.parse('${wenreco}updateTransaction'),
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
          powerToken = responseResult['powerToken'].toString();
          units = responseResult['powerUnits'].toString() +
              responseResult['measurementUnits'].toString();
          userType = responseResult['userType'].toString();
          electricityFee = responseResult['electricityFee'].toString();
          taxFee = responseResult['taxFee'].toString();
          serviceFee = responseResult['serviceFee'].toString();
          meter_name = responseResult['userName'].toString();

          switch (paymentMode) {
            case 0:
              _logResponseUtility(
                'SUCCESS',
                reference,
                powerToken,
                units,
                userType,
                electricityFee,
                taxFee,
                serviceFee,
                meter_name,
              );
              break;
            default:
              _logResponse(
                  responseMessage,
                  pivotReference,
                  telecomRef,
                  reference,
                  powerToken,
                  units,
                  userType,
                  electricityFee,
                  taxFee,
                  serviceFee,
                  meter_name);
              break;
          }
        }
        if (responseStatus == 'FAILED') {
          setState(() {
            ignoreTaps = false;
          });
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['reason']}",
          );
        }
      } else {
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Please check your Internet Connection',
      );
    }
  }

  _logResponse(
    String tranMessage,
    String pivotReference,
    String telecomId,
    String reference,
    String powerToken,
    String units,
    String userType,
    String electricityFee,
    String taxFee,
    String serviceFee,
    String meterName,
  ) async {
    Map data = {
      'reference': reference,
      'pivot_ref': pivotReference,
      'telecom_ref': telecomId,
      'response_message': tranMessage,
      'credit': "false",
      'merchant': utility,
      'power_token': powerToken,
      'user_type': userType,
      'bill_utility': billUtility,
      'units': units,
      'tax_fee': taxFee,
      'electricity_fee': electricityFee,
      'service_fee': serviceFee,
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          _updateBalance(responseResult['accountBalance'].toString());
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            PageRouter.fadeScale(
              () => TransactionSuccessPage(
                body: 'Your Metre token is: $powerToken',
                templateId: 4,
              ),
            ),
          );
        } else {
          setState(() {
            ignoreTaps = false;
          });
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      buildDialog(
        _formEleKey.currentContext,
        'Failed to Connect to Server, Please check your internet Connection',
      );
    }
  }

  _checkStatusCard(Timer t, String vendorTranId, int paymentMode) async {
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
        if (t.tick < 90) {
          if (responseStatus == 'SUCCESS') {
            setState(() {
              ignoreTaps = false;
            });
            t.cancel();
            _processTransaction(paymentMode);
          }
          if (responseStatus == 'FAILED') {
            setState(() {
              ignoreTaps = false;
            });
            t.cancel();
            buildDialog(
              _formEleKey.currentContext,
              "${responseResult['reason']}",
            );
          }
        } else {
          setState(() {
            ignoreTaps = false;
          });
          t.cancel();
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0002',
            'Utility Payment',
            channelDescription: 'Utility Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Utility Payment Notification',
            'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
            platformChannelSpecifics,
            payload: 'data',
          );
        }
      } else {
        setState(() {
          ignoreTaps = false;
        });
        t.cancel();
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      t.cancel();
      buildDialog(
        _formEleKey.currentContext,
        'Failed to connect to Server, Please check Internet Connectio',
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
          body: 'Your Metre token is: $powerToken',
          templateId: 4,
        ),
      ),
    );
  }

  _logResponseUtility(
    String tranMessage,
    String reference,
    String powerToken,
    String units,
    String userType,
    String electricityFee,
    String taxFee,
    String serviceFee,
    String meterName,
  ) async {
    Map data = {
      'reference': reference,
      'response_message': tranMessage,
      'credit': "false",
      'merchant': utility,
      'power_token': powerToken,
      'bill_utility': billUtility,
      'user_type': userType,
      'units': units,
      'wallet_log_token': "true",
      'tax_fee': taxFee,
      'electricity_fee': electricityFee,
      'service_fee': serviceFee,
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}log_response.php'), body: data);
      if (response.statusCode == 200) {
        print(response.body);
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          _updateBalance(responseResult['accountBalance'].toString());
        } else {
          buildDialog(
            _formEleKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formEleKey.currentContext,
          'Server Error, Response Code ${response.statusCode}',
        );
      }
    } catch (e) {
      buildDialog(
        _formEleKey.currentContext,
        'Failed to connect to Server, Please check your Internet Connection' +
            e.toString(),
      );
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
              _formEleKey.currentContext,
              'Currency $currencyCode is not Supported',
            );
          } else {
            _translatedAmountController.value =
                TextEditingValue(text: '$currencyCode : ');
          }
        }
      } else {
        buildDialog(_formEleKey.currentContext,
            'Server Error, Response Code ${response.statusCode}');
      }
    } catch (e) {
      StylishDialog(
        context: _formEleKey.currentContext,
        alertType: StylishDialogType.ERROR,
        titleText: 'Sorry',
        dismissOnTouchOutside: false,
        confirmButton: ElevatedButton(
          onPressed: () {
            Navigator.pop(_formEleKey.currentContext);
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

class NationalWaterLocations extends StatelessWidget {
  final List<Bill> waterBills;
  String customerCode;
  NationalWaterLocations({this.waterBills});
  @override
  Widget build(BuildContext context) {
    return DropDownTextInputField(
        labelText: 'Select Location',
        isOnboardingField: true,
        onSaved: (value) {
          customerCode = value.value;
          ElectricityPage.of(context).myCustomerCode = customerCode;
        },
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          ...List.generate(
            waterBills.length,
            (i) => DropDownItem(
              imgUrl: 'assets/images/nwsc.png',
              title: waterBills[i].biller_name,
              value: waterBills[i].biller_category,
            ),
          )
        ]);
  }
}
