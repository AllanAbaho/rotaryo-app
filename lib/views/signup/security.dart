import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/security/security.dart';
import 'package:tumiapesa/views/signup/otp.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class SignupSecurityPage extends StatefulWidget {
  File imgFile, imgFileBack, imgFileProfile;
  String firstName,
      lastName,
      email,
      phoneNumber,
      country,
      idType,
      idNumber,
      userName,
      countryCode,
      currencyCode;

  SignupSecurityPage(
    this.country,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.idType,
    this.idNumber,
    this.imgFile,
    this.userName,
    this.countryCode,
    this.currencyCode,
    this.email,
    this.imgFileBack,
    this.imgFileProfile,
  );
  @override
  _SignupSecurityPageState createState() => _SignupSecurityPageState();
}

class _SignupSecurityPageState extends State<SignupSecurityPage> {
  String pin, cPin;
  bool termsAccepted = false;
  final _formSecurityKey = GlobalKey<FormState>();
  TextEditingController _pinController = TextEditingController();
  TextEditingController _pinConfirmController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Form(
        key: _formSecurityKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 45),
              child: Center(
                  child: LocalImage(
                AppImages.logo,
                height: 40,
              )),
            ),
            VSpace.sm,
            MediumText(
              "Security",
              fontWeight: FontW.bold,
              size: 24,
            ),
            SmallText('Secure your account'),
            VSpace.lg,
            MediumText(
              pin == null
                  ? "Create a 4 digit security pin"
                  : "Confirm security pin",
              fontWeight: FontW.bold,
              size: 15,
            ),
            VSpace(10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg + 24),
              child: Column(
                children: [
                  Align(
                    child: SmallText(
                      'This pin will be used to sign in and authorise transactions',
                      align: TextAlign.center,
                    ),
                  ),
                  VSpace.md,
                  PinInputField(
                    controller: _pinController,
                    onSaved: (value) {
                      pin = value;
                    },
                    key: ValueKey('pin'),
                  ),
                  VSpace.md,
                  Align(
                    child: SmallText(
                      "Confirm pin",
                      align: TextAlign.center,
                    ),
                  ),
                  VSpace.md,
                  PinInputField(
                    controller: _pinConfirmController,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please confirm confirm your Pin';
                    //   }
                    //   if (value != pin) {
                    //     return 'User Pin is not the same';
                    //   }
                    //   return null;
                    // },
                    onSaved: (value) {
                      cPin = value;
                    },
                    key: ValueKey('confirm_pin'),
                  )
                ],
              ),
            ),
            VSpace(100),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: Row(
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (value) {
                      setState(
                        () {
                          termsAccepted = value;
                        },
                      );
                      if (value) {
                        showModal(
                          context: context,
                          builder: (context) => Dialog(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(44),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(Insets.lg),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MediumText(
                                    'By proceeding means you accept the terms and conditions of Pivot Payments',
                                    align: TextAlign.center,
                                  ),
                                  VSpace.lg,
                                  PElevatedbtn(
                                    'OK',
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    activeColor: AppColors.primaryColor,
                  ),
                  Expanded(
                    child: SmallText(
                      'I have read and agreed to the terms and conditions',
                      color: AppColors.primaryColor,
                      size: FontSizes.s11,
                    ),
                  )
                ],
              ),
            ),
            VSpace.lg,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: PElevatedbtn(
                'Next',
                onTap: () {
                  if (_formSecurityKey.currentState.validate()) {
                    setState(() {
                      _formSecurityKey.currentState.save();
                    });
                    if (_pinController.text.isNotEmpty) {
                      if (!validateSpecialCharacters(_pinController.text)) {
                        buildDialog(_formSecurityKey.currentContext,
                            'The pin should only contain numbers');
                      } else {
                        if (_pinConfirmController.text.isNotEmpty) {
                          if (_pinController.text ==
                              _pinConfirmController.text) {
                            if (!termsAccepted) {
                              buildDialog(_formSecurityKey.currentContext,
                                  'Please accept the terms and conditions');
                            } else {
                              Navigator.push(
                                context,
                                PageRouter.fadeScale(
                                  () => SignupOtpPage(
                                    country: widget.country,
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    phoneNumber: widget.phoneNumber,
                                    img: widget.imgFile,
                                    userName: widget.userName,
                                    idType: widget.idType,
                                    idNumber: widget.idNumber,
                                    pin: _pinController.text,
                                    imgBack: widget.imgFileBack,
                                    email: widget.email,
                                    imgProfile: widget.imgFileProfile,
                                    countryCode: widget.countryCode,
                                    currencyCode: widget.currencyCode,
                                  ),
                                ),
                              );
                            }
                          } else {
                            buildDialog(_formSecurityKey.currentContext,
                                'The provided pins do not match');
                          }
                        } else {
                          buildDialog(_formSecurityKey.currentContext,
                              'Please Confirm Your Pin');
                        }
                      }
                    } else {
                      buildDialog(
                          _formSecurityKey.currentContext, 'Please Enter Pin');
                    }
                  }
                },
              ),
            ),
            VSpace.lg
          ],
        ),
      ),
    ));
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
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
        ),
        child: SmallText(
          'Okay',
        ),
      ),
      animationLoop: true,
      contentText: dialogMessage,
    ).show();
  }

  bool validateSpecialCharacters(String text) {
    return RegExp(r"^(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(text);
  }
}
