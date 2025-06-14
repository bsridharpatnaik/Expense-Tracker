import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class BuildConfig {
  static var serverUrl = '';
  static var serverProdUrl = 'https://www.egcity.in/expense-tracker';
  // static var serverProdUrl = 'https://sabkainsurance.in/expense-tracker';
  static var serverTestUrl = 'https://app.nexus360.in/expense-tracker';
  static var authorization = '';
  static var username = '';
  static List<String> partyList = [];
  static bool appIsActive = false;
  static var debugModeKey = 'TMcVZVbWLF4ityu';
  static bool webPlatform = false;

  static isAndroid() {
    try {
      if (Platform.isAndroid) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static isIOS() {
    try {
      if (Platform.isIOS) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static isWeb() {
    try {
      if (kIsWeb) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
