import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/text.dart';

enum PinState { otp, authentication }

class PinPage extends StatefulWidget {
  final PinState state;
  PinPage({this.state = PinState.authentication});

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final _formPinKey = GlobalKey<FormState>();
  Timer timer;
  String userPin;

  TextEditingController _pinNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPin();
  }

  getPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userPin = prefs.getString('pin');
    print(userPin);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Scaffold(
      appBar: customAppbar(context),
      body: ProgressHUD(
        child: Builder(
          builder: (context) => Form(
            key: _formPinKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  VSpace.lg,
                  MediumText(
                    state == PinState.otp
                        ? "Authenticate OTP"
                        : "Just a little bit more",
                    size: FontSizes.s18,
                  ),
                  VSpace.lg,
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Insets.lg, vertical: 10),
                    child: Align(
                      child: SmallText(
                        state == PinState.otp
                            ? "We've sent a 4 - digit OTP code to your mobile number"
                            : 'Confirm with your 4 - Digit pin',
                      ),
                    ),
                  ),
                  VSpace.lg,
                  if (state == PinState.otp)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg + 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SmallText(
                          'Enter OTP',
                        ),
                      ),
                    ),
                  VSpace.sm,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.lg + 24),
                    child: PinInputField(
                      controller: _pinNumber,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Pin';
                        }
                        return null;
                      },
                    ),
                  ),
                  VSpace.md,
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Insets.lg, vertical: 10),
                    child: Align(
                      child: state == PinState.otp
                          ? SmallText(
                              'Resend OTP',
                              color: AppColors.primaryColor,
                            )
                          : SmallText(
                              'Forgot PIN?',
                            ),
                    ),
                  ),
                  VSpace(50),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                    child: PElevatedbtn(
                      state == PinState.otp ? 'Next' : 'Confirm',
                      onTap: () {
                        if (_formPinKey.currentState.validate()) {
                          setState(() {
                            _formPinKey.currentState.save();
                          });
                          if (_pinNumber.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Pin must have a value')));
                          } else {
                            if (userPin == _pinNumber.text) {
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Incorrect Pin Entered')));
                            }
                          }
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Insets.lg, vertical: 10),
                    child: Align(
                      child: MediumText(
                        'Cancel',
                      ),
                    ),
                  ),
                  VSpace.lg
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
