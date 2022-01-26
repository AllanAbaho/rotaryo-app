import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/contactus/web_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tumiapesa/views/privacypolicy/privacy_policy.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/text.dart';

class ContactUsPage extends StatefulWidget {
  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(47),
                bottomRight: Radius.circular(47),
              ),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: Insets.md, vertical: Insets.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(PhosphorIcons.caretLeftLight,
                              color: Colors.white)
                          .onTap(() => Navigator.pop(context)),
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VSpace.lg,
                    LocalImage(
                      AppImages.logo2,
                      height: 27,
                    ),
                    VSpace.sm,
                    LocalImage(
                      AppIcons.headset,
                      height: 36,
                    ),
                    VSpace.sm,
                    MediumText('Contact support', color: Colors.white),
                  ],
                ),
                Icon(PhosphorIcons.x, color: Colors.transparent),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ContactItem('Call us 24/7 on +256393252361',
                    imgUrl: AppIcons.call, onTap: () {
                  launch("tel://+256393252361");
                }),
                ContactItem(
                  'Email us at support@pivotpayts.com',
                  imgUrl: AppIcons.sms,
                  onTap: () {
                    launch(
                      'mailto:support@pivotpayts.com?subject=Customer Support&body=Contacting Customer Support on',
                    );
                  },
                ),
                ContactItem(
                  'Text us on +256393252361',
                  imgUrl: AppIcons.message,
                  onTap: () {
                    launch(
                      'sms:+256393252361?body=Requesting Customer Support',
                    );
                  },
                ),
                ContactItem(
                  'Facebook',
                  imgUrl: AppIcons.fb,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouter.fadeScale(
                        () => WebViewPage(
                          'https://www.facebook.com/Tumiapesa1/',
                        ),
                      ),
                    );
                  },
                ),
                ContactItem(
                  'Twitter',
                  imgUrl: AppIcons.twitter,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouter.fadeScale(
                        () => WebViewPage(
                          'https://twitter.com/pivotpayts',
                        ),
                      ),
                    );
                  },
                ),
                ContactItem(
                  'Website',
                  imgUrl: AppIcons.web,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouter.fadeScale(
                        () => WebViewPage(
                          'https://pivotpayts.com/',
                        ),
                      ),
                    );
                  },
                ),
                ContactItem(
                  'Terms and conditions',
                  imgUrl: AppIcons.list2,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouter.fadeThrough(() => PrivacyPolicyPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  final String label, imgUrl;
  final Function onTap;
  ContactItem(this.label, {this.imgUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: EdgeInsets.all(9),
      margin:
          EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.sm - 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14), color: Color(0xAAFAFAFA)),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: ImageIcon(
                AssetImage(imgUrl),
                color: AppColors.primaryColor,
                size: 18,
              ),
            ),
            HSpace.sm,
            Expanded(
              child: SmallText(
                label,
                size: FontSizes.s15,
              ),
            )
          ],
        ),
      ),
    );
  }
}
