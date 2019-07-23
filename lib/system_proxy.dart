import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class SystemProxy {
  static const MethodChannel _channel =
      const MethodChannel('system_proxy');

  /// get system proxy
  /// Has proxy, return: {port: 8899, host: 172.24.141.93}
  /// no proxy, return: null
  ///
  static Future<Map<String, String>> getProxySettings() async {
    if (Platform.isAndroid) {

      dynamic proxySettingRes = await _channel.invokeMethod('getProxySettings');
      if (proxySettingRes != null) {
        Map<String, dynamic> proxySetting = Map<String, dynamic>.from(proxySettingRes);
        return {
          "port": proxySetting['port'].toString(),
          "host": proxySetting['host'].toString(),
        };
      }
    }
    else if (Platform.isIOS) {
      // 有代理时
      // {FTPPassive: 1, HTTPEnable: 1, HTTPPort: 8899, HTTPSProxy: 127.0.0.1, HTTPSPort: 8899, __SCOPED__: {en0: {HTTPEnable: 1, HTTPPort: 8899, HTTPSProxy: 127.0.0.1, HTTPSPort: 8899, FTPPassive: 1, HTTPProxy: 127.0.0.1, SOCKSEnable: 0, HTTPSEnable: 1}}, HTTPProxy: 127.0.0.1, HTTPSEnable: 1, SOCKSEnable: 0}
      // 无代理时
      // {FTPPassive: 1, HTTPEnable: 0, __SCOPED__: {en0: {HTTPEnable: 0, FTPPassive: 1, SOCKSEnable: 0, HTTPSEnable: 0}}, HTTPSEnable: 0, SOCKSEnable: 0}
      dynamic proxySettingRes = await _channel.invokeMethod('getProxySettings');
      Map<String, dynamic> proxySetting = Map<String, dynamic>.from(proxySettingRes);
      if (proxySetting['HTTPEnable'] == 1) {
        return {
          "port": proxySetting['HTTPPort'].toString(),
          "host": proxySetting['HTTPProxy'].toString(),
        };
      }
    }
    return null;
  }
}
