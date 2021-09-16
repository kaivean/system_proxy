package com.kaivean.system_proxy;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.Map;
import android.net.ProxyInfo;

import android.net.ConnectivityManager;
import android.os.Build;
import android.content.Context;

import androidx.annotation.NonNull;

/** SystemProxyPlugin */
public class SystemProxyPlugin implements FlutterPlugin, MethodCallHandler {
  private ConnectivityManager manager;
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "system_proxy");
    channel.setMethodCallHandler(this);
    manager = (ConnectivityManager)flutterPluginBinding.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getProxySettings")) {
      getNetworkType(manager, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void getNetworkType(ConnectivityManager manager,  Result result) {
    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      ProxyInfo defaultProxy = manager.getDefaultProxy();

      if (defaultProxy != null) {
        Map map = new HashMap<String, String>();
        map.put("host", defaultProxy.getHost());
        map.put("port", Integer.toString(defaultProxy.getPort()));
        result.success(map);
        return;
      }
    }
    result.success(null);
  }
}