import 'package:flutter/material.dart';

class AppIcons {
  static String iconPath(String ico, [String ext]) =>
      'assets/icons/$ico.${ext ?? "png"}';
  static String get bell => iconPath('bell');
  static String get caretDown => iconPath('caret_down');
  static String get menu => iconPath('menu');
  static String get transaction => iconPath('transaction');
  static String get wallet => iconPath('wallet');
  static String get card => iconPath('card');
  static String get transactionRed => iconPath('transaction_red');
  static String get cardRed => iconPath('card_red');
  static String get walletRed => iconPath('wallet_red');
  static String get electricity => iconPath('electricity');
  static String get loan => iconPath('loan');
  static String get send => iconPath('send');
  static String get topup => iconPath('topup');
  static String get chat => iconPath('chat');
  static String get tv => iconPath('tv');
  static String get utilities => iconPath('utilities');
  static String get list => iconPath('list');
  static String get people => iconPath('people');
  static String get lock => iconPath('lock');
  static String get notes => iconPath('notes');
  static String get icon => iconPath('icon');
  static String get call => iconPath('call-calling');
  static String get fb => iconPath('facebook');
  static String get web => iconPath('global-search');
  static String get headset => iconPath('headset');
  static String get list2 => iconPath('menu-board');
  static String get message => iconPath('message-text');
  static String get sms => iconPath('sms');
  static String get twitter => iconPath('twitter');
  static String get searchWhite => iconPath('search_white');
  static String get check => iconPath('check');
  static String get greenCheck => iconPath('green_check');
  static String get trash => iconPath('trash');
}

class AppImages {
  static String imagePath(String img, [String ext]) =>
      'assets/images/$img.${ext ?? "png"}';
  static String get logo => imagePath('logo');
  static String get logo2 => imagePath('rotary-logo');
  static String get login => imagePath('login');
  static String get loginBanner => imagePath('login-banner', 'jpg');
  static String get onboarding => imagePath('onboarding', 'gif');
  static String get onboarding2 => imagePath('onboarding2');
  static String get kudos => imagePath('kudos');
  static String get person1 => imagePath('person1');
  static String get person2 => imagePath('person2');
  static String get mastercard => imagePath('mastercard');
  static String get btnWave => imagePath('btn_wave');
  static String get blob1 => imagePath('blob1');
  static String get blob2 => imagePath('blob2');
  static String get blob3 => imagePath('blob3');
  static String get shieldTick => imagePath('shield_tick');
  static String get hand => imagePath('hand');
  static String get mtn => imagePath('mtn');
  static String get airtel => imagePath('airtel');
  static String get bodaboda => imagePath('bodaboda');
  static String get umeme => imagePath('umeme');
  static String get dstv => imagePath('dstv');
  static String get tv => imagePath('tv');
  static String get wenreco => imagePath('wenreco');
  static String get nwsc => imagePath('nwsc');
  static String get phoneIcon => imagePath('phone_icon');
  static String get sim => imagePath('sim');
  static String get flash => imagePath('flash');
  static String get xmas => imagePath('xmas');
  static String get uganda => imagePath('uganda');
  static String get pplogo => imagePath('pivot-logo');
}

class AppColors {
  static Color get primaryColor => Colors.blue[900];
  static Color get scaffoldColor => Colors.white;
  static Color get errorColor => Color(0xFFFE1B02);
  static Color get lightGrey => Color(0xFFD2D2D2);
  static Color get greyColor => Color(0xFF727272).withOpacity(0.48);
  static Color get greyColor2 => Color(0xFF5c5c5c);
}
