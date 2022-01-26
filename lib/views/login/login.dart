import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:tumiapesa/utils/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/forgotpassword/forgot_password.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/signup/bio.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username, pin;
  bool ignoreTaps = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Builder(
            builder: (context) => SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    VSpace(60),
                    MediumText(
                      "Sign in to your account",
                      fontWeight: FontW.bold,
                      size: 24,
                    ),
                    VSpace(10),
                    LocalImage(
                      AppImages.loginBanner,
                      height: 200,
                    ),
                    VSpace(10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        labelText: 'Email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        onSaved: (value) {
                          username = value;
                        },
                        isOnboardingField: true,
                      ),
                    ),
                    VSpace(10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        enableSuggestions: true,
                        obscureText: true,
                        autocorrect: false,
                        labelText: 'Password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        onSaved: (value) {
                          username = value;
                        },
                        isOnboardingField: true,
                      ),
                    ),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Insets.lg, vertical: 10),
                      child: Align(
                        child: SmallText(
                          'Forgot password?',
                          color: AppColors.primaryColor,
                        ).onTap(() {
                          sendEmail();
                        }),
                      ),
                    ),
                    VSpace(10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: PElevatedbtn(
                        'Login',
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _formKey.currentState.save();
                            });
                            login(
                              _emailController.text,
                              _passwordController.text,
                              context,
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              PageRouter.fadeScale(() => SignupBioPage()));
                        },
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: 'Don’t have an account?'),
                            TextSpan(
                                text: ' Signup',
                                style: TextStyles.caption.copyWith(
                                    color: AppColors.primaryColor,
                                    fontSize: 15)),
                          ]),
                          style: TextStyles.caption
                              .copyWith(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ),
                    VSpace(20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 100,
                                height: 1.5,
                                color: Colors.grey[300]),
                            Text(
                              'or contact us via',
                              //  style: GoogleFonts.manrope(textStyle:
                              //                TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Color.fromRGBO(223,32,48,1)
                              //                ) )
                            ),
                            Container(
                                width: 100,
                                height: 1.5,
                                color: Colors.grey[300]),
                          ]),
                    ),
                    SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(
                        icon: Image.asset('assets/icons/facebook.png',
                            color: Colors.red, width: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/twitter.png',
                            color: Colors.red, width: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/world.png',
                            color: Colors.red, width: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Image.asset('assets/icons/linkedin.png',
                            color: Colors.red, width: 20),
                        onPressed: () {},
                      )
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  login(String email, String password, BuildContext context) async {
    final progress = ProgressHUD.of(context);
    progress.showWithText('Logging In...');
    setState(() {
      ignoreTaps = true;
    });

    Map data = {'email': email, 'password': password};
    try {
      final response =
          await http.post(Uri.parse('${rotaryApi}login'), body: data);
      var responseResult = jsonDecode(response.body);

      if (response.statusCode == 200) {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        _saveSession(
          email,
        );
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });

        buildDialog(
            _formKey.currentContext, responseResult['message'].toString());
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });

      buildDialog(_formKey.currentContext,
          "Failed to Connect to Server, Check your internet connection");
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
        child: SmallText(
          'Okay',
        ),
      ),
      animationLoop: true,
      contentText: dialogMessage,
    ).show();
  }

  _saveSession(String email) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLoggedIn', true);
    preferences.setString('email', email);
    Navigator.pushAndRemoveUntil(
      context,
      PageRouter.fadeScale(() => HomePage()),
      (route) => false,
    );
    print(email);

    print(preferences.getBool('isLoggedIn'));
    print(preferences.getString('email'));
  }

  void sendEmail() {}
}
