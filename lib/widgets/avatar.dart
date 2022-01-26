import 'package:flutter/material.dart';
import 'package:tumiapesa/utils/resources.dart';

class Avatar extends StatelessWidget {
  final String imgUrl;
  final double height, width;
  Avatar({
    this.imgUrl,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(2),
      height: height ?? 47,
      width: width ?? 47,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            
            image: NetworkImage(
              imgUrl),
            //image: AssetImage(imgUrl ?? AppImages.person1),
          ),
        ),
      ),
    );
  }
}
