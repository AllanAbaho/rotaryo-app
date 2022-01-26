import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';

class NotificationsPage extends StatefulWidget  {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();

}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppbar(context, title: 'Notifications'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Column(
              children: [
                VSpace.md,
                Chip(
                  label: SmallText(
                    '2+ Messages unread',
                    color: Colors.white,
                  ),
                  backgroundColor: AppColors.primaryColor,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                VSpace.md,
                ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _NotificationWidget(
                      title: 'Security Alert',
                      body:
                          'Someone tried to access your account with an unrecognised time. click on this notification to confirm that it was you.',
                      date: '21 sept 4:44pm',
                      seen: false,
                    ),
                    _NotificationWidget(
                      title: 'Update',
                      body:
                          'Kindly update your application for better experience',
                      date: '12 sept 1:00am',
                      seen: false,
                    ),
                    _NotificationWidget(
                      title: 'Terms and condition',
                      body:
                          'We have updated our terms and condition to serve you better. Kindly read it up.',
                      date: '10 sept 3:00am',
                    ),
                    _NotificationWidget(
                      title: 'Terms and condition',
                      body:
                          'We have updated our terms and condition to serve you better. Kindly read it up.',
                      date: '10 sept 3:00am',
                    ),
                    _NotificationWidget(
                      title: 'Terms and condition',
                      body:
                          'We have updated our terms and condition to serve you better. Kindly read it up.',
                      date: '10 sept 3:00am',
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

class _NotificationWidget extends StatelessWidget {
  final String title, body, date;
  final bool seen;
  _NotificationWidget({
    this.title,
    this.body,
    this.date,
    this.seen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 120,
      margin: EdgeInsets.only(bottom: Insets.md),
      padding: EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        borderRadius: Corners.lgBorder,
        color: seen ? Color(0xFFFAFAFA) : Color(0xFFECEBEB),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          children: [
            LocalImage(
              AppIcons.icon,
              height: 24,
            ),
            HSpace.sm,
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.h3,
              ),
            ),
            SmallText(date),
          ],
        ),
        VSpace.xs,
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.caption,
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
