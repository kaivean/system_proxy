#include "system_proxy_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#include <WinHttp.h>
#include <string>
#pragma comment(lib, "winhttp")

namespace system_proxy {

// static
void SystemProxyPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "system_proxy",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<SystemProxyPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

SystemProxyPlugin::SystemProxyPlugin() {}

SystemProxyPlugin::~SystemProxyPlugin() {}


// Function to convert LPWSTR (wide string) to std::string (UTF-8 encoded)
std::string SystemProxyPlugin::LPWSTRToString(LPWSTR wideStr) {
  // Get the required buffer size for the UTF-8 string
  int bufferSize = WideCharToMultiByte(CP_UTF8, 0, wideStr, -1, nullptr, 0, nullptr, nullptr);

  // Allocate buffer with the required size
  std::vector<char> buffer(bufferSize);

  // Perform the conversion from wide string to UTF-8 string
  WideCharToMultiByte(CP_UTF8, 0, wideStr, -1, buffer.data(), bufferSize, nullptr, nullptr);

  // Create and return a std::string with the converted UTF-8 data
  return std::string(buffer.data());
}

std::string SystemProxyPlugin::MapToJson(const std::unordered_map<std::string, std::string>& map) {
  std::stringstream json_stream;
  json_stream << "{";

  for (auto it = map.begin(); it != map.end(); ++it) {
    if (it != map.begin()) {
      json_stream << ",";
    }
    json_stream << "\"" << it->first << "\":\"" << it->second << "\"";
  }

  json_stream << "}";
  return json_stream.str();
}


void SystemProxyPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getProxySettings") == 0) {
    std::unordered_map<std::string, std::string> proxyConfigMap;

    WINHTTP_CURRENT_USER_IE_PROXY_CONFIG proxyConfig;
    // Retrieve the proxy configuration for the current user
    if (WinHttpGetIEProxyConfigForCurrentUser(&proxyConfig)) {
      // Check if an automatic configuration URL is set
      if (proxyConfig.lpszAutoConfigUrl) {
        proxyConfigMap["autoConfigUrl"] = LPWSTRToString(proxyConfig.lpszAutoConfigUrl);
      }
      // Check if a manual proxy setting is provided
      if (proxyConfig.lpszProxy) {
        proxyConfigMap["proxy"] = LPWSTRToString(proxyConfig.lpszProxy);
      }
      // Check if a proxy bypass setting is provided
      if (proxyConfig.lpszProxyBypass) {
        proxyConfigMap["proxyBypass"] = LPWSTRToString(proxyConfig.lpszProxyBypass);
      }
      GlobalFree(proxyConfig.lpszAutoConfigUrl);
      GlobalFree(proxyConfig.lpszProxy);
      GlobalFree(proxyConfig.lpszProxyBypass);
    }

    std::string json_str = MapToJson(proxyConfigMap);
    result->Success(flutter::EncodableValue(json_str));
  } else {
    result->NotImplemented();
  }
}

}  // namespace system_proxy
