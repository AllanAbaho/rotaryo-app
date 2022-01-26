import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';

class BottomBarItem {
  final String label;
  final Widget icon;
  final Widget activeIcon;
  BottomBarItem({
    this.label,
    this.icon,
    this.activeIcon,
  });
}

class CustomBottomBar extends StatelessWidget {
  final List<BottomBarItem> items;
  final Color selectedColor;
  final Color unselectedColor;
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomBar({
    this.items,
    this.currentIndex,
    this.selectedColor,
    this.unselectedColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: context.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((e) {
          final bool active = items.indexOf(e) == currentIndex;
          return Container(
            width: context.width / items.length,
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(
                color: AppColors.greyColor.withOpacity(0.09),
                width: 0.8,
              ),
            )),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 2,
                  decoration: BoxDecoration(
                    color: active ? selectedColor : Colors.transparent,
                  ),
                ),
                VSpace(12),
                if (active) e.activeIcon else e.icon,
                HSpace(4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    e.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.caption.copyWith(
                      fontWeight: FontW.bold,
                      color: active ? selectedColor : unselectedColor,
                      fontSize: FontSizes.s11,
                    ),
                  ),
                ),
              ],
            ),
          ).onTap(() => onTap(items.indexOf(e)));
        }).toList(),
      ),
    );
  }
}
