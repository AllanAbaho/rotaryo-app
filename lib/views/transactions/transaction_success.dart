import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumiapesa/styles.dart';
import 'package:tumiapesa/utils/resources.dart';
import 'package:tumiapesa/utils/routing.dart';
import 'package:tumiapesa/views/home/home.dart';
import 'package:tumiapesa/views/transactions/transactions.dart';
import 'package:tumiapesa/widgets/buttons/elevated.button.dart';
import 'package:tumiapesa/widgets/flexibles/spacers.dart';
import 'package:tumiapesa/widgets/image.dart';
import 'package:tumiapesa/widgets/text.dart';
import 'package:tumiapesa/utils/extension.dart';

class TransactionSuccessPage extends StatelessWidget {
  final String title,
      body,
      btnText,
      imgUrl,
      name,
      plateNumber,
      paymentType,
      charge,
      amount,
      narration,
      receipient,
      balance,
      agentId,
      transactionRef,
      dateTime;
  final VoidCallback callback;
  final int templateId;
  final bool showStatement;
  TransactionSuccessPage({
    this.title,
    this.body,
    this.callback,
    this.btnText,
    this.imgUrl,
    this.narration,
    this.receipient,
    this.name,
    this.paymentType,
    this.plateNumber,
    this.balance,
    this.charge,
    this.amount,
    this.agentId,
    this.dateTime,
    this.transactionRef,
    this.templateId = 1,
    this.showStatement = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (templateId) {
      case 2:
        return Scaffold(
            body: Template2(
          title: title,
          body: body,
          btnText: btnText,
          balance: balance,
          showStatement: showStatement,
          callback: callback,
        ));
      case 3:
        return Scaffold(
            body: Template3(
          title: title,
          body: body,
          btnText: btnText,
          showStatement: showStatement,
          callback: callback,
          transactionRef: transactionRef,
          name: name,
          balance: balance,
          paymentType: paymentType,
          dateTime: dateTime,
          agentId: agentId,
          amount: amount,
          charge: charge,
          plateNumber: plateNumber,
        ));
      case 4:
        return Scaffold(
          body: Template4(
            title: title,
            body: body,
            btnText: btnText,
            balance: balance,
            showStatement: showStatement,
            callback: callback,
            imgUrl: imgUrl,
          ),
        );
      default:
        return Scaffold(
            body: Template1(
          title: title,
          body: body,
          btnText: btnText,
          balance: balance,
          showStatement: showStatement,
          callback: callback,
        ));
    }
  }
}

class Template1 extends StatelessWidget {
  final String title, body, btnText, balance;
  final VoidCallback callback;
  final bool showStatement;
  Template1({
    this.title,
    this.body,
    this.balance,
    this.callback,
    this.btnText,
    this.showStatement = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Insets.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MediumText(
            title ?? 'Transaction Successful',
            align: TextAlign.center,
            size: FontSizes.s20,
          ),
          VSpace.md,
          VSpace.lg,
          Container(
            height: 120,
            width: 120,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFFFFF7E1),
              shape: BoxShape.circle,
            ),
            child: LocalImage(
              AppImages.hand,
            ),
          ),
          VSpace.lg,
          SmallText(
            body ?? '',
            align: TextAlign.center,
          ),
          VSpace.lg,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.width / 4),
            child: PElevatedbtn(
              'OK',
              onTap: () => callback == null
                  ? Navigator.pushAndRemoveUntil(
                      context,
                      PageRouter.fadeScale(() => HomePage()),
                      (route) => false,
                    )
                  : callback.call(),
            ),
          ),
          VSpace.md,
        ],
      ),
    );
  }
}

class Template2 extends StatelessWidget {
  final String title, body, btnText, balance;
  final VoidCallback callback;
  final bool showStatement;
  Template2({
    this.title,
    this.body,
    this.callback,
    this.balance,
    this.btnText,
    this.showStatement = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Insets.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MediumText(
            title ?? 'Transaction Successful',
            align: TextAlign.center,
            size: FontSizes.s20,
          ),
          VSpace.md,
          SmallText(
            body ?? '',
            align: TextAlign.center,
          ),
          VSpace.lg,
          Container(
            height: 120,
            width: 120,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFFFFF7E1),
              shape: BoxShape.circle,
            ),
            child: LocalImage(
              AppImages.hand,
            ),
          ),
          VSpace.lg,
          VSpace.lg,
          PElevatedbtn(btnText ?? 'Another transaction', onTap: () {
            callback == null
                ? Navigator.pushAndRemoveUntil(
                    context,
                    PageRouter.fadeScale(() => HomePage()),
                    (route) => false,
                  )
                : callback.call();
          }),
          VSpace.md,
          if (showStatement)
            SmallText(
              'View statement',
              align: TextAlign.center,
            ).onTap(() {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouter.fadeScale(
                  () => TransactionsPage(
                    showAppbar: true,
                  ),
                ),
                (route) => route.isFirst,
              );
            }),
        ],
      ),
    );
  }
}

