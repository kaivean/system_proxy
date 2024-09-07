#include "include/system_proxy/system_proxy_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "system_proxy_plugin.h"

void SystemProxyPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  system_proxy::SystemProxyPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
