import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class ReceiptPage extends StatelessWidget {
  String from,
      to,
      narration,
      amount,
      transactionType,
      payee,
      transactionRef,
      accountNumber,
      accountName,
      date,
      alertType,
      status;

  ReceiptPage(
    this.from,
    this.to,
    this.narration,
    this.amount,
    this.transactionType,
    this.payee,
    this.transactionRef,
    this.accountNumber,
    this.accountName,
    this.date,
    this.alertType,
    this.status,
  );

  _checkTimer(Timer t, BuildContext buildContext) async {
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
        buildContext,
        PageRouter.fadeScale(() => LoginPage()),
        (route) => false,
      );
    }
  }

  Timer timer;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        if (timer != null) {
          timer.cancel();
        }
        timer = Timer.periodic(
          Duration(seconds: 5),
          (Timer t) => _checkTimer(t, context),
        );
      },
      child: Scaffold(
        appBar: customAppbar(context, title: 'E-Receipt'),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(Insets.lg - 8),
                margin: EdgeInsets.all(Insets.lg),
                decoration: BoxDecoration(
                    borderRadius: Corners.lgBorder, color: Color(0xAAFAFAFA)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: LocalImage(
                        AppIcons.icon,
                        height: 44,
                      ),
                    ),
                    VSpace.md,
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {},
                        clipBehavior: Clip.hardEdge,
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.primaryColor,
                            padding: EdgeInsets.zero,
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            LocalImage(AppImages.btnWave),
                            Center(
                              child: MediumText('Transfer'),
                            )
                          ],
                        ),
                      ),
                    ),
                    VSpace.lg,
                    ReceiptItem('Means', transactionType),
                    ReceiptItem('Account Number', payee),
                    ReceiptItem('Account Name', accountName),
                    ReceiptItem('Amount', 'UGX. $amount'),
                    ReceiptItem('Date', date),
                    ReceiptItem('Reason', narration),
                    ReceiptItem('Type', alertType),
                    ReceiptItem(
                        'Status', status == 'INSERTED' ? 'PENDING' : status),
                    ReceiptItem('Transaction ID/Ref', transactionRef),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Download as '),
                    TextSpan(
                        text: 'PNG',
                        style: TextStyles.h3
                            .copyWith(color: AppColors.primaryColor)),
                    TextSpan(text: ' or '),
                    TextSpan(
                        text: 'PDF',
                        style: TextStyles.h3
                            .copyWith(color: AppColors.primaryColor))
                  ],
                ),
                style: TextStyles.h3,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptItem extends StatelessWidget {
  final String k, v;
  ReceiptItem(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(k),
          Flexible(
            child: SmallText(
              v,
              fontWeight: FontW.bold,
            ),
          ),
        ],
      ),
    );
  }
}
