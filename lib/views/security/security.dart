import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  String pin, oPin;
  final _formSecurityKey = GlobalKey<FormState>();
  TextEditingController _pinController = TextEditingController();
  TextEditingController _oldPinController = TextEditingController();
  TextEditingController _confirmPinController = TextEditingController();

  int step = 0;
  @override
  Widget build(BuildContext context) {
    String title;
    switch (step) {
      case 1:
        title = 'Input new pin';
        break;
      case 2:
        title = 'Confirm new pin';
        break;
      default:
        title = 'Input old pin';
    }
    return Scaffold(
      appBar: customAppbar(context, title: 'Change security pin'),
      body: ProgressHUD(
        child: SingleChildScrollView(
          child: Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              child: Form(
                key: _formSecurityKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          VSpace.lg,
                          SmallText(
                            "Input old pin",
                            fontWeight: FontW.bold,
                          ),
                          VSpace.md,
                          PinInputField(
                            controller: _oldPinController,
                            key: ValueKey(step),
                            onSubmit: (value) => setState(() {
                              if (step == 0) {
                                print(value);
                                step++;
                                oPin = value;
                              } else if (step == 1) {
                                step++;
                                pin = value;
                              } else {
                                // check if new pin and confirm pin matches
                                if (pin == value) {
                                  // valid
                                }
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    VSpace(30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SmallText(
                            'Input new pin',
                            fontWeight: FontW.bold,
                          ),
                          VSpace.md,
                          PinInputField(
                            controller: _pinController,
                            key: ValueKey(step),
                            onSubmit: (value) => setState(() {
                              if (step == 0) {
                                step++;
                                oPin = value;
                              } else if (step == 1) {
                                step++;
                                pin = value;
                              } else {
                                // check if new pin and confirm pin matches
                                if (pin == value) {
                                  // valid
                                }
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    VSpace(30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SmallText(
                            'Comfirm new pin',
                            fontWeight: FontW.bold,
                          ),
                          VSpace.md,
                          PinInputField(
                            controller: _confirmPinController,
                            key: ValueKey(step),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new Pin';
                              }
                              return null;
                            },
                            onSubmit: (value) => setState(() {
                              if (step == 0) {
                                step++;
                                oPin = value;
                              } else if (step == 1) {
                                step++;
                                pin = value;
                              } else {
                                // check if new pin and confirm pin matches
                                if (pin == value) {
                                  // valid
                                }
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    VSpace(20),
                    Align(
                      child: SmallText(
                        'This pin will be used to sign in and authenticate transactions',
                        align: TextAlign.center,
                        size: FontSizes.s11,
                        color: AppColors.greyColor2,
                      ),
                    ),
                    VSpace(30),
                    PElevatedbtn(
                      'Change Pin',
                      onTap: () {
                        if (_formSecurityKey.currentState.validate()) {
                          setState(() {
                            _formSecurityKey.currentState.save();
                          });
                          SharedPreferences.getInstance().then((value) {
                            if (value.getString('pin') ==
                                _oldPinController.text) {
                              if (_oldPinController.text ==
                                  _pinController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: SmallText(
                                      'New Pin cannot be the same as Current Pin',
                                    ),
                                  ),
                                );
                              } else {
                                if (_pinController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          SmallText('New pin cannot be empty'),
                                    ),
                                  );
                                } else {
                                  if (_pinController.text ==
                                      _confirmPinController.text) {
                                    _changePin(value.getString('userName'));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            SmallText('Please confirm Pin'),
                                      ),
                                    );
                                  }
                                }
                              }
                            } else {
                              if (_oldPinController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        SmallText('Old pin cannot be empty'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        SmallText('Old pin does not match'),
                                  ),
                                );
                              }
                            }
                          });
                        }
                      },
                    ),
                    VSpace.lg
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _changePin(String userName) async {
    final progress = ProgressHUD.of(_formSecurityKey.currentContext);
    progress.showWithText('Changing Pin...');
    Map data = {'username': userName, 'pin': _pinController.text, 'old_pin':_oldPinController.text};
    final response =
        await http.post(Uri.parse('${tumiaApi}changePin.php'), body: data);
    if (response.statusCode == 200) {
      var responseResult = jsonDecode(response.body);
      var responseStatus = responseResult['success'];
      if (responseStatus == true) {
        progress.dismiss();
        _saveSession(
          _pinController.text,
        );
      } else {
        progress.dismiss();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${responseResult['message']}")),
        );
      }
    } else {
      progress.dismiss();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Change Pin failed ${response.statusCode}')),
      );
    }
  }

  _saveSession(
    String pin,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
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
                'Your pin has been changed successfully',
                align: TextAlign.center,
              ),
              VSpace.md,
              Container(
                height: 100,
                width: 100,
                padding: EdgeInsets.all(27),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF7E1),
                  shape: BoxShape.circle,
                ),
                child: LocalImage(
                  AppImages.shieldTick,
                ),
              ),
              VSpace.lg,
              PElevatedbtn(
                'OK',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouter.fadeScale(() => LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