class Template3 extends StatelessWidget {
  final String title,
      body,
      btnText,
      name,
      plateNumber,
      paymentType,
      charge,
      amount,
      balance,
      agentId,
      transactionRef,
      dateTime;

  final VoidCallback callback;
  final bool showStatement;

  Template3({
    this.title,
    this.body,
    this.callback,
    this.btnText,
    this.name,
    this.balance,
    this.paymentType,
    this.plateNumber,
    this.charge,
    this.amount,
    this.agentId,
    this.dateTime,
    this.transactionRef,
    this.showStatement = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Insets.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VSpace.md,
            MediumText(
              title ?? 'Transaction Successful',
              align: TextAlign.center,
              size: FontSizes.s20,
            ),
            VSpace.md,
            Container(
              height: 60,
              width: 60,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFFF7E1),
                shape: BoxShape.circle,
              ),
              child: LocalImage(
                AppImages.hand,
              ),
            ),
            VSpace.md,
            Container(
              padding: EdgeInsets.all(Insets.lg - 8),
              decoration: BoxDecoration(
                  borderRadius: Corners.lgBorder, color: Color(0xAAFAFAFA)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: LocalImage(
                      AppIcons.icon,
                      height: 44,
                    ),
                  ),
                  VSpace.md,
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {},
                      clipBehavior: Clip.hardEdge,
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                          padding: EdgeInsets.zero,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          LocalImage(AppImages.btnWave),
                          Center(
                            child: MediumText('Loan (Boda Boda Banja)'),
                          )
                        ],
                      ),
                    ),
                  ),
                  VSpace.lg,
                  //ReceiptItem('Transaction type', paymentType),
                  ReceiptItem('Name', name),
                  ReceiptItem('Number Plate', plateNumber),
                  ReceiptItem('Amount', 'UGX. $amount'),
                  ReceiptItem('Charge', 'UGX. $charge'),
                  ReceiptItem('Total Amount',
                      'UGX. ${double.parse(amount) + double.parse(charge)}'),
                  ReceiptItem('Agent ID', agentId),
                  ReceiptItem('Agent Location', 'Kampala'),
                  ReceiptItem('Transaction ID', transactionRef),
                  ReceiptItem('Date', dateTime),
                ],
              ),
            ),
            SmallText(
              body ?? '',
              align: TextAlign.center,
            ),
            VSpace.lg,
            PElevatedbtn(btnText ?? 'Another transaction', onTap: () {
              _updateBalance(balance);
              callback == null
                  ? Navigator.pushAndRemoveUntil(
                      context,
                      PageRouter.fadeScale(() => HomePage()),
                      (route) => false,
                    )
                  : callback.call();
            }),
            VSpace.md,
            if (showStatement)
              SmallText(
                'View statement',
                align: TextAlign.center,
              ).onTap(() {
                _updateBalance(balance);
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouter.fadeScale(
                    () => TransactionsPage(
                      showAppbar: true,
                    ),
                  ),
                  (route) => route.isFirst,
                );
              }),
          ],
        ),
      ),
    );
  }

  _updateBalance(String balance) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
      'accountBalance',
      balance,
    );
  }
}

class Template4 extends StatelessWidget {
  final String title, body, btnText, imgUrl, balance;
  final VoidCallback callback;
  final bool showStatement;
  Template4({
    this.title,
    this.body,
    this.balance,
    this.callback,
    this.btnText,
    this.imgUrl,
    this.showStatement = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Insets.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MediumText(
            title ?? 'Transaction Successful',
            align: TextAlign.center,
            size: FontSizes.s20,
          ),
          VSpace.md,
          VSpace.lg,
          Container(
            height: 120,
            width: 120,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFFFFF7E1),
              shape: BoxShape.circle,
            ),
            child: LocalImage(
              AppImages.hand,
            ),
          ),
          VSpace.md,
          LocalImage(
            imgUrl ?? AppImages.wenreco,
            height: 100,
            width: 100,
            fit: BoxFit.contain,
          ),
          VSpace.lg,
          SmallText(
            body ?? '',
            align: TextAlign.center,
          ),
          VSpace.lg,
          PElevatedbtn(btnText ?? 'Another transaction', onTap: () {
            callback == null
                ? Navigator.pushAndRemoveUntil(
                    context,
                    PageRouter.fadeScale(() => HomePage()),
                    (route) => false,
                  )
                : callback.call();
          }),
          VSpace.md,
          if (showStatement)
            SmallText(
              'View statement',
              align: TextAlign.center,
            ).onTap(() {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouter.fadeScale(
                  () => TransactionsPage(
                    showAppbar: true,
                  ),
                ),
                (route) => route.isFirst,
              );
            }),
          VSpace.md,
        ],
      ),
    );
  }

  _updateBalance(String balance) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
      'accountBalance',
      balance,
    );
  }
}

class ReceiptItem extends StatelessWidget {
  final String k, v;
  ReceiptItem(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Insets.sm),
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
