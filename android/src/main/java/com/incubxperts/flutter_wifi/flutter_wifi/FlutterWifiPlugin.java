package com.incubxperts.flutter_wifi.flutter_wifi;

import android.content.Context;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/** FlutterWifiPlugin */
public class FlutterWifiPlugin implements MethodCallHandler {
  /** Plugin registration. */

  private final Registrar registrar;
  private WifiUtil wifiUtil;

  private FlutterWifiPlugin(Registrar registrar, WifiUtil wifiUtil) {
    this.registrar = registrar;
    this.wifiUtil = wifiUtil;
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_wifi");
    WifiManager wifiManager = (WifiManager) registrar.activeContext().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    final WifiUtil wifiUtil = new WifiUtil(registrar.activity(), wifiManager);
    registrar.addRequestPermissionsResultListener(wifiUtil);

    // support Android O,listen network disconnect event
    // https://stackoverflow.com/questions/50462987/android-o-wifimanager-enablenetwork-cannot-work
    IntentFilter filter = new IntentFilter();
    filter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);
    filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
    registrar
            .context()
            .registerReceiver(wifiUtil.networkReceiver,filter);

    channel.setMethodCallHandler(new FlutterWifiPlugin(registrar, wifiUtil));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (registrar.activity() == null) {
      result.error("no_activity", "wifi plugin requires a foreground activity.", null);
      return;
    }
    switch (call.method) {
      case "ssid":
        wifiUtil.getSSID(call, result);
        break;
      case "level":
        wifiUtil.getLevel(call, result);
        break;
      case "ip":
        wifiUtil.getIP(call, result);
        break;
      case "list":
        wifiUtil.getWifiList(call, result);
        break;
      case "connection":
        wifiUtil.connection(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
