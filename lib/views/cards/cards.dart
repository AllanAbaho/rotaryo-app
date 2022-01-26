import 'package:flutter/material.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/cards/add_from_wallet.dart';
import 'package:tumiapesa/views/cards/add_mobile_money.dart';
import 'package:tumiapesa/views/cards/manage_cards.dart';
import 'package:tumiapesa/views/cards/withdraw_to_wallet.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/utils/extension.dart';
import 'package:tumiapesa/widgets/text.dart';

// ignore: avoid_implementing_value_types
class CardsPage extends StatefulWidget implements HomeWidget {
  @override
  _CardsPageState createState() => _CardsPageState();

  @override
  String get tag => "Cards";
}

class _CardsPageState extends State<CardsPage> {
  bool revealCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          Center(child: SmallText('balance')),
          Center(
            child: BigText(
              'UGX56,900',
              fontWeight: FontWeight.w800,
            ),
          ),
          VSpace.md,
          SizedBox(
            height: 200,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: List.generate(
                2,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? Insets.lg : Insets.md,
                    // here i == (cards length -1) should be used here
                    right: i == 1 ? Insets.lg : 0,
                  ),
                  child: CardWidget(
                    color: i == 1 ? AppColors.primaryColor : null,
                    reveal: revealCard,
                  ),
                ),
              ),
            ),
          ),
          VSpace.md,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MediumText(
                  revealCard ? 'Hide card details' : 'Show card details',
                  size: FontSizes.s12,
                ).onTap(() => setState(() {
                      revealCard = !revealCard;
                    })),
                MediumText(
                  'Manage cards',
                  color: AppColors.primaryColor,
                  size: FontSizes.s12,
                ).onTap(
                  () => Navigator.push(
                    context,
                    PageRouter.fadeThrough(() => ManageCardsPage()),
                  ),
                ),
              ],
            ),
          ),
          VSpace.md,
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                HSpace.lg,
                _ActionWidget(
                  'Add Mobile money',
                  onTap: () => Navigator.push(
                    context,
                    PageRouter.fadeThrough(() => AddFromMobileMoneyPage()),
                  ),
                ),
                _ActionWidget(
                  'Add from Wallet',
                  onTap: () => Navigator.push(
                    context,
                    PageRouter.fadeThrough(() => AddFromWalletPage()),
                  ),
                ),
                _ActionWidget(
                  'Withdraw to wallet',
                  onTap: () => Navigator.push(
                    context,
                    PageRouter.fadeThrough(() => WithdrawToWalletPage()),
                  ),
                ),
                HSpace.lg,
              ],
            ),
          ),
          VSpace.lg,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: MediumText('Recent Transactions'),
            ),
          ),
          VSpace.md,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _TransactionWidget(
                  title: 'Apple store',
                  subtitle: 'You used this card on Apple store',
                  date: '12 Nov 9:34pm',
                  amount: 8000,
                ),
                _TransactionWidget(
                  title: 'Card funded',
                  subtitle: 'This card was funded with mobile money',
                  date: '12 sept 3:00am',
                  amount: 4300,
                  type: TransactionType.fund,
                ),
                _TransactionWidget(
                  title: 'Jumia',
                  subtitle: 'This card was used on jumia online store',
                  date: '10 sept 3:00am',
                  amount: 8000,
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}

class _ActionWidget extends StatelessWidget {
  final String label;
  final Function onTap;
  _ActionWidget(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: SmallText(
          label,
          color: AppColors.primaryColor,
        ),
        backgroundColor: Color(0xFFEFEFEF),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ).onTap(() => onTap());
  }
}

class _TransactionWidget extends StatelessWidget {
  final String title, subtitle, date;
  final int amount;
  final TransactionType type;
  _TransactionWidget({
    this.title,
    this.subtitle,
    this.date,
    this.amount,
    this.type = TransactionType.spend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 99,
      margin: EdgeInsets.only(bottom: Insets.md),
      padding: EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
          borderRadius: Corners.lgBorder, color: Color(0xFFFAFAFA)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.h3,
                ),
              ),
              if (type == TransactionType.fund)
                MediumText(
                  "+ UGX$amount",
                  color: Color(0xFF21BC22),
                )
              else
                MediumText(
                  "- UGX$amount",
                  color: AppColors.primaryColor,
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.caption,
                ),
              ),
              HSpace.sm,
              SmallText(date)
            ],
          )
        ],
      ),
    );
  }
}

class CardWidget extends StatefulWidget {
  final Color color;
  final bool reveal;
  CardWidget({this.color, this.reveal = false});

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: widget.color ?? Colors.black,
          ),
        ),
        Positioned(
          top: Insets.md,
          left: Insets.lg - Insets.md,
          bottom: Insets.md,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.reveal) ...[
                CardInfoWidget('CARD NUMBER', '5656 2878 2987 89268'),
                CardInfoWidget('EXPIRATION', '09/22'),
                CardInfoWidget('CVV', '423'),
              ] else ...[
                LocalImage(
                  AppImages.logo2,
                  height: 27,
                ),
                CardInfoWidget('Princess Shamirah'.toUpperCase(), '***9268'),
              ]
            ],
          ),
        ),
        Positioned(
          top: Insets.md,
          right: Insets.lg,
          bottom: Insets.lg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'USH',
                style: TextStyles.h3.copyWith(
                  color: Colors.white,
                ),
              ),
              LocalImage(AppImages.mastercard)
            ],
          ),
        )
      ],
    );
  }
}

class CardInfoWidget extends StatelessWidget {
  final String label, value;
  CardInfoWidget(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.caption.copyWith(
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: TextStyles.h3.copyWith(
            color: Colors.white,
            fontSize: FontSizes.s14,
          ),
        ),
      ],
    );
  }
}

enum TransactionType { fund, spend }
