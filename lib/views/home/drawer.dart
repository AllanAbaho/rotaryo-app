import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/beneficiaries/beneficiaries.dart';
import 'package:tumiapesa/views/contactus/contact_us.dart';
import 'package:tumiapesa/views/customercare/customer_care.dart';
import 'package:tumiapesa/views/onboarding/onboarding.dart';
import 'package:tumiapesa/views/privacypolicy/privacy_policy.dart';
import 'package:tumiapesa/views/profile/profile.dart';
import 'package:tumiapesa/views/security/security.dart';
import 'package:tumiapesa/views/transactions/transactions.dart';
import 'package:tumiapesa/views/withdraw/withdraw_to_bank.dart';
import 'package:tumiapesa/widgets/avatar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/text.dart';
import 'package:tumiapesa/utils/extension.dart';

class HomeDrawerPage extends StatefulWidget {
  @override
  _HomeDrawerPageState createState() => _HomeDrawerPageState();
}

class _HomeDrawerPageState extends State<HomeDrawerPage> {
    String _firstName, _secondName, _accountNumber, _accountBalance, _profilePicture;
    SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _getSessionValues();
  }

  _getSessionValues() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName');
      _secondName = prefs.getString('secondName');
      _accountNumber = prefs.getString('accountNumber');
      _accountBalance = prefs.getString('accountBalance');
      _profilePicture = prefs.getString('profilePicture');
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.getWidth(factor: 0.9),
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            top: Insets.statusBar + Insets.md,
            bottom: Insets.md,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Insets.md,
                  right: Insets.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Avatar(
                          imgUrl: "$tumiaApi$_profilePicture",
                        ),
                        HSpace.md,
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MediumText('$_firstName $_secondName'),
                              SmallText(
                                'View Profile',
                                color: AppColors.primaryColor,
                              ).onTap(
                                () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    PageRouter.fadeThrough(
                                      () => ProfilePage(),
                                    ),
                                  );
                                },
                              )
                            ])
                      ],
                    ),
                    Icon(PhosphorIcons.xBold, color: Colors.black)
                        .onTap(() => Navigator.pop(context))
                  ],
                ),
              ),
              Divider(
                height: Insets.lg,
                color: AppColors.primaryColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: Insets.md,
                    right: Insets.lg,
                  ),
                  child: ListView(
                    children: [
                      DrawerItem(
                        'Beneficiaries',
                        imgUrl: AppIcons.people,
                        onTap: () => Navigator.push(
                          context,
                          PageRouter.fadeThrough(() => BeneficiariesPage()),
                        ),
                      ),
                      // DrawerItem(
                      //   'Withdraw',
                      //   imgUrl: AppIcons.list2,
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     PageRouter.fadeThrough(() => WithdrawToBank()),
                      //   ),
                      // ),
                      DrawerItem(
                        'Security',
                        imgUrl: AppIcons.lock,
                        onTap: () => Navigator.push(
                          context,
                          PageRouter.fadeThrough(() => SecurityPage()),
                        ),
                      ),
                      DrawerItem(
                        'My Transactions',
                        imgUrl: AppIcons.notes,
                        onTap: () => Navigator.push(
                          context,
                          PageRouter.fadeThrough(() => TransactionsPage(
                                showAppbar: true,
                                isDrawer: true,
                              )),
                        ),
                      ),
                      // DrawerItem(
                      //   'Customer care',
                      //   imgUrl: AppIcons.chat,
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     PageRouter.fadeThrough(() => CustomerCarePage()),
                      //   ),
                      // ),
                      DrawerItem('Privacy policy',
                          imgUrl: AppIcons.list,
                          onTap: () => Navigator.push(
                                context,
                                PageRouter.fadeThrough(
                                    () => PrivacyPolicyPage()),
                              )),
                      DrawerItem(
                        'Contact us',
                        imgUrl: AppIcons.list,
                        onTap: () => Navigator.push(
                          context,
                          PageRouter.fadeThrough(() => ContactUsPage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              VSpace.md,
              Padding(
                padding: EdgeInsets.only(
                  left: Insets.md,
                  right: Insets.lg,
                ),
                child: PElevatedbtn('Log out', onTap: () {
                  prefs.clear();
                  Navigator.pushAndRemoveUntil(
                      context,
                      PageRouter.fadeThrough(
                        () => OnboardingPage(),
                      ),
                      (route) => false);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String label, imgUrl;
  final Function onTap;
  DrawerItem(this.label, {this.imgUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: 65,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: Insets.sm + 4),
      decoration: BoxDecoration(
          borderRadius: Corners.lgBorder, color: Color(0xAAFAFAFA)),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: ImageIcon(
                AssetImage(imgUrl ?? AppIcons.loan),
                color: AppColors.primaryColor,
              ),
            ),
          ),
          HSpace.md,
          SmallText(
            label,
            size: FontSizes.s15,
          )
        ],
      ),
    ).onTap(() {
      Navigator.pop(context);
      onTap();
    });
  }
}
