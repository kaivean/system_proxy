#import "SystemProxyPlugin.h"
#import <system_proxy/system_proxy-Swift.h>

@implementation SystemProxyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSystemProxyPlugin registerWithRegistrar:registrar];
}
@end
