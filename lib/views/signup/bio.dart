// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/login/login.dart';
import 'package:tumiapesa/views/signup/personalisation.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/dialogs/stylish_dialog.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class SignupBioPage extends StatefulWidget {
  @override
  _SignupBioPageState createState() => _SignupBioPageState();
}

class _SignupBioPageState extends State<SignupBioPage>
    with WidgetsBindingObserver {
  File imgFile, imgFileBack, imgFileProfile;
  String _countryValue,
      _idType,
      _prefixCode,
      _countryCode,
      _currencyCode,
      email;
  bool ignoreTap = false;
  List<Country> countries;
  final _formBioKey = GlobalKey<FormState>();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _idTypeController = TextEditingController();
  TextEditingController _emailAddressController = TextEditingController();
  TextEditingController _idNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IgnorePointer(
        ignoring: ignoreTap,
        child: ProgressHUD(
          child: SingleChildScrollView(
            child: Builder(
              builder: (context) => Form(
                key: _formBioKey,
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
                      "Let's get you started",
                      fontWeight: FontW.bold,
                      size: 24,
                    ),
                    SmallText('Bio details'),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        readOnly: true,
                        controller: _countryController,
                        labelText: 'Select Country / Region',
                        isOnboardingField: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Tap to select your Country / Region';
                          }
                          return null;
                        },
                        onTap: () {
                          // showCurrencyPicker(
                          //   context: context,
                          //   showFlag: true,
                          //   showCurrencyName: true,
                          //   showCurrencyCode: true,
                          //   onSelect: (Currency currency) {
                          //     print('Select Country: ${currency.code}');
                          //   },
                          //   currencyFilter: <String>[
                          //     'EUR',
                          //     'GBP',
                          //     'USD',
                          //     'KES',
                          //     'NGN',
                          //     'UGX'
                          //   ],
                          // );

                          showCountryPicker(
                            context: context,
                            countryListTheme: CountryListThemeData(
                              flagSize: 25,
                              backgroundColor: Colors.white,
                              //Optional. Sets the border radius for the bottomsheet.
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              //Optional. Styles the search field.
                              inputDecoration: InputDecoration(
                                labelText: 'Search',
                                hintText: 'Start typing to search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color(0xFF8C98A8)
                                        .withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ), // optional. Shows phone code before the country name.
                            onSelect: (Country country) {
                              _countryDetails(country.countryCode);
                              setState(() {
                                _countryValue =
                                    country.displayNameNoCountryCode;
                                _prefixCode = country.fullExampleWithPlusSign;
                                _countryCode = country.countryCode;
                                _countryController.value =
                                    TextEditingValue(text: _countryValue);
                              });
                            },
                          );
                        },
                        onSaved: (value) {
                          _countryValue = value;
                        },
                      ),
                    ),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        labelText: 'First Name',
                        isOnboardingField: true,
                        controller: _firstNameController,
                        onSaved: (value) {},
                        validator: (value) {
                          if (!validateSpecialCharacters(value)) {
                            return 'First Name must only contain letters (no spaces)';
                          }
                          if (value.length <= 3 || value.length > 12) {
                            return 'First Name must contain 4 to 12 characters';
                          }
                          if (value.contains(RegExp(r'[0-9]'))) {
                            return 'First Name must only contain letters (no spaces)';
                          }
                          return null;
                        },
                      ),
                    ),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        labelText: 'Last Name',
                        isOnboardingField: true,
                        validator: (value) {
                          if (!validateSpecialCharacters(value)) {
                            return 'Last Name must only contain letters (no spaces)';
                          }
                          if (value.length <= 3 || value.length > 12) {
                            return 'Last Name must contain 4 to 12 characters';
                          }
                          if (value.contains(RegExp(r'[0-9]'))) {
                            return 'Last Name must only contain letters (no spaces)';
                          }
                          return null;
                        },
                        controller: _lastNameController,
                        onSaved: (value) {},
                      ),
                    ),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        labelText: 'Email Address (Optional)',
                        isOnboardingField: true,
                        controller: _emailAddressController,
                        // helperText: 'This field is optional',
                        validator: (value) {
                          if (value.isNotEmpty) {
                            if (!validateUserEmail(value)) {
                              return 'Please Enter a valid Email Address';
                            }
                          }
                          return null;
                        },
                        onSaved: null,
                      ),
                    ),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        // decoration: InputDecoration(
                        //   labelText: "Phone",
                        //   icon: Icon(Icons.phone),
                        //   prefixText: _prefixCode,
                        // ),
                        // suffixIcon: Icon(Icons.phone_android),
                        labelText: 'Phone Number (Example: +256700460000)',
                        // initialValue: _prefixCode,
                        isOnboardingField: true,
                        hintText: _prefixCode,
                        controller: _phoneNumberController,
                        validator: (value) {
                          if (!validatePhoneNumber(value)) {
                            return 'Invalid Phone Number';
                          }
                          if (value.length < 13) {
                            return 'Invalid Phone Number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        onSaved: (value) {},
                      ),
                    ),
                    VSpace.md,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                        child: MediumText('Upload your Profile Picture'),
                      ),
                    ),
                    VSpace.md,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                        child: ImageBox(
                          img: imgFileProfile,
                        ).onTap(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext) {
                              AlertDialog dialog = AlertDialog(
                                content: Text('Choose'),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 54,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final ImagePicker _picker =
                                                  ImagePicker();
                                              final XFile image =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                      imageQuality: 25);
                                              setState(() {
                                                imgFileProfile =
                                                    File(image.path);
                                              });
                                            },
                                            child: MediumText('Gallery'),
                                          ),
                                        ),
                                      ),
                                      HSpace.md,
                                      Expanded(
                                        child: SizedBox(
                                          height: 54,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final ImagePicker _picker =
                                                  ImagePicker();
                                              final XFile image =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.camera,
                                                      imageQuality: 25);
                                              setState(() {
                                                imgFileProfile =
                                                    File(image.path);
                                              });
                                            },
                                            child: MediumText('Camera'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                              return dialog;
                            },
                          );
                        }),
                      ),
                    ),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: DropDownTextInputField(
                        labelText: 'Select Id Type',
                        isOnboardingField: true,
                        onSaved: (value) {
                          _idType = value.title;
                        },
                        items: [
                          DropDownItem(
                              imgUrl: 'assets/icons/people.png',
                              title: 'National ID',
                              value: '1'),
                          DropDownItem(
                              imgUrl: 'assets/icons/people.png',
                              title: 'Passport',
                              value: '2'),
                          DropDownItem(
                              imgUrl: 'assets/icons/people.png',
                              title: 'Iqama',
                              value: '3'),
                          DropDownItem(
                              imgUrl: 'assets/icons/people.png',
                              title: 'Others',
                              value: '4'),
                          // CAN IMPLEMENT COUNTRY PACKAGE
                        ],
                      ),
                    ),
                    //  DropDownItem( title: 'National ID', value: '1'),
                    //         DropDownItem( title: 'Passport', value: '2'),
                    //         DropDownItem( title: 'Iqama', value: '3'),
                    //          DropDownItem( title: 'Others', value: '4'),
                    VSpace.md,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: TextInputField(
                        labelText: 'Input ID Number',
                        controller: _idNumberController,
                        // onTap: () {
                        //   //_selectDeviceFromPicker();
                        //   _toggleScanner();
                        // },
                        validator: (value) {
                          if (!validateSpecialCharacters(value)) {
                            return 'ID must only contain numbers or letters (no spaces)';
                          }
                          if (value.length <= 3) {
                            return 'ID Number must contain 4 to 12 characters';
                          }
                          return null;
                        },
                        isOnboardingField: true,
                        onSaved: (value) {},
                      ),
                    ),
                    VSpace.md,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                        child: MediumText(
                            'Take photos of your ID (back and front)'),
                      ),
                    ),
                    VSpace.md,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                        child: Row(
                          children: [
                            ImageBox(
                              img: imgFile,
                            ).onTap(() {
                              showDialog(
                                context: context,
                                builder: (BuildContext) {
                                  AlertDialog dialog = AlertDialog(
                                    content: Text('Choose'),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 54,
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    final ImagePicker _picker =
                                                        ImagePicker();
                                                    final XFile image =
                                                        await _picker.pickImage(
                                                            source: ImageSource
                                                                .gallery,
                                                            imageQuality: 25);
                                                    setState(() {
                                                      imgFile =
                                                          File(image.path);
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: MediumText('Gallery')),
                                            ),
                                          ),
                                          HSpace.md,
                                          Expanded(
                                            child: SizedBox(
                                              height: 54,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final ImagePicker _picker =
                                                      ImagePicker();
                                                  final XFile image =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .camera,
                                                          imageQuality: 25);
                                                  setState(() {
                                                    imgFile = File(image.path);
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                child: MediumText('Camera'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                  return dialog;
                                },
                              );
                            }),
                            HSpace.md,
                            ImageBox(
                              img: imgFileBack,
                            ).onTap(() {
                              showDialog(
                                context: context,
                                builder: (BuildContext) {
                                  AlertDialog dialog = AlertDialog(
                                    content: Text('Choose'),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 54,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final ImagePicker _picker =
                                                      ImagePicker();
                                                  final XFile image =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                          imageQuality: 25);
                                                  setState(() {
                                                    imgFileBack =
                                                        File(image.path);
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                child: MediumText('Gallery'),
                                              ),
                                            ),
                                          ),
                                          HSpace.md,
                                          Expanded(
                                            child: SizedBox(
                                              height: 54,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final ImagePicker _picker =
                                                      ImagePicker();
                                                  final XFile image =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .camera,
                                                          imageQuality: 25);
                                                  setState(() {
                                                    imgFileBack =
                                                        File(image.path);
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                child: MediumText('Camera'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                  return dialog;
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    VSpace(46),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                      child: PElevatedbtn(
                        'Next',
                        onTap: () {
                          if (_formBioKey.currentState.validate()) {
                            setState(() {
                              _formBioKey.currentState.save();
                            });
                            if (_emailAddressController.text.isEmpty) {
                              email = 'support@pivotpayts.com';
                            } else {
                              email = _emailAddressController.text;
                            }
                            if (imgFileProfile == null) {
                              StylishDialog(
                                context: context,
                                alertType: StylishDialogType.ERROR,
                                titleText: 'Sorry',
                                dismissOnTouchOutside: false,
                                confirmButton: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.fromLTRB(
                                        20, 1, 20, 1), // Set padding
                                  ),
                                  child: SmallText(
                                    'Okay',
                                  ),
                                ),
                                animationLoop: true,
                                contentText:
                                    'Please upload you profile picture',
                              ).show();
                            } else if (imgFile == null) {
                              StylishDialog(
                                context: context,
                                alertType: StylishDialogType.ERROR,
                                titleText: 'Sorry',
                                dismissOnTouchOutside: false,
                                confirmButton: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.fromLTRB(
                                        20, 1, 20, 1), // Set padding
                                  ),
                                  child: SmallText(
                                    'Okay',
                                  ),
                                ),
                                animationLoop: true,
                                contentText:
                                    'Please upload a front image of your ID',
                              ).show();
                            } else if (imgFileBack == null) {
                              StylishDialog(
                                context: context,
                                alertType: StylishDialogType.ERROR,
                                titleText: 'Sorry',
                                dismissOnTouchOutside: false,
                                confirmButton: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.fromLTRB(
                                        20, 1, 20, 1), // Set padding
                                  ),
                                  child: SmallText(
                                    'Okay',
                                  ),
                                ),
                                animationLoop: true,
                                contentText:
                                    'Please upload a back image of your ID',
                              ).show();
                            } else {
                              checkPhone();
                            }
                          }
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

  bool validateUserEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool validateSpecialCharacters(String text) {
    return RegExp(r"^(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(text);
  }

  bool validatePhoneNumber(String text) {
    return RegExp(r"^\+?\d*$").hasMatch(text);
  }

  _countryDetails(String countryCode) async {
    final response = await http.get(Uri.parse(countriesUrl + countryCode));
    if (response.statusCode == 200) {
      var responseResult = jsonDecode(response.body);
      final String currenciesObject =
          responseResult[0]['currencies'].toString();
      setState(() {
        _phoneNumberController.value = TextEditingValue(
            text: responseResult[0]['idd']['root'].toString() +
                responseResult[0]['idd']['suffixes'][0].toString());
      });

      final String curreniesJsonReplaced =
          currenciesObject.replaceAllMapped(RegExp(r'[{}]'), (match) {
        return '';
      });
      final int index = curreniesJsonReplaced.indexOf(':');
      _currencyCode = curreniesJsonReplaced.substring(0, index);
    }
  }

  void checkPhone() async {
    setState(() {
      ignoreTap = true;
    });
    final progress = ProgressHUD.of(_formBioKey.currentContext);
    progress.showWithText('Checking Phone Number...');
    Map data = {'phone': _phoneNumberController.text};
    try {
      final response =
          await http.post(Uri.parse('${tumiaApi}check_phone.php'), body: data);
      if (response.statusCode == 200) {
        var responseResult = jsonDecode(response.body);
        var responseStatus = responseResult['success'];
        if (responseStatus == true) {
          progress.dismiss();
          setState(() {
            ignoreTap = false;
          });
          StylishDialog(
            context: _formBioKey.currentContext,
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
            contentText: responseResult['message'].toString(),
          ).show();
        } else {
          progress.dismiss();
          setState(() {
            ignoreTap = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            PageRouter.fadeScale(
              () => SignupPersonalisationPage(
                  _countryValue,
                  _firstNameController.text,
                  _lastNameController.text,
                  _phoneNumberController.text,
                  _idType,
                  _idNumberController.text,
                  imgFile,
                  _countryCode,
                  _currencyCode,
                  email,
                  imgFileProfile,
                  imgFileBack),
            ),
          );
        }
      } else {
        progress.dismiss();
        setState(() {
          ignoreTap = false;
        });

        StylishDialog(
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
          contentText: response.body,
        ).show();
      }
    } catch (e) {
      progress.dismiss();
      setState(() {
        ignoreTap = false;
      });

      buildDialog(_formBioKey.currentContext,
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

class ImageBox extends StatelessWidget {
  final File img;
  ImageBox({this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryColor,
            width: 1.8,
          ),
          borderRadius: Corners.lgBorder,
          image: img == null
              ? null
              : DecorationImage(
                  image: FileImage(img),
                  fit: BoxFit.cover,
                )),
      padding: EdgeInsets.all(10),
      child: img == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 12,
                      width: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            left: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                      width: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            right: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 12,
                      width: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            left: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                      width: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            right: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          : SizedBox(),
    );
  }
}
