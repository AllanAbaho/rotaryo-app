import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/apis.dart';
import 'package:tumiapesa/models/bills.dart';
import 'package:tumiapesa/storage/database_helper.dart';
import 'package:tumiapesa/utils/credentials.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/marketplace/paytv/packages.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/banner.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/inputs/textfield.dart';
import 'package:tumiapesa/widgets/text.dart';

class PayTvPage extends StatefulWidget {
  @override
  _PayTvPageState createState() => _PayTvPageState();
}

class _PayTvPageState extends State<PayTvPage> {
  bool save = true;
  final _formTvKey = GlobalKey<FormState>();
  String tvProvider, tvProviderImg, tvCustomerCode, reference;
  TextEditingController _decoderNumberController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Tv subscriptions'),
      body: ProgressHUD(
        child: Builder(
          builder: (context) => Form(
            key: _formTvKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                child: Column(
                  children: [
                    VSpace.md,
                    TumiaPesaBanner(
                      imgUrl: AppImages.tv,
                      title: 'TV Subsriptions',
                      subtitle: 'Anytime, anywhere',
                    ),
                    VSpace.sm,
                    SmallText(
                      "Buy your tv subcriptions with ease",
                      align: TextAlign.center,
                    ),
                    VSpace.md,
                    DropDownTextInputField(
                      labelText: 'Select provider',
                      isOnboardingField: true,
                      onSaved: (value) {
                        setState(() {
                          tvProvider = value.title;
                          tvProviderImg = value.imgUrl;
                          tvCustomerCode = value.value;
                        });
                      },
                      // ignore: prefer_const_literals_to_create_immutables
                      items: [
                        DropDownItem(
                          imgUrl: 'assets/images/dstv.png',
                          title: 'Dstv',
                          value: '215',
                        ),
                        DropDownItem(
                          imgUrl: 'assets/images/gotv.png',
                          title: 'Gotv',
                          value: '215',
                        ),
                        DropDownItem(
                          imgUrl: 'assets/images/star.jpeg',
                          title: 'Startimes',
                          value: '213',
                        ),
                        DropDownItem(
                          imgUrl: 'assets/images/azam.png',
                          title: 'Azam',
                          value: '433',
                        ),
                        DropDownItem(
                          imgUrl: 'assets/images/zukutv.png',
                          title: 'Zuku',
                          value: '258',
                        ),
                      ],
                    ),
                    VSpace.md,
                    TextInputField(
                      labelText: 'Enter Decoder Number',
                      helperText: "*10 digits",
                      controller: _decoderNumberController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Decoder Number';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    VSpace.md,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmallText('Save card details'),
                        Switch(
                          value: save,
                          onChanged: (value) => setState(
                            () {
                              save = !save;
                            },
                          ),
                          activeColor: AppColors.primaryColor,
                        )
                      ],
                    ),
                    VSpace.lg,
                    PElevatedbtn('Next', onTap: () {
                      if (_formTvKey.currentState.validate()) {
                        setState(() {
                          _formTvKey.currentState.save();
                        });
                        Navigator.push(
                          _formTvKey.currentContext,
                          PageRouter.fadeThrough(
                            () => TvPackagesPage(
                                tvCustomerCode,
                                _decoderNumberController.text,
                                tvProvider,
                                tvProviderImg),
                          ),
                        );
                      }
                    }),
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
}
