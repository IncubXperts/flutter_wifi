import Flutter
import UIKit
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

public class SwiftFlutterWifiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_wifi", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterWifiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "ssid":
            let wifiName = getSSID()
            if(wifiName == "Not Found"){
                result(FlutterError(code: "UNAVAILABLE", message: "wifi name unavailable", details: nil))
            } else{
                result(wifiName)
            }
            break;
        case "level":
            let level = getSignalStrength()
            if(level == nil){
                result(0)
            } else{
                result(level)
            }
            break;
        case "ip":
            let ip = getIPAddress()
            if (ip == "error") {
                result(FlutterError(code: "UNAVAILABLE", message: "wifi name unavailable", details: nil))
            } else {
                result(ip)
            }
            break;
        default:
            break;
        }
    }
    
    func getSSID() -> String
    {
        var ssid = "Not Found"
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String ?? "Not Found"
                    break
                }
            }
        }
        return ssid
    }
    
    func getSignalStrength() -> Int? {
        let app = UIApplication.shared
        var rssi: Int?
        guard let statusBar = app.value(forKey: "statusBar") as? UIView, let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else {
            return rssi
        }
        for view in foregroundView.subviews {
            if let statusBarDataNetworkItemView = NSClassFromString("UIStatusBarDataNetworkItemView"), view .isKind(of: statusBarDataNetworkItemView) {
                if let val = view.value(forKey: "wifiStrengthRaw") as? Int {
                    rssi = val
                    break
                }
            }
        }
        return rssi
    }
    
    func getIPAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}
