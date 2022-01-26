import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/signup/setup_complete.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/pinfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class SignupOtpPage extends StatefulWidget {
  final String title, btnText, phoneNumber;
  File img, imgBack, imgProfile;
  String firstName,
      lastName,
      country,
      accountNumber,
      userName,
      idType,
      idNumber,
      email,
      countryCode,
      currencyCode,
      pin;

  SignupOtpPage({
    this.title,
    this.btnText,
    this.country,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.accountNumber,
    this.img,
    this.countryCode,
    this.currencyCode,
    this.userName,
    this.idType,
    this.idNumber,
    this.pin,
    this.email,
    this.imgBack,
    this.imgProfile,
  });

  @override
  _SignupOtpPageState createState() => _SignupOtpPageState();
}

class _SignupOtpPageState extends State<SignupOtpPage> {
  String verificationId;
  String errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formOtpKey = GlobalKey<FormState>();
  TextEditingController _otpController = TextEditingController();
  bool ignoreTaps = false;

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  Future<void> sendOtp() async {
    // ignore: prefer_function_declarations_over_variables
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      verificationId = verId;
    };
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber, // PHONE NUMBER TO SEND OTP
        codeAutoRetrievalTimeout: (String verId) {
          //Starts the phone number verification process for the given phone number.
          //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
          verificationId = verId;
        },
        codeSent:
            smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
        timeout: const Duration(seconds: 20),
        verificationCompleted: (AuthCredential phoneAuthCredential) async {
          final FirebaseUser user =
              (await _auth.signInWithCredential(phoneAuthCredential)).user;
          final FirebaseUser currentUser = await _auth.currentUser();
          if (user.uid == currentUser.uid) {
            _signIn(
              widget.country,
              widget.firstName,
              widget.lastName,
              widget.phoneNumber,
              widget.idType,
              widget.idNumber,
              widget.img,
              widget.userName,
              widget.pin,
              _formOtpKey.currentContext,
              widget.countryCode,
              widget.currencyCode,
              widget.email,
              widget.imgBack,
              widget.imgProfile,
            );
          } else {
            buildDialog(_formOtpKey.currentContext,
                'OTP verified successfully, but Firebase User is not Registered');
          }
        },
        verificationFailed: (AuthException exceptio) {
          buildDialog(_formOtpKey.currentContext, exceptio.message);
        },
      );
    } catch (e) {
      print(e.code.toString());
      switch (e.code.toString()) {
        case 'ERROR_INVALID_VERIFICATION_CODE':
          FocusScope.of(context).requestFocus(new FocusNode());
          setState(() {
            errorMessage = 'Invalid Code';
          });
          Navigator.of(context).pop();
          break;
        default:
          setState(() {
            errorMessage = e.message.toString();
          });
          break;
      }

      buildDialog(_formOtpKey.currentContext, '$errorMessage - ${e.code}');
    }
  }

  buildDialog(BuildContext buildContext, String dialogMessage) {
    return StylishDialog(
      context: buildContext,
      alertType: StylishDialogType.ERROR,
      titleText: 'Sorry',
      dismissOnTouchOutside: false,
      confirmButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(buildContext);
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

  buildDialogResend(BuildContext buildContext, String dialogMessage) {
    return StylishDialog(
      context: buildContext,
      alertType: StylishDialogType.ERROR,
      titleText: 'Sorry',
      dismissOnTouchOutside: false,
      confirmButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(buildContext);
          sendOtp();
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
          padding: EdgeInsets.fromLTRB(20, 1, 20, 1), // Set padding
        ),
        child: SmallText(
          'Resend OTP',
        ),
      ),
      animationLoop: true,
      contentText: dialogMessage,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IgnorePointer(
      ignoring: ignoreTaps,
      child: ProgressHUD(
        child: SingleChildScrollView(
          child: Builder(
            builder: (context) => Form(
              key: _formOtpKey,
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
                  VSpace.lg,
                  MediumText(
                    "Verify with OTP",
                    fontWeight: FontW.bold,
                    size: 24,
                  ),
                  VSpace.lg,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Insets.lg,
                      vertical: 10,
                    ),
                    child: Align(
                      child: SmallText(
                        widget.title ??
                            'We’ve sent a 6 - digit code to your phone number',
                        align: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.sm + 12),
                    child: PinInputField(
                      count: 6,
                      controller: _otpController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Otp';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                  ),
                  VSpace(100),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                    child: PElevatedbtn(
                      widget.btnText ?? 'Next',
                      onTap: () {
                        if (_formOtpKey.currentState.validate()) {
                          setState(() {
                            _formOtpKey.currentState.save();
                          });
                          if (_otpController.text.isNotEmpty) {
                            _firebaseSignIn(_otpController.text, context);
                          } else {
                            buildDialog(_formOtpKey.currentContext,
                                'Please Enter Your OTP');
                          }
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
    ));
  }

  _saveSession(
    String userName,
    String firstName,
    String secondName,
    String phoneNumber,
    String accountNumber,
    String accountBalance,
    String pin,
    String currencyCode,
    String profile,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLoggedIn', true);
    preferences.setString('userName', userName);
    preferences.setString('firstName', firstName);
    preferences.setString('secondName', secondName);
    preferences.setString('phoneNumber', phoneNumber);
    preferences.setString('accountNumber', accountNumber);
    preferences.setString('accountBalance', accountBalance);
    preferences.setString('profilePicture', profile);
    preferences.setString('pin', pin);
    preferences.setString('currencyCode', currencyCode);
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(context,
        PageRouter.fadeScale(() => SignupCompletePage()), (route) => false);
  }

  _firebaseSignIn(String smsOTP, BuildContext context) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      if (user.uid == currentUser.uid) {
        _signIn(
          widget.country,
          widget.firstName,
          widget.lastName,
          widget.phoneNumber,
          widget.idType,
          widget.idNumber,
          widget.img,
          widget.userName,
          widget.pin,
          _formOtpKey.currentContext,
          widget.countryCode,
          widget.currencyCode,
          widget.email,
          widget.imgBack,
          widget.imgProfile,
        );
      } else {
        buildDialog(_formOtpKey.currentContext,
            'OTP verified successfully, but Firebase User is not Registered');
      }
    } catch (e) {
      switch (e.code.toString()) {
        case 'ERROR_INVALID_VERIFICATION_CODE':
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            errorMessage = 'Invalid Code';
          });
          Navigator.of(context).pop();
          break;
        default:
          setState(() {
            errorMessage = e.message.toString();
          });
          break;
      }
      if (e.code.toString().contains('ERROR_SESSION_EXPIRED')) {
        buildDialogResend(
            _formOtpKey.currentContext, '$errorMessage - ${e.code}');
      } else {
        buildDialog(_formOtpKey.currentContext, '$errorMessage - ${e.code}');
      }
    }
  }

  _signIn(
    String country,
    String firstName,
    String lastName,
    String phoneNumber,
    String idType,
    String idNumber,
    File img,
    String userName,
    String pin,
    BuildContext context,
    String countryCode,
    String currencyCode,
    String email,
    File imgBack,
    File imgProfile,
  ) async {
    _otpController.value = TextEditingValue(text: '******');
    final progress = ProgressHUD.of(_formOtpKey.currentContext);
    progress.showWithText('Registering User...');
    setState(() {
      ignoreTaps = true;
    });
    List<int> imageBytes = img.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    List<int> imageBytesBack = imgBack.readAsBytesSync();
    String base64ImageBack = base64Encode(imageBytesBack);
    List<int> imageBytesProfile = imgProfile.readAsBytesSync();
    String base64ImageProfile = base64Encode(imageBytesProfile);
    Map data = {
      'country': country,
      'currency': currencyCode,
      'country_code': countryCode,
      'phone_number': phoneNumber,
      'user_name': userName,
      'second_name': lastName,
      'pin': pin,
      'email': email,
      'id_img_back': base64ImageBack,
      'profile_img': base64ImageProfile,
      'id_type': idType,
      'id_number': idNumber,
      'id_img': base64Image,
      'first_name': firstName
    };
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}signUp.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });
          _saveSession(
              widget.userName,
              widget.firstName,
              widget.lastName,
              widget.phoneNumber,
              responseResult['accountNumber'].toString(),
              '0',
              widget.pin,
              widget.currencyCode,
              responseResult['image'].toString());
        } else {
          progress.dismiss();
          setState(() {
            ignoreTaps = false;
          });
          // ignore: use_build_context_synchronously
          buildDialog(
              _formOtpKey.currentContext, '${responseResult['message']}');
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTaps = false;
        });
        buildDialog(_formOtpKey.currentContext, '${response.statusCode}');
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTaps = false;
      });
      buildDialog(_formOtpKey.currentContext,
          'Failed to Connect to Server, Check your internet connection ${e.toString()}');
    }
  }
}
