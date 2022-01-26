import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class CustomerCarePage extends StatefulWidget {
  @override
  _CustomerCarePageState createState() => _CustomerCarePageState();
}

class _CustomerCarePageState extends State<CustomerCarePage> {
  final _border = OutlineInputBorder(
    borderRadius: Corners.lgBorder,
    borderSide: BorderSide(
      color: Color(0xFFDFDFDF),
      width: 0.8,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppbar(context, title: 'Customer care'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Column(
              children: [
                VSpace.md,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyles.body1.copyWith(
                          color: Colors.black,
                          fontSize: FontSizes.s16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search for articles',
                          hintStyle: TextStyles.body1
                              .copyWith(color: Color(0xFF6F6F6F)),
                          isDense: true,
                          border: _border,
                          enabledBorder: _border,
                          focusedBorder: _border.copyWith(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSpace.md,
                    Container(
                      height: 53,
                      width: 53,
                      padding: EdgeInsets.all(Insets.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: Corners.lgBorder,
                      ),
                      child: LocalImage(
                        AppIcons.searchWhite,
                        height: 16,
                      ),
                    )
                  ],
                ),
                VSpace.md,
                ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _BlogWidget(
                      title: 'Getting Started On Tumia Pesa',
                      body:
                          'Someone tried to access your account with an unrecognised time. click on this notification to confirm that it was you.',
                      readTime: '5mins read',
                    ),
                    _BlogWidget(
                      title: 'Getting Started On Tumia Pesa',
                      body:
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam',
                      readTime: '5mins read',
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

class _BlogWidget extends StatelessWidget {
  final String title, body, readTime;
  _BlogWidget({
    this.title,
    this.body,
    this.readTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 200,
      margin: EdgeInsets.only(bottom: Insets.md),
      padding: EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFFAFAFA),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocalImage(
              AppIcons.check,
              height: 16,
            ),
            VSpace.sm,
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.h3.copyWith(color: AppColors.primaryColor),
            ),
            VSpace.sm,
            Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.caption,
            ),
            VSpace.sm,
            SmallText(
              readTime,
              color: Colors.black,
              fontWeight: FontW.bold,
            )
          ]),
    );
  }
}
