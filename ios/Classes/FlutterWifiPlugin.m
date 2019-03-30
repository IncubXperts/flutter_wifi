#import "FlutterWifiPlugin.h"
#import <flutter_wifi/flutter_wifi-Swift.h>

@implementation FlutterWifiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterWifiPlugin registerWithRegistrar:registrar];
}
@end
