// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/models/bills.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tumiapesa/storage/database_helper.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/debitcard/debit_card.dart';
import 'package:tumiapesa/views/debitcard/web_view.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/pin/pin.dart';
import 'package:tumiapesa/views/sendmoney/mobilemoney/mobile_money.dart';
import 'package:tumiapesa/views/sendmoney/select_payment_method.dart';
import 'package:tumiapesa/views/transactions/transaction_success.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class TvPackagesPage extends StatefulWidget {
  String tvCustomerCode, decoderNumber, tvProvider, tvProviderImg;

  TvPackagesPage(this.tvCustomerCode, this.decoderNumber, this.tvProvider,
      this.tvProviderImg);

  @override
  _TvPackagesPageState createState() => _TvPackagesPageState();
}

class _TvPackagesPageState extends State<TvPackagesPage> {
  DatabaseHandler handler;
  List<Bill> packages;
  int packageSize = 0;
  String senderPhone,
      txnCharge,
      reference,
      version,
      pivotReference,
      pivotTranRef,
      totalAmount,
      telecomRef,
      responseMessage,
      utility,
      txnReference,
      authCode,
      powerToken,
      units,
      dealer,
      agent,
      pivot,
      userType,
      electricityFee,
      taxFee,
      serviceFee,
      pivotServiceFee,
      pivotTranCharge;

