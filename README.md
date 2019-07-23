# system_proxy

A Flutter Plugin to get system proxy setting. It is used to proxy for Flutter and Dart HttpClient request。Because Dart HttpClient is adapting the system proxy setting automatically in default, it's  difficult to grab requests for testing .

获取系统代理配置。
可用于为flutter的Dart `HttpClient`的请求设置代理，因为默认Dart请求不会理睬系统代理配置，这对于抓取请求来进行测试等场景造成不小困难。

## Getting Started

### Install

Please add the plugin to `pubspec.yaml`.

### Caution

It's useful for Android >= 23 .

### Usage

Import
```Dart
import 'package:system_proxy/system_proxy.dart';
```

Code
```Dart
// the proxy value likes:  {port: 8899, host: 127.0.0.1}
Map<String, String> proxy = await SystemProxy.getProxySettings();
if (proxy != null) {
    print('proxy $proxy');
}
```

### Setting Proxy for HttpClient

```Dart
class ProxiedHttpOverrides extends HttpOverrides {
  String _port;
  String _host;
  ProxiedHttpOverrides(this._host, this._port);

  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      // set proxy
      ..findProxy = (uri) {
        return _host != null ? "PROXY $_host:$_port;" : 'DIRECT';
      };
  }
}

void main() async {
  Map<String, String> proxy = await SystemProxy.getProxySettings();
  if (proxy == null) {
    proxy = {
    'host': null,
    'port': null
    };
  }
  HttpOverrides.global = new ProxiedHttpOverrides(proxy['host'], proxy['port']);
  runApp(MyApp());
}
```
