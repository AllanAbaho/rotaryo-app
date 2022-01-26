import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:tumiapesa/widgets/appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage(this.url);
  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  WebViewController webView;
  bool isLoading = false;
  ProgressHUD progress;
  final _webKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(context, title: 'Contact Us'),
      body: ProgressHUD(
        child: Column(
          key: _webKey,
          children: [
            Expanded(
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: widget.url,
                onPageStarted: (value) {
                  setState(() {
                    ProgressHUD.of(_webKey.currentContext).showWithText('Loading...');
                  });
                },
                onPageFinished: (value) {
                  setState(() {
                    ProgressHUD.of(_webKey.currentContext).dismiss();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
