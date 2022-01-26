import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class TumiaPesaBanner extends StatelessWidget {
  final String imgUrl, title, subtitle;
  TumiaPesaBanner({this.imgUrl, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: context.width,
      padding: EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              LocalImage(
                imgUrl,
                fit: BoxFit.contain,
                height: 27,
              ),
              HSpace.md,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MediumText(
                    title,
                    color: Colors.white,
                  ),
                  SmallText(
                    subtitle,
                    color: Colors.white,
                  )
                ],
              )
            ],
          ),
          LocalImage(
            AppImages.logo2,
            fit: BoxFit.contain,
            height: 24,
          ),
        ],
      ),
    );
  }
}
