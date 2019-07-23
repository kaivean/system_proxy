package com.kaivean.system_proxy;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.HashMap;
import java.util.Map;
import android.net.ProxyInfo;

import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

/** SystemProxyPlugin */
public class SystemProxyPlugin implements MethodCallHandler {
  private final Registrar registrar;
  private final ConnectivityManager manager;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "system_proxy");
    channel.setMethodCallHandler(new SystemProxyPlugin(registrar));
  }

  private SystemProxyPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.manager =
            (ConnectivityManager)
                    registrar
                            .context()
                            .getApplicationContext()
                            .getSystemService(Context.CONNECTIVITY_SERVICE);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getProxySettings")) {
      getNetworkType(manager, result);
    } else {
      result.notImplemented();
    }
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