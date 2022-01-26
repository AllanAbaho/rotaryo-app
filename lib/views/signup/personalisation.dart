import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/signup/security.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class SignupPersonalisationPage extends StatefulWidget {
  File imgFile, imgFileBack, imgFileProfile;
  String firstName,
      lastName,
      phoneNumber,
      country,
      idType,
      email,
      idNumber,
      countryCode,
      currencyCode;

  SignupPersonalisationPage(
    this.country,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.idType,
    this.idNumber,
    this.imgFile,
    this.countryCode,
    this.currencyCode,
    this.email,
    this.imgFileProfile,
    this.imgFileBack,
  );

  @override
  _SignupPersonalisationPageState createState() =>
      _SignupPersonalisationPageState();
}

class _SignupPersonalisationPageState extends State<SignupPersonalisationPage> {
  final _formPersonKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _confirmUserNameController = TextEditingController();
  bool ignoreTaps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => Form(
              key: _formPersonKey,
              child: SingleChildScrollView(
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
                      "Personalisation",
                      fontWeight: FontW.bold,
                      size: 24,
                    ),
                    SmallText('Fill in your details'),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        labelText: 'Create Username',
                        controller: _userNameController,
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
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        labelText: 'Confirm Username',
                        onSaved: (value) {},
                        validator: (value) {
                          if (!validateUserName(value)) {
                            return 'Please Enter a valid Username';
                          }
                          if (_userNameController.text != value) {
                            return 'Username is not the same';
                          }
                          return null;
                        },
                        controller: _confirmUserNameController,
                        isOnboardingField: true,
                      ),
                    ),
                    VSpace(46),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: PElevatedbtn(
                        'Next',
                        onTap: () {
                          if (_formPersonKey.currentState.validate()) {
                            setState(() {
                              _formPersonKey.currentState.save();
                            });
                            check_user();
                          }
                        },
                      ),
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

  bool validateUserName(String username) {
    return RegExp(r"^(?=.{4,12}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(username);
  }

  void check_user() async {
    final progress = ProgressHUD.of(_formPersonKey.currentContext);
    progress.showWithText('Checking Username...');
    setState(() {
      ignoreTaps = true;
    });
    Map data = {'user': _userNameController.text};
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}check_user.php'), body: data);

      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });

          buildDialog(_formPersonKey.currentContext,
              responseResult['message'].toString());
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              PageRouter.fadeScale(() => SignupSecurityPage(
                  widget.country,
                  widget.firstName,
                  widget.lastName,
                  widget.phoneNumber,
                  widget.idType,
                  widget.idNumber,
                  widget.imgFile,
                  _userNameController.text,
                  widget.countryCode,
                  widget.currencyCode,
                  widget.email,
                  widget.imgFileBack,
                  widget.imgFileProfile)));
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          PageRouter.fadeScale(
            () => SignupSecurityPage(
                widget.country,
                widget.firstName,
                widget.lastName,
                widget.phoneNumber,
                widget.idType,
                widget.idNumber,
                widget.imgFile,
                _userNameController.text,
                widget.countryCode,
                widget.currencyCode,
                widget.email,
                widget.imgFileBack,
                widget.imgFileProfile),
          ),
        );
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });
      buildDialog(_formPersonKey.currentContext,
          'Failed to Connect to Server, Check your internet connection');
    }
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
}