  String currencyCode, convertedAmount;
  final _formTvKey = GlobalKey<FormState>();
  Timer timer;
  MoneyInputFormatter moneyInputFormatter = MoneyInputFormatter();
  bool ignoreTaps = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      version = '${value.version}+${value.buildNumber}';
      _getBills();
    });
  }

  _getBills() async {
    handler = DatabaseHandler();
    await handler.activeBill(widget.tvCustomerCode).then((value) {
      setState(() {
        packageSize = value.length;
        packages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Dstv Packages'),
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Form(
              key: _formTvKey,
              child: ListView(
                children: List.generate(
                  packageSize,
                  (index) => _PackageItem(
                    name: packages.elementAt(index).biller_name,
                    amount: packages.elementAt(index).biller_amount,
                    imgUrl: widget.tvProviderImg,
                    customerCode: packages.elementAt(index).biller_category,
                    tvProvider: widget.tvProvider,
                    conext: _formTvKey.currentContext,
                    decoderNumber: widget.decoderNumber,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  validateDecoder(
    String amount,
    String customerCode,
    String tvProvider,
    String decoderNumber,
    BuildContext context,
    int paymentMode,
    String package,
  ) async {
    final progress = ProgressHUD.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    progress.showWithText('Verifying Decoder Number...');
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
      'amount': '500',
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
          _showDialog(
            decoderNumber,
            outstanding,
            responseResult['customerName'].toString(),
            context,
            paymentMode,
            amount,
            tvProvider,
            package,
            customerCode,
          );
        } else {
          //progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });
          buildDialog(
            _formTvKey.currentContext,
            "${responseResult['responseDescription']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(
          _formTvKey.currentContext,
          'Fund Account failed ${response.body}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
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

  _showDialog(
    String decoderNumber,
    String balance,
    String accountName,
    BuildContext currentContext,
    int paymentMode,
    String amount,
    String utility,
    String package,
    String customerCode,
  ) {
    showDialog(
      context: currentContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Decoder Verification',
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
                          'Confirm payment for: Decoder number $decoderNumber username: $accountName and outstanding balance of UGX. $balance',
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
                            Navigator.pop(context);
                            _logTransaction(
                                paymentMode,
                                accountName,
                                amount,
                                utility,
                                package,
                                decoderNumber,
                                customerCode,
                                currentContext);
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

  _logTransaction(
      int paymentMode,
      String customerName,
      String amount,
      String utility,
      String package,
      String decoderNumber,
      String customerCode,
      BuildContext currentContext) async {
    final progress = ProgressHUD.of(currentContext);
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
        paymentNetwork = 'WALLET PAYMENT';
        break;
      case 1:
        paymentNetwork = 'CARD PAYMENT';
        break;
      case 2:
        paymentNetwork = 'SEND MONEY';
        break;
    }
    reference = reference + prefs.getString('userName').toUpperCase();
    Map data = {
      'phone': senderPhone,
      'amount': '500',
      'channel': 'RETAIL_APP',
      'service': paymentNetwork,
      'payment_method': paymentNetwork,
      'payee': package,
      'username': prefs.getString('userName'),
      'customer_name': customerName,
      'service_provider': paymentNetwork,
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
              _topUpCollection(
                  formatted,
                  paymentMobileNetwork,
                  paymentMode,
                  amount,
                  utility,
                  decoderNumber,
                  customerName,
                  customerCode,
                  currentContext);
              break;
            case 0:
              // ignore: use_build_context_synchronously
              _logResponseWallet(
                reference,
                prefs.get('accountNumber').toString(),
                'SUCCESS',
                paymentMode,
                decoderNumber,
                utility,
                currentContext,
                customerCode,
                amount,
                customerName,
              );
              break;
            case 1:
              timer = Timer.periodic(
                Duration(seconds: 5),
                (Timer t) => _checkStatusCard(
                  t,
                  reference,
                  paymentMode,
                  decoderNumber,
                  amount,
                  utility,
                  customerName,
                  customerCode,
                  currentContext,
                ),
              );
              // ignore: use_build_context_synchronously
              Navigator.push(
                currentContext,
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
            _formTvKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(
          _formTvKey.currentContext,
          'Logging Transaction failed ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _checkStatusCard(
    Timer t,
    String vendorTranId,
    int paymentMode,
    String decoderNumber,
    String amount,
    String utility,
    String customerName,
    String customerCode,
    BuildContext currentContext,
  ) async {
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
          // ignore: use_build_context_synchronously
          _processTransaction(
            paymentMode,
            decoderNumber,
            utility,
            customerCode,
            customerName,
            amount,
            currentContext,
          );
        }
        if (responseStatus == 'FAILED') {
          t.cancel();
          buildDialog(
            _formTvKey.currentContext,
            "${responseResult['reason']}",
          );
        }
      } else {
        t.cancel();
        WidgetsFlutterBinding.ensureInitialized();
        await NotificationService().init();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          '0004',
          'Tv Payment',
          channelDescription: 'Tv Channel',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        const int MAX = 1000000;
        final int randomNumber = Random().nextInt(MAX);
        await FlutterLocalNotificationsPlugin().show(
          randomNumber,
          'Tv Payment Notification',
          'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
          platformChannelSpecifics,
          payload: 'data',
        );
      }
    } else {
      t.cancel();
      buildDialog(
        _formTvKey.currentContext,
        'Response Time out',
      );
    }
  }

  _logResponseWallet(
    String reference,
    String accountNumber,
    String tranMessage,
    int paymentMode,
    String decoderNumber,
    String utility,
    BuildContext currentContext,
    String customerCode,
    String amount,
    String accountName,
  ) async {
    final progress = ProgressHUD.of(currentContext);
    progress.showWithText('Processing Wallet Transaction...');
    setState(() {
      ignoreTaps = true;
    });
    Map data = {
      'reference': reference,
      'accountNumber': accountNumber,
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
          // ignore: use_build_context_synchronously
          _processTransaction(
            paymentMode,
            decoderNumber,
            utility,
            customerCode,
            accountName,
            amount,
            currentContext,
          );
        } else {
          buildDialog(
            _formTvKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formTvKey.currentContext,
          'Sending Money Failed ${response.statusCode}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _topUpCollection(
    String _date,
    String telecom,
    int paymentMode,
    String amount,
    String utility,
    String decoderNumber,
    String accountName,
    String customerCategory,
    BuildContext currentContext,
  ) async {
    final progress = ProgressHUD.of(currentContext);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    progress.showWithText('Initiating Collection Request..');
    setState(() {
      ignoreTaps = true;
    });
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    Map data = {
      'accountNumber': senderPhone,
      'tranAmount': '500',
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
            (Timer t) => _checkStatus(
              t,
              reference,
              pivotReference,
              paymentMode,
              decoderNumber,
              amount,
              utility,
              accountName,
              customerCategory,
              currentContext,
            ),
          );
          _collectionPromptDialog(senderPhone, currentContext);
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });
          buildDialog(
            _formTvKey.currentContext,
            "${responseResult['statusDesc']}",
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(
          _formTvKey.currentContext,
          'Sending Money Failed ${response.body}',
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _collectionPromptDialog(String phone, BuildContext currentContext) {
    showDialog(
      context: currentContext,
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

  _checkStatus(
    Timer t,
    String vendorTranId,
    String tranReference,
    int paymentMode,
    String decoderNumber,
    String amount,
    String tvProvider,
    String accountName,
    String customerCategory,
    BuildContext currentContext,
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
        if (t.tick < 90) {
          if (responseStatus == 'SUCCESS') {
            t.cancel();
            responseMessage = responseResult['tran_status'].toString();
            pivotTranRef = responseResult['pivot_ref'].toString();
            telecomRef = responseResult['telecom_id'].toString();
            _processTransaction(paymentMode, decoderNumber, tvProvider,
                customerCategory, accountName, amount, currentContext);
          }
          if (responseStatus == 'FAILED') {
            t.cancel();
            buildDialog(
              _formTvKey.currentContext,
              "${responseResult['reason']}",
            );
          }
        } else {
          t.cancel();
          WidgetsFlutterBinding.ensureInitialized();
          await NotificationService().init();

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            '0004',
            'Tv Payment',
            channelDescription: 'Tv Channel',
          );

          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          const int MAX = 1000000;
          final int randomNumber = Random().nextInt(MAX);
          await FlutterLocalNotificationsPlugin().show(
            randomNumber,
            'Tv Payment Notification',
            'Please note that your transaction is being processed, Incase there is a delay kindly Contact Customer Support',
            platformChannelSpecifics,
            payload: 'data',
          );
        }
      } else {
        t.cancel();
        buildDialog(
          _formTvKey.currentContext,
          'Collection failed ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _processTransaction(
      int paymentMode,
      String decoderNumber,
      String tvProvider,
      String customerCategory,
      String accountName,
      String amount,
      BuildContext currentContext) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    String merchantSecret = 'CZKGZ9JO2T4VG4ODPMZF';
    String stringToHash =
        '$decoderNumber${accountName}PREPAID${tvProvider}TUMIA_APPPAYBILL$senderPhone${reference}135000UGXUGATUMIAWALLET';
    print(stringToHash);
    var key = utf8.encode(merchantSecret);
    var bytes = utf8.encode(stringToHash);

    var hmacSha512 = Hmac(sha512, key);
    Random random = Random();
    Digest sha512Result = hmacSha512.convert(bytes);
    Map data = {
      'customerName': accountName,
      'tranAmount': '135000',
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
      'requestReference': random.nextInt(100).toString() + reference,
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
              _logResponseUtility(
                'SUCCESS',
                reference,
                txnReference,
                currentContext,
              );
              break;
            default:
              // ignore: use_build_context_synchronously
              _logResponse(
                responseMessage,
                pivotReference,
                telecomRef,
                reference,
                accountName,
                currentContext,
              );
              break;
          }
        } else {
          buildDialog(
            _formTvKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formTvKey.currentContext,
          'Utility Payment Failed ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _logResponse(
    String tranMessage,
    String pivotReference,
    String telecomId,
    String reference,
    String customerName,
    BuildContext currentContext,
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
        final responseResult = jsonDecode(response.body);
        final responseStatus = responseResult['success'];
        if (responseStatus == true) {
          // ignore: use_build_context_synchronously
          _updateBalance(
            responseResult['accountBalance'].toString(),
            currentContext,
          );
        } else {
          buildDialog(
            _formTvKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formTvKey.currentContext,
          'Sending Money Failed ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }

  _updateBalance(String balance, BuildContext currentContext) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
      'accountBalance',
      balance,
    );
    // ignore: use_build_context_synchronously
    Navigator.push(
      currentContext,
      PageRouter.fadeScale(
        () => TransactionSuccessPage(
          body: "Your Dstv subscription was successful",
          templateId: 4,
          imgUrl: AppImages.dstv,
        ),
      ),
    );
  }

  _logResponseUtility(
    String tranMessage,
    String reference,
    String pivotReference,
    BuildContext currentContext,
  ) async {
    Map data = {
      'reference': reference,
      'response_message': tranMessage,
      'pivot_ref': pivotReference,
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
          _updateBalance(
            responseResult['accountBalance'].toString(),
            currentContext,
          );
        } else {
          buildDialog(
            _formTvKey.currentContext,
            "${responseResult['message']}",
          );
        }
      } else {
        buildDialog(
          _formTvKey.currentContext,
          'Sending Money Failed ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(
        _formTvKey.currentContext,
        'Failed to Connect to Server, Check your internet connection',
      );
    }
  }
}

class _PackageItem extends StatelessWidget {
  final String name, amount, imgUrl, customerCode, decoderNumber, tvProvider;
  BuildContext conext;
  _PackageItem({
    this.name,
    this.amount,
    this.imgUrl,
    this.customerCode,
    this.decoderNumber,
    this.tvProvider,
    this.conext,
  });

  _TvPackagesPageState _tvPackagesPageState = _TvPackagesPageState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      margin: EdgeInsets.only(
        top: Insets.xs,
        bottom: Insets.xs,
        left: Insets.lg,
        right: Insets.lg,
      ),
      padding: EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFFAFAFA),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalImage(
                  imgUrl,
                  fit: BoxFit.contain,
                  height: 24,
                  width: 44,
                ),
                SmallText(name),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SmallText(amount),
              Icon(
                PhosphorIcons.caretRight,
                color: Colors.black,
              )
            ],
          ),
        ],
      ),
    ).onTap(() async {
      final paymentMethod = Navigator.push<PaymentMethod>(
        context,
        PageRouter.fadeThrough(
          () => SelectPaymentMethodPage(),
        ),
      );

      paymentMethod.then((value) {
        final int paymentMode = value.id;
        if (value.id == 1) {
          _tvPackagesPageState.validateDecoder(
            amount,
            customerCode,
            tvProvider,
            decoderNumber,
            context,
            paymentMode,
            name,
          );
        } else if (value.id == 2) {
          _tvPackagesPageState.validateDecoder(
            amount,
            customerCode,
            tvProvider,
            decoderNumber,
            context,
            paymentMode,
            name,
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
                _tvPackagesPageState.validateDecoder(
                  amount,
                  customerCode,
                  tvProvider,
                  decoderNumber,
                  context,
                  paymentMode,
                  name,
                );
              }
            },
          );
        }
      });
    });
  }
}
