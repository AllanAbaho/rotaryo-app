import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/views/onboarding/onboarding.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      SharedPreferences.getInstance().then((value) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouter.fadeThrough(() => LoginPage()),
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LargeText(
                    'Rotary',
                    color: Colors.white,
                  ),
                  HSpace(5),
                  LocalImage(
                    AppImages.logo2,
                    height: 50,
                  ),
                ],
              ),
              VSpace.md,
              Center(
                  child: MediumText(
                'Serve to change lives',
                color: Colors.white,
                size: FontSizes.s16,
              ))
            ],
          ),
          Positioned(
            bottom: Insets.sm,
            right: Insets.lg,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmallText(
                  'A product of Rotary-O',
                  color: Colors.white,
                ),
                HSpace.sm,
              ],
            ),
          )
        ],
      ),
    );
  }
}
