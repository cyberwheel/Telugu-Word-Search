import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF9933);
  static const Color secondary = Color(0xFF009688);
  static const Color background = Color(0xFFFFF8E1);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color locked = Color(0xFF9E9E9E);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color gridCell = Color(0xFFFFFFFF);
  static const Color selectedCell = Color(0xFF2196F3);
  static const Color foundCell = Color(0xFF4CAF50);
  static const Color hintFlash = Color(0xFFFFEB3B);
}

class AppStrings {
  static const String appTitle = 'తెలుగు పద వినోదం';
  static const String subtitle = 'Telugu Pada Vinodham';
  static const String levelsUrl = 'https://gist.githubusercontent.com/YOUR_USERNAME/GIST_ID/raw/levels.json';
  
  static const String loading = 'Loading...';
  static const String noInternet = 'No Internet Connection';
  static const String retry = 'Retry';
  static const String watchAd = 'Watch Video';
  static const String insufficientCoins = 'Not enough coins!';
  static const String hintCost = '50';
  static const String rewardAmount = '100';
  static const String excellent = 'అద్భుతం!';
  
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
}

class AppSounds {
  static const String select = 'sounds/select.mp3';
  static const String success = 'sounds/success.mp3';
  static const String win = 'sounds/win.mp3';
  static const String error = 'sounds/error.mp3';
}

class AppAnimations {
  static const Duration gridShake = Duration(milliseconds: 300);
  static const Duration hintFlash = Duration(milliseconds: 500);
  static const Duration levelPulse = Duration(seconds: 1);
}
