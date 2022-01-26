import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class SignupCompletePage extends StatefulWidget {
  @override
  _SignupCompletePageState createState() => _SignupCompletePageState();
}

class _SignupCompletePageState extends State<SignupCompletePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 45),
          child: Center(
              child: LocalImage(
            AppImages.logo,
            height: 150,
            width: 150,
            fit: BoxFit.contain,
          )),
        ),
        VSpace.lg,
        Padding(
          padding: const EdgeInsets.only(top: 55),
          child: MediumText(
            "You’re all set up",
            fontWeight: FontW.bold,
            size: 24,
          ),
        ),
        VSpace.lg,
        Container(
          height: 140,
          width: 140,
          padding: EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Color(0xFFFFF7E1),
            shape: BoxShape.circle,
          ),
          child: LocalImage(
            AppImages.kudos,
          ),
        ),
        Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
          child: PElevatedbtn(
            'Continue to login',
            onTap: () {
              Navigator.pushAndRemoveUntil(context,
                  PageRouter.fadeScale(() => LoginPage()), (route) => false);
            },
          ),
        ),
        VSpace.lg
      ],
    ));
  }
}
