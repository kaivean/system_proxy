import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:system_proxy/system_proxy.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _proxyStr = 'loading';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String proxyStr;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Map<String, String>? proxy = await SystemProxy.getProxySettings();
      if (proxy != null) {
        proxyStr = '${proxy["host"]}:${proxy["port"]}';
      }
      else {
        proxyStr = 'no proxy';
      }
    } on PlatformException {
      proxyStr = 'Failed to get system proxy.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _proxyStr = proxyStr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SystemProxy Plugin example app'),
        ),
        body: Center(
          child: Text('proxy setting on: $_proxyStr\n'),
        ),
      ),
    );
  }
}
