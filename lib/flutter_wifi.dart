import 'dart:async';

import 'package:flutter/services.dart';

enum WifiState { error, success, already }

class FlutterWifi {
  static const MethodChannel _channel = const MethodChannel('flutter_wifi');

  static Future<String> get ssid async {
    return await _channel.invokeMethod('ssid');
  }

  static Future<int> get level async {
    return await _channel.invokeMethod('level');
  }

  static Future<String> get ip async {
    return await _channel.invokeMethod('ip');
  }

  static Future<List<WifiResult>> list({String filter}) async {
    final Map<String, dynamic> params = {
      'filter': filter,
    };
    var results = await _channel.invokeMethod('list', params);
    List<WifiResult> resultList = [];
    for (int i = 0; i < results.length; i++) {
      resultList.add(WifiResult(results[i]['ssid'], results[i]['level']));
    }
    return resultList;
  }

  static Future<WifiState> connection(String ssid, String password) async {
    final Map<String, dynamic> params = {
      'ssid': ssid,
      'password': password,
    };
    int state = await _channel.invokeMethod('connection', params);
    switch (state) {
      case 0:
        return WifiState.error;
      case 1:
        return WifiState.success;
      case 2:
        return WifiState.already;
      default:
        return WifiState.error;
    }
  }

  static Future<bool> isWifiEnabled() async {
    bool isWifiEnabled = await _channel.invokeMethod('getWifiStatus');
    return isWifiEnabled;
  }

  static Future<bool> turnWifiOnOff({bool enable = true}) async {
    final Map<String, dynamic> params = {
      'enable': enable,
    };
    bool result = await _channel.invokeMethod('changeWifiStatus', params);
    return result;
  }
}

class WifiResult {
  String ssid;
  int level;

  WifiResult(this.ssid, this.level);
}
