import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tumiapesa/utils/apis.dart';
import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/views/sendmoney/bankaccount/recipient_details.dart';
import 'package:tumiapesa/views/sendmoney/sendmoney.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class BeneficiariesPage extends StatefulWidget {
  @override
  _BeneficiariesPageState createState() => _BeneficiariesPageState();
}

class _BeneficiariesPageState extends State<BeneficiariesPage> {
  List beneficiaries = [];
  bool ignoreTaps = false;
  String _accountNumber, _userName, _noBeneficiaries = '';
  final _transactionsKey = GlobalKey<FormState>();

  Timer timer;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getBeneficiaries();
  }

  _getBeneficiaries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _accountNumber = prefs.getString('accountNumber');
      _userName = prefs.getString('userName');
      ignoreTaps = true;
    });
    final progress = ProgressHUD.of(_transactionsKey.currentContext);
    progress.showWithText('Loading....');
    try {
      final Map data = {'username': _userName, 'account_no': _accountNumber};
      final response =
          await http.post(Uri.parse('${tumiaApi}pull.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          final beneficiariesArray = jsonDecode(response.body)['recipients'];
          setState(() {
            ignoreTaps = false;
            ProgressHUD.of(_transactionsKey.currentContext).dismiss();
            beneficiaries = beneficiariesArray as List;
          });
        } else {
          setState(() {
            beneficiaries = [];
            _noBeneficiaries = 'No Beneficiaries';
            ProgressHUD.of(_transactionsKey.currentContext).dismiss();

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
              },
              child: SmallText(
                'Okay',
              ),
            ),
            animationLoop: true,
            contentText: responseResult["recipients"].toString(),
          ).show();
        }
      } else {
        setState(() {
          beneficiaries = [];
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
            },
            child: SmallText(
              'Okay',
            ),
          ),
          animationLoop: true,
          contentText: 'Server Error, Response Code ${response.statusCode}',
        ).show();
      }
    } catch (e) {
      setState(() {
        ignoreTaps = false;
      });
      ProgressHUD.of(_transactionsKey.currentContext).dismiss();
      StylishDialog(
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
        contentText:
            'Failed to Connect to Server, Check your internet connection',
      ).show();
    }
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
        appBar: customAppbar(context, title: 'Beneficiaries'),
        body: IgnorePointer(
          ignoring: ignoreTaps,
          child: ProgressHUD(
            child: beneficiaries.isEmpty
                ? Center(
                    key: _transactionsKey, child: MediumText(_noBeneficiaries))
                : ListView(
                    key: _transactionsKey,
                    children: List.generate(beneficiaries.length, (i) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                        child: beneficiaries[i]['name'].toString().isNotEmpty
                            ? _BeneficiaryWidget(
                                name: beneficiaries[i]['name'].toString(),
                                accountNumber:
                                    beneficiaries[i]['phone'].toString(),
                              )
                            : null,
                      );
                    }),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BeneficiaryWidget extends StatelessWidget {
  final String name, accountNumber;
  _BeneficiaryWidget({
    this.name,
    this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 80,
      margin: EdgeInsets.only(bottom: Insets.md),
      padding: EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFFAFAFA),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            LocalImage(
              AppIcons.icon,
              height: 30,
            ),
            HSpace.md,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VSpace.xs,
                MediumText(name),
                SmallText(accountNumber),
              ],
            )
          ],
        ),
        // LocalImage(
        //   AppIcons.trash,
        //   height: 18,
        // ),
      ]),
    ).onTap(
      () => Navigator.push(
        context,
        PageRouter.fadeScale(
          () => SendMoneyPage(custName: name, custNumber: accountNumber),
        ),
      ),
    );
  }
}
