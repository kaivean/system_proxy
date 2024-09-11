import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class SystemProxy {
  static const MethodChannel _channel =
      const MethodChannel('system_proxy');

  /// get system proxy
  /// Has fixed proxy, return: {port: 8899, host: 172.24.141.93}
  /// Has automatic proxy (iOS only), return: {url: http://example.com/wpad.dat}
  /// no proxy, return: null
  ///
  static Future<Map<String, String>?> getProxySettings() async {
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
      } else if (proxySetting['ProxyAutoConfigEnable'] == 1) {
        return {
          "url": proxySetting['ProxyAutoConfigURLString'].toString(),
        };
      }
    }
    else if (Platform.isWindows) {
      Map<String, String> result = {};

      // Map Keys
      //
      // see https://learn.microsoft.com/en-us/windows/win32/api/winhttp/ns-winhttp-winhttp_current_user_ie_proxy_config#members
      //
      // autoConfigUrl is lpszAutoConfigUrl
      // proxy is lpszProxy
      // proxyBypass is lpszProxyBypass
      final Map<Object?, Object?> proxySettingMap = await _channel.invokeMethod<dynamic>('getProxySettings');

      if (proxySettingMap['autoConfigUrl'] != null) {
        result['url'] = proxySettingMap['autoConfigUrl'].toString();
      }
      if (proxySettingMap['proxy'] != null) {
        final proxySplit = proxySettingMap['proxy'].toString().split(':');
        if (0 < proxySplit.length) {
          result['host'] = proxySplit[0];
        }
        if (1 < proxySplit.length) {
          result['port'] = proxySplit[1];
        }
      }
      if (proxySettingMap['proxyBypass'] != null) {
      }

      if (result.length == 0) {
        return null;
      } else {
        return result;
      }
    }
    return null;
  }
}
