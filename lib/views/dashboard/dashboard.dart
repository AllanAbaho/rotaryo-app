import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/models/bills.dart';
import 'package:tumiapesa/storage/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/beneficiaries/beneficiaries.dart';
import 'package:tumiapesa/views/fundaccount/fund_account.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/marketplace/electricity/electricity.dart';
import 'package:tumiapesa/views/marketplace/mobiletopup/mobile_topup.dart';
import 'package:tumiapesa/views/marketplace/payloan/pay_load.dart';
import 'package:tumiapesa/views/marketplace/paytv/pay_tv.dart';
import 'package:tumiapesa/views/sendmoney/sendmoney.dart';
import 'package:tumiapesa/widgets/avatar.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/text.dart';

// ignore: avoid_implementing_value_types
class DashboardPage extends StatefulWidget implements HomeWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();

  @override
  String get tag => 'Tumia Pesa';
}

class _DashboardPageState extends State<DashboardPage> {
  String _email,
      _secondName,
      _accountNumber,
      _accountBalance,
      _profilePicture,
      _userName,
      _imgStamp,
      _currency;

  List bills = [];

  Timer timer;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ignore: prefer_final_fields
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  DatabaseHandler handler;

  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    _getSessionValues();
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _onLoading();
  }

  _getSessionValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _email = prefs.getString('email');
    });
    print(prefs.get('email'));

    // _pullBills();
  }

  _pullBills() async {
    final response = await http.post(Uri.parse('${tumiaApi}pull_bills.php'));
    if (response.statusCode == 200) {
      var billsArray = jsonDecode(response.body)['bills'];
      bills = billsArray as List;
      _addBill(bills);
    } else {
      bills = [];
    }
  }

  _addBill(List _bills) async {
    handler.deleteBills();
    String str;
    for (int index = 0; index < _bills.length; index++) {
      str = _bills[index]['bill_amount'].toString();
      if ((str.length > 3)) {
        str = str.substring(0, str.length - 2);
      }
      Bill bill = Bill(
        biller_code: _bills[index]['biller_id'].toString(),
        biller_name: _bills[index]['bill_name'].toString(),
        biller_category: _bills[index]['bill_category'].toString(),
        biller_amount: str,
      );
      handler.insertBill(bill);
    }
  }

  _onLoading() async {
    Map data = {'username': _accountNumber};
    final response =
        await http.post(Uri.parse('${citrusBridgeApi}QueryWalletBalance'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data));
    if (response.statusCode == 200) {
      var responseResult = jsonDecode(response.body);
      var responseStatus = responseResult['status'];
      if (responseStatus == 'SUCCESS') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('accountBalance',
            responseResult['balance'].toString().replaceAll(',', ''));
        _refreshController.refreshCompleted();

        setState(() {
          _accountBalance =
              responseResult['balance'].toString().replaceAll(',', '');
        });
      } else {
        _refreshController.refreshFailed();
      }
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
          body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Column(
              children: [
                VSpace.md,
                Row(
                  children: [
                    Avatar(
                      imgUrl: "$tumiaApi$_profilePicture",
                    ),
                    HSpace.md,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SmallText('Welcome back ✋🏽'),
                        MediumText(_email)
                      ],
                    )
                  ],
                ),
                VSpace.lg,
                // BalanceWidget(_accountNumber, _accountBalance),
                // VSpace.lg,
                // Container(
                //   width: context.width,
                //   height: 240,
                //   clipBehavior: Clip.hardEdge,
                //   decoration: BoxDecoration(
                //     color: AppColors.scaffoldColor,
                //     borderRadius: BorderRadius.circular(18),
                //   ),
                //   child: FittedBox(
                //     fit: BoxFit.fill,
                //     child: Image.asset(AppImages.xmas),
                //   ),
                // ),
                VSpace.lg,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            PageRouter.fadeScale(
                              () => SendMoneyPage(),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                AssetImage(AppIcons.send),
                                color: Color(0xAAFFB800),
                              ),
                              HSpace.xs,
                              MediumText('Send Money'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    HSpace.md,
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            PageRouter.fadeScale(
                              () => BeneficiariesPage(),
                            ),
                          ),
                          child: MediumText('Beneficiaries'),
                        ),
                      ),
                    ),
                  ],
                ),
                VSpace.md,
                SizedBox(
                  height: 54,
                  width: context.width,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      PageRouter.fadeThrough(
                        () => FundAccountPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(primary: Color(0xFFE1E1E1)),
                    child: MediumText('Fund account', color: Colors.black),
                  ),
                ),
                VSpace.lg,
                Visibility(
                  visible: isVisible,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: MediumText('Marketplace'),
                      ),
                      VSpace.md,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MarketplaceWidget(
                            label: 'Utilities',
                            color: AppColors.primaryColor,
                            img: AppIcons.utilities,
                            onTap: () => Navigator.push(
                              context,
                              PageRouter.fadeThrough(
                                () => ElectricityPage(),
                              ),
                            ),
                          ),
                          MarketplaceWidget(
                            label: 'Pay TV',
                            color: AppColors.primaryColor,
                            img: AppIcons.tv,
                            onTap: () => Navigator.push(
                              context,
                              PageRouter.fadeThrough(
                                () => PayTvPage(),
                              ),
                            ),
                          ),
                          // MarketplaceWidget(
                          //   label: 'Mobile\nTop-up',
                          //   color: Color(0xFFFFB800),
                          //   img: AppIcons.topup,
                          //   onTap: () => Navigator.push(
                          //     context,
                          //     PageRouter.fadeThrough(
                          //       () => MobileTopupPage(),
                          //     ),
                          //   ),
                          // ),
                          MarketplaceWidget(
                            label: 'Pay Loan',
                            color: AppColors.primaryColor,
                            img: AppIcons.loan,
                            onTap: () => Navigator.push(
                              context,
                              PageRouter.fadeThrough(
                                () => PayLoanPage(),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class BalanceWidget extends StatelessWidget {
  String _accountNumber, _accountBalance;
  BalanceWidget(this._accountNumber, this._accountBalance);
  var format = NumberFormat("###,###", "en_US");
  @override
  Widget build(BuildContext context) {
    const double _ring = 88;
    const double _contHeight = 140;
    const double _contTopMargin = 52;
    const _avatarYOffset = _contHeight - _contTopMargin + 20;
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          padding: EdgeInsets.all(7),
          height: _ring,
          width: _ring,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor,
            ),
          ),
        ),
        Container(
          width: context.width,
          height: 120,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmallText(
                'Wallet balance',
                color: AppColors.scaffoldColor,
              ),
              BigText(
                'UGX. ${format.format(int.parse(_accountBalance))}',
                color: AppColors.scaffoldColor,
                fontWeight: FontWeight.w800,
              ),
              SmallText(
                'Account Number: $_accountNumber',
                color: AppColors.scaffoldColor,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: _avatarYOffset - 5,
          left: 110,
          child: LocalImage(
            AppImages.blob1,
            height: 36,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 25,
          child: LocalImage(AppImages.blob2, height: 36),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: LocalImage(AppImages.blob3, height: 55),
        ),
      ],
    );
    // return Container(
    //   width: context.width,
    //   height: 120,
    //   decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(25),
    //       boxShadow: const [
    //         BoxShadow(
    //             color: Color(0xAACCCACA), blurRadius: 29, offset: Offset(0, 21))
    //       ]),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       SmallText('Wallet balance'),
    //       BigText(
    //         'UGX. $_accountBalance',
    //         fontWeight: FontWeight.w800,
    //       ),
    //       SmallText('Account Number: $_accountNumber'),
    //     ],
    //   ),
    // );
  }
}

class MarketplaceWidget extends StatelessWidget {
  final Color color;
  final String label, img;
  final Function onTap;
  MarketplaceWidget({@required this.label, this.img, this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          width: 70,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: Corners.lgBorder, color: Color(0xAAFAFAFA)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: ImageIcon(
                AssetImage(img),
                color: color,
              ),
            ),
          ),
        ),
        VSpace.sm,
        SmallText(label),
      ],
    ).onTap(() => onTap());
  }
}
