import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/views/transactions/receipt.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/text.dart';

// ignore: avoid_implementing_value_types
class TransactionsPage extends StatefulWidget implements HomeWidget {
  final bool showAppbar, isDrawer;
  int currentIndex;
  TransactionsPage({this.showAppbar = false, this.isDrawer = false});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();

  @override
  String get tag => "Statements";
}

class _TransactionsPageState extends State<TransactionsPage> {
  List transactions = [];
  bool ignoreTap = false;
  String _userName, _fullName, _accountNumber;

  Timer timer;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String currentMonth = DateFormat('MMMM').format(DateTime.now());
  String startDate, endDate, startMonth, endMonth;

  @override
  void initState() {
    super.initState();
    startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    endDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(const Duration(days: 7)));
    _getTransactions();
  }

  String _selectedDate = '';
  final _transactionsKey = GlobalKey();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        startDate = args.value.startDate.toString().split(' ')[0];
        endDate = args.value.endDate.toString().split(' ')[0];
        startMonth = DateFormat('MMMM').format(
            DateTime.parse(args.value.startDate.toString().split(' ')[0]));
        endMonth = DateFormat('MMMM').format(
            DateTime.parse(args.value.endDate.toString().split(' ')[0]));
        if (startMonth == endMonth) {
          currentMonth = startMonth;
        } else {
          currentMonth = '$startMonth - $endMonth';
        }
      }
    });
  }

  _getTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
      _accountNumber = prefs.getString('accountNumber');
      _fullName = prefs.getString('firstName');
      ProgressHUD.of(_transactionsKey.currentContext)
          .showWithText('loading.....');
      ignoreTap = true;
    });
    Map data = {
      'user_name': _userName,
      'startDate': startDate,
      'endDate': endDate
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}transactions.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          var transactionsArray = json.decode(response.body)['transactions'];
          setState(() {
            ProgressHUD.of(_transactionsKey.currentContext).dismiss();
            ignoreTap = false;
            transactions = transactionsArray as List;
          });
        } else {
          setState(() {
            transactions = [];
            ProgressHUD.of(_transactionsKey.currentContext).dismiss();
            ignoreTap = false;
          });
          if (widget.isDrawer) {
            buildDialog(_transactionsKey.currentContext,
                '${responseResult['transactions']} in the selected Date Range for the month $currentMonth');
          }
        }
      } else {
        setState(() {
          transactions = [];
          ProgressHUD.of(_transactionsKey.currentContext).dismiss();
          ignoreTap = false;
        });
        if (widget.isDrawer) {
          buildDialog(_transactionsKey.currentContext, response.reasonPhrase);
        }
      }
    } catch (e) {
      setState(() {
        ProgressHUD.of(_transactionsKey.currentContext).dismiss();
      });
      if (widget.isDrawer) {
        buildDialog(_transactionsKey.currentContext,
            'Failed to Connect to Server, Check your internet connection');
      }
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

  _datePickerDialog(BuildContext mContext) {
    showDialog(
      context: mContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 400,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Date Picker',
                style: TextStyle(
                  color: Color.fromRGBO(223, 32, 48, 1),
                ),
              ),
              Divider(
                color: Color.fromRGBO(223, 32, 48, 1),
              ),
              Column(
                children: [
                  SfDateRangePicker(
                    onSelectionChanged: _onSelectionChanged,
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                      DateTime.now(),
                      DateTime.now().add(const Duration(days: 7)),
                    ),
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
                            setState(() {
                              transactions.clear();
                              _getTransactions();
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
                              fontWeight: FontWeight.bold,
                            ),
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

  _checkTimer(Timer t) async {
    if (t.tick > 90) {
      t.cancel();

      WidgetsFlutterBinding.ensureInitialized();
      await NotificationService().init();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        '0005',
        'Account Notification',
        channelDescription: 'Account Notification Channel',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      const int MAX = 1000000;
      final int randomNumber = Random().nextInt(MAX);

      await flutterLocalNotificationsPlugin.show(
        randomNumber,
        'Account Notification',
        'Please note that your account has been logged out due to inactivity',
        platformChannelSpecifics,
        payload: 'data',
      );

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear();
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        PageRouter.fadeScale(() => LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        // if (timer != null) {
        //   timer.cancel();
        // }
        // timer = Timer.periodic(
        //   Duration(seconds: 5),
        //   (Timer t) => _checkTimer(t),
        // );
      },
      child: Scaffold(
        appBar: widget.showAppbar
            ? customAppbar(context, title: TransactionsPage().tag)
            : null,
        body: IgnorePointer(
          ignoring: ignoreTap,
          child: ProgressHUD(
            child: SingleChildScrollView(
              key: _transactionsKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                child: Column(
                  children: [
                    VSpace.md,
                    ElevatedButton(
                      // ignore: sort_child_properties_last
                      child: SmallText(
                        currentMonth,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _datePickerDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
                      ),
                    ),
                    VSpace.md,
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext, index) {
                        return _TransactionWidget(
                          from: '$_fullName: $_accountNumber',
                          transRef: transactions[index]['trans_ref'].toString(),
                          transType:
                              transactions[index]['trans_type'].toString(),
                          payee: transactions[index]['payee'].toString(),
                          desc: transactions[index]['narration'].toString(),
                          date: transactions[index]['payment_date'].toString(),
                          amount: transactions[index]['amount'].toString(),
                          accountNumber: _accountNumber,
                          accountName:
                              transactions[index]['customer_name'].toString(),
                          status: transactions[index]['status'].toString(),
                          alertType:
                              transactions[index]['alert_type'].toString(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionWidget extends StatelessWidget {
  final String from,
      to,
      desc,
      date,
      amount,
      transRef,
      transType,
      payee,
      accountNumber,
      accountName,
      status,
      alertType;
  final TransactionType type;
  _TransactionWidget({
    this.from,
    this.transRef,
    this.transType,
    this.payee,
    this.to,
    this.desc,
    this.date,
    this.amount,
    this.accountNumber,
    this.accountName,
    this.status,
    this.alertType,
    this.type = TransactionType.credit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouter.fadeThrough(
          () => ReceiptPage(
            from,
            to,
            desc,
            amount,
            transType,
            payee,
            transRef,
            accountNumber,
            accountName,
            date,
            alertType,
            status,
          ),
        ),
      ),
      child: Container(
        width: context.width,
        height: 100,
        margin: EdgeInsets.only(bottom: Insets.md),
        padding: EdgeInsets.all(Insets.md),
        decoration: BoxDecoration(
          borderRadius: Corners.lgBorder,
          color: Color(0xFFFAFAFA),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (alertType == 'Credit') ...[
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Color(0xFF21BC22).withOpacity(0.08),
                      borderRadius: Corners.lgBorder,
                    ),
                    child: Icon(
                      PhosphorIcons.arrowDownLeft,
                      size: 18,
                      color: Color(0xFF21BC22),
                    ),
                  ),
                  HSpace.sm,
                  Expanded(
                    child: Text(
                      '$alertType Alert',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.h3,
                    ),
                  ),
                  MediumText(
                    "+ UGX $amount",
                    color: Color(0xFF21BC22),
                  )
                ],
              ),
              VSpace.xs,
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        "from $from\ndescription: $desc",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.caption,
                      ),
                    ),
                    HSpace.sm,
                    SmallText(date)
                  ],
                ),
              )
            ] else ...[
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: Corners.lgBorder,
                    ),
                    child: Icon(
                      PhosphorIcons.arrowUpRight,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  HSpace.sm,
                  Expanded(
                    child: Text(
                      '$alertType Alert',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.h3,
                    ),
                  ),
                  MediumText(
                    '- UGX. $amount',
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
              VSpace.xs,
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        "to $payee\ndescription: $desc",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.caption,
                      ),
                    ),
                    HSpace.sm,
                    SmallText(date)
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

enum TransactionType { debit, credit }
