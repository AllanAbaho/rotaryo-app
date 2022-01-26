import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/signup/otp.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            VSpace.sm,
            MediumText(
              "Create new PIN",
              fontWeight: FontW.bold,
              size: 24,
            ),
            VSpace.lg,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: TextInputField(
                labelText: 'Username',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (!validateUserName(value)) {
                    return 'Please Enter a valid Username';
                  }
                  return null;
                },
                onSaved: (value) {},
                isOnboardingField: true,
              ),
            ),
            VSpace.lg,
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SmallText(
                  'Create new PIN',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg + 24),
              child: PinInputField(
                controller: _pinController,
                onSaved: (value) {
                  pin = value;
                },
                key: ValueKey('pin'),
              ),
            ),
            VSpace.md,
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SmallText(
                  'Confirm PIN',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg + 24),
              child: PinInputField(
                controller: _pinConfirmController,
                onSaved: (value) {
                  pin = value;
                },
                key: ValueKey('confirm_pin'),
              ),
            ),
            VSpace.lg,
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
                            Navigator.push(
                              context,
                              PageRouter.fadeScale(
                                () => SignupOtpPage(
                                  title:
                                      'We’ve sent a 4- digit code to the phone number linked to your account',
                                  btnText: 'Verify',
                                ),
                              ),
                            );
                          } else {
                            buildDialog(_formSecurityKey.currentContext,
                                'The provided pins do not match');
                          }
                        } else {
                          buildDialog(_formSecurityKey.currentContext,
                              'Please confirm your pin');
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
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SmallText('Cancel'),
              ),
            ),
            VSpace.lg
          ],
        ),
      ),
    ));
  }

  bool validateSpecialCharacters(String text) {
    return RegExp(r"^(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(text);
  }

  bool validateUserName(String username) {
    return RegExp(r"^(?=.{4,12}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(username);
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
}
