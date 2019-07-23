import Flutter
import UIKit

public class SwiftSystemProxyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "system_proxy", binaryMessenger: registrar.messenger())
    let instance = SwiftSystemProxyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getProxySettings") {
      let systemProxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() ?? [:] as CFDictionary
      result(systemProxySettings as NSDictionary);
      return;
    }
  }
}
