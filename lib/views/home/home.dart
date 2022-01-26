import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/cards/cards.dart';
import 'package:tumiapesa/views/dashboard/dashboard.dart';
import 'package:tumiapesa/views/home/bottom_bar.dart';
import 'package:tumiapesa/views/home/drawer.dart';
import 'package:tumiapesa/views/notifications/notifications.dart';
import 'package:tumiapesa/views/transactions/transactions.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';
import 'package:tumiapesa/utils/extension.dart';

abstract class HomeWidget extends Widget {
  final String tag = throw UnimplementedError();
}

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  final List<HomeWidget> _tabs = [
    DashboardPage(),
    // CardsPage(),
    TransactionsPage()
  ];

  void _openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  void changeIndex(int i) => setState(() {
        currentIndex = i;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: MediumText(
          _tabs[currentIndex].tag,
          color: Colors.black,
        ),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffoldColor,
        leading: currentIndex == 0
            ? Icon(
                PhosphorIcons.list,
                color: Colors.black,
              ).onTap(() => _openDrawer())
            : Icon(
                PhosphorIcons.caretLeft,
                color: Colors.black,
              ).onTap(() => changeIndex(0)),
        // actions: [
        //   if (currentIndex == 0)
        //     Padding(
        //       padding: const EdgeInsets.only(right: 8.0),
        //       child: Stack(
        //         alignment: AlignmentDirectional.center,
        //         // ignore: prefer_const_literals_to_create_immutables
        //         children: [
        //           ImageIcon(
        //             AssetImage(AppIcons.bell),
        //             color: Colors.black,
        //           ).onTap(
        //             () => Navigator.push(
        //               context,
        //               PageRouter.fadeThrough(
        //                 () => NotificationsPage(),
        //               ),
        //             ),
        //           ),
        //           Positioned(
        //             top: 15,
        //             right: 4,
        //             child: SizedBox(
        //               height: 5,
        //               width: 5,
        //               child: DecoratedBox(
        //                 decoration: BoxDecoration(
        //                   color: Colors.red,
        //                   shape: BoxShape.circle,
        //                 ),
        //               ),
        //             ),
        //           )
        //         ],
        //       ),
        //     )
        // ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _tabs,
      ),
      drawer: HomeDrawerPage(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        selectedColor: AppColors.primaryColor,
        unselectedColor: AppColors.greyColor2,
        items: _items,
        onTap: changeIndex,
      ),
    );
  }
}

final List<BottomBarItem> _items = [
  BottomBarItem(
    icon: LocalImage(
      AppIcons.wallet,
      height: 27,
    ),
    activeIcon: LocalImage(
      AppIcons.walletRed,
      height: 27,
    ),
    label: 'Wallet',
  ),
  // BottomBarItem(
  //   icon: LocalImage(
  //     AppIcons.card,
  //     height: 27,
  //   ),
  //   activeIcon: LocalImage(
  //     AppIcons.cardRed,
  //     height: 27,
  //   ),
  //   label: 'Cards',
  // ),
  BottomBarItem(
    icon: Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: LocalImage(
        AppIcons.transaction,
        height: 18,
      ),
    ),
    activeIcon: Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: LocalImage(
        AppIcons.transactionRed,
        height: 18,
      ),
    ),
    label: 'Transactions',
  ),
];
