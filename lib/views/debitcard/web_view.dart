import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CardPayment extends StatefulWidget {
  final String url;

  CardPayment(this.url);
  @override
  CardPaymentState createState() => CardPaymentState();
}

class CardPaymentState extends State<CardPayment> {
  WebViewController webView;
  final _cardKey = GlobalKey();
  bool isLoading = false;
  bool ignoreTaps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Card Payment'),
      body: IgnorePointer(
        ignoring: ignoreTaps,
        child: ProgressHUD(
          child: Column(
            key: _cardKey,
            children: [
              Expanded(
                child: WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: widget.url,
                  onPageStarted: (value) {
                    setState(() {
                      ignoreTaps = true;
                      ProgressHUD.of(_cardKey.currentContext)
                          .showWithText('Loading....');
                    });
                  },
                  onPageFinished: (value) {
                    setState(() {
                      ignoreTaps = false;
                      ProgressHUD.of(_cardKey.currentContext).dismiss();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
