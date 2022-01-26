import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/notifications.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/views/signup/bio.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  Timer timer;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();


  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Scaffold(
        backgroundColor: Colors.white10,
        body: Column(
          children: [
            VSpace(40),
            Padding(
              padding: const EdgeInsets.only(top: 45),
              child: Center(
                  child: LocalImage(
                AppImages.logo,
                height: 40,
              )),
            ),
            LottieBuilder.asset(
              'assets/images/lottie.json',
              width: 250,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: MediumText(
                "Payments made easy",
                fontWeight: FontW.bold,
                size: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: '\u2022 ',
                      style: TextStyles.caption
                          .copyWith(color: AppColors.primaryColor)),
                  TextSpan(text: 'Cross border payments'),
                  TextSpan(
                      text: ' \u2022',
                      style: TextStyles.caption
                          .copyWith(color: AppColors.primaryColor)),
                ]),
                style: TextStyles.caption,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 16, left: Insets.lg, right: Insets.lg),
              child: SmallText(
                "Send funds, Recieve funds, Pay bills, subscriptions, E- cards",
                align: TextAlign.center,
                size: 16,
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: PElevatedbtn(
                'Get Started',
                onTap: () {
                  Navigator.push(
                      context, PageRouter.fadeScale(() => SignupBioPage()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, PageRouter.fadeScale(() => LoginPage()));
                },
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: 'Have an account?'),
                    TextSpan(
                      text: ' Login',
                      style: TextStyles.caption.copyWith(
                          color: AppColors.primaryColor, fontSize: 15),
                    ),
                  ]),
                  style: TextStyles.caption
                      .copyWith(color: Colors.black, fontSize: 15),
                ),
              ),
            ),
            VSpace.lg,
            VSpace.lg,
          ],
        ),
      ),
    );
  }
}
