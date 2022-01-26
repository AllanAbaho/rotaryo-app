import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _firstName,
      _secondName,
      _accountNumber,
      _accountBalance,
      _profilePicture,
      _userName,
      _phoneNumber;

  final FocusNode _pFocusNode = FocusNode();

  File imgFile;
  final _scaffoldKey = GlobalKey<FormState>();

  TextEditingController _pController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSessionValues();
  }

  _getSessionValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _firstName = prefs.getString('firstName');
      _secondName = prefs.getString('secondName');
      _accountNumber = prefs.getString('accountNumber');
      _accountBalance = prefs.getString('accountBalance');
      _profilePicture = prefs.getString('profilePicture');
      _userName = prefs.getString('userName');
      _phoneNumber = prefs.getString('phoneNumber');

      _pController = TextEditingController(text: _phoneNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double _contHeight = 140;
    const double _contTopMargin = 60;
    const _avatarYOffset = _contHeight - _contTopMargin + 20;
    const double _ring = 0;
    return ProgressHUD(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: customAppbar(
          context,
          title: 'My Profile',
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              VSpace.md,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      Container(
                        padding: EdgeInsets.all(7),
                        height: _ring,
                        width: _ring,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        height: _contHeight,
                        width: double.infinity,
                        clipBehavior: Clip.hardEdge,
                        margin: EdgeInsets.only(top: _contTopMargin),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            VSpace.md,
                            SmallText(
                              _userName,
                              color: Colors.white,
                              size: FontSizes.s14,
                            ),
                            EditableText(
                              controller: _pController,
                              focusNode: _pFocusNode,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyles.h3.copyWith(
                                color: Colors.white,
                                fontSize: FontSizes.s16,
                              ),
                              cursorColor: Colors.white,
                              backgroundCursorColor: Colors.white,
                            ),
                            VSpace.sm,
                            MediumText(
                              '$_secondName $_firstName',
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: _avatarYOffset - 5,
                          left: 110,
                          child: LocalImage(
                            AppImages.blob1,
                            height: 36,
                          )),
                      Positioned(
                        bottom: 0,
                        left: 25,
                        child: LocalImage(AppImages.blob2, height: 36),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: LocalImage(AppImages.blob3, height: 55),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Positioned(
                          bottom: _avatarYOffset,
                          child: GestureDetector(
                            onTap: () {
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
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                    setState(() {
                                                      imgFile =
                                                          File(image.path);
                                                      Navigator.pop(context);
                                                      showUploadDialog();
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
                                                    source: ImageSource.camera,
                                                  );
                                                  setState(() {
                                                    imgFile = File(image.path);
                                                    Navigator.pop(context);
                                                    showUploadDialog();
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
                            },
                            child: ImageBox(
                              img: imgFile,
                              profilePicture: _profilePicture,
                            ),
                          )
                          // child: SizedBox(
                          //   height: _avatar,
                          //   width: _avatar,
                          //   child: DecoratedBox(
                          //     decoration: BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       image: DecorationImage(
                          //         image: AssetImage(AppImages.person2),
                          //         fit: BoxFit.cover,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          ),
                    ],
                  ),
                ),
              ),
              VSpace.md,
              Container(
                padding: EdgeInsets.all(Insets.lg - 8),
                margin: EdgeInsets.symmetric(horizontal: Insets.lg),
                decoration: BoxDecoration(
                  borderRadius: Corners.lgBorder,
                  color: Color(0xAAFAFAFA),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MediumText(
                      'Verification status',
                    ),
                    LocalImage(
                      AppIcons.greenCheck,
                      height: 18,
                    )
                  ],
                ),
              ),
              VSpace.md,
              Container(
                padding: EdgeInsets.all(Insets.lg - 8),
                margin: EdgeInsets.symmetric(horizontal: Insets.lg),
                decoration: BoxDecoration(
                    borderRadius: Corners.lgBorder, color: Color(0xAAFAFAFA)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediumText(
                      'Transfer Limits',
                      fontWeight: FontW.bold,
                    ),
                    VSpace.lg,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: Corners.lgBorder,
                        color: Color(0xFF21BC22),
                      ),
                      child: SmallText(
                        'Incoming',
                        color: Colors.white,
                      ),
                    ),
                    VSpace.md,
                    LimitItem('Daily limit', 'UGX350,000'),
                    LimitItem('Monthly limit', 'UGX3,500,000'),
                    Divider(
                      color: Colors.black,
                    ),
                    VSpace.md,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: Corners.lgBorder,
                        color: Color(0xFFFFD15A),
                      ),
                      child: SmallText(
                        'Outgoing',
                        color: Colors.white,
                      ),
                    ),
                    VSpace.md,
                    LimitItem('Daily limit', 'UGX150,000'),
                    LimitItem('Monthly limit', 'UGX1,500,000'),
                  ],
                ),
              ),
              VSpace.lg,
            ],
          ),
        ),
      ),
    );
  }

  showUploadDialog() {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Profile Update',
                style: TextStyle(
                  color: Color.fromRGBO(223, 32, 48, 1),
                ),
              ),
              Divider(
                color: Color.fromRGBO(223, 32, 48, 1),
              ),
              Column(
                children: [
                  Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Flexible(
                        child: Text(
                          'Do you want to update your Profile Details?',
                          style: TextStyle(fontSize: 14),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.black,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            updateProfile();
                          },
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(
                                  223,
                                  32,
                                  48,
                                  1,
                                ),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _successDialog() {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (context) => AlertDialog(
        title: Container(
          width: 500,
          height: 170,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Profile Update',
                style: TextStyle(
                  color: Color.fromRGBO(223, 32, 48, 1),
                ),
              ),
              Divider(
                color: Color.fromRGBO(223, 32, 48, 1),
              ),
              Column(
                children: [
                  Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Flexible(
                        child: Text(
                          'Profile update was completed successfully. Log out and Log in to reflect the changes',
                          style: TextStyle(fontSize: 14),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouter.fadeScale(() => HomePage()),
                        (route) => false,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateProfile() async {
    final progress = ProgressHUD.of(_scaffoldKey.currentContext);
    progress.show();
    List<int> imageBytes = imgFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    Map data = {'profileImg': base64Image, 'userName': _userName};
    final response =
        await http.post(Uri.parse('${tumiaApi}updateProfile.php'), body: data);
    if (response.statusCode == 200) {
      var responseResult = jsonDecode(response.body);
      print(responseResult);
      var responseStatus = responseResult['success'];
      if (responseStatus == true) {
        progress.dismiss();
        _saveSession(responseResult['image'].toString());
      } else {
        progress.dismiss();
        ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
          SnackBar(content: Text("${responseResult['message']}")),
        );
      }
    } else {
      progress.dismiss();
      ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
        SnackBar(content: Text('Login failed ${response.statusCode}')),
      );
    }
  }

  _saveSession(String profilePicture) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('profilePicture', profilePicture);
    preferences.reload();
    _successDialog();
  }
}

class LimitItem extends StatelessWidget {
  final String k, v;
  LimitItem(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(k),
          MediumText(
            v,
            fontWeight: FontW.bold,
          ),
        ],
      ),
    );
  }
}

class ImageBox extends StatelessWidget {
  final File img;
  final String profilePicture;
  ImageBox({this.img, this.profilePicture});

  @override
  Widget build(BuildContext context) {
    const double _ring = 88;
    const _avatar = _ring - 10;
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor,
          width: 1.8,
        ),
        // borderRadius: Corners.lgBorder,

        image: img == null
            ? DecorationImage(
                image: NetworkImage("$tumiaApi$profilePicture?v="),
                fit: BoxFit.cover,
              )
            : DecorationImage(
                image: FileImage(img),
                fit: BoxFit.cover,
              ),
      ),
      padding: EdgeInsets.all(10),
    );
  }
}
