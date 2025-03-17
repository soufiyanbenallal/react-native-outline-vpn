package com.outlinevpn;

import androidx.annotation.NonNull;
import android.content.Intent;
import android.net.VpnService;
import android.content.IntentFilter;
import static android.app.Activity.RESULT_OK;
import android.app.Activity;

import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;
import org.json.JSONException;
import org.json.JSONObject;

@ReactModule(name = OutlineVpnModule.NAME)
public class OutlineVpnModule extends ReactContextBaseJavaModule {
  public static final String NAME = "OutlineVpn";
  private static ReactApplicationContext _reactContext;
  private VpnTunnelStore vpnTunnelStore;
  private VpnTunnelService vpnTunnelService;
  private static final String TUNNEL_ID_KEY = "id";
  private static final String TUNNEL_CONFIG_KEY = "config";
  private static final String TUNNEL_SERVER_NAME = "serverName";

  public OutlineVpnModule(ReactApplicationContext reactContext) {
    super(reactContext);
    _reactContext = reactContext;
    vpnTunnelStore = new VpnTunnelStore(_reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void saveCredential(String host, int port, String password, String method, String prefix, Promise promise) {
      try {
        JSONObject tunnel = new JSONObject();
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("id", 0);
        jsonObject.put("host", host);
        jsonObject.put("port", port);
        jsonObject.put("password", password);
        jsonObject.put("method", method);
        jsonObject.put("prefix", prefix);
        tunnel.put(TUNNEL_ID_KEY, "0").put(
        TUNNEL_CONFIG_KEY, jsonObject).put(TUNNEL_SERVER_NAME, "OutlineVpn");
        vpnTunnelStore.save(tunnel);
        promise.resolve(true);
      } catch (Exception e) {
            promise.reject("VPN_CONNECTION_ERROR", e);
      }
  }

  @ReactMethod
  public void getCredential(Promise promise) {
      try {
        final JSONObject res = vpnTunnelStore.load();
        promise.resolve(res.toString());
      } catch (Exception e) {
            promise.reject("VPN_CONNECTION_ERROR", e);
      }
  }

  @ReactMethod
  public void prepareLocalVPN(Promise promise) {
      try {
          Intent intent = VpnService.prepare(getReactApplicationContext());
          if (intent != null) {
              _reactContext.addActivityEventListener(new BaseActivityEventListener() {
                  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
                      if(requestCode == 0 && resultCode == RESULT_OK){
                          promise.resolve(true);
                      } else {
                          promise.reject("PrepareError", "Failed to prepare");
                      }
                  }
              });
              getCurrentActivity().startActivityForResult(intent, 0);
          } else {
              promise.resolve(true);
          }
      } catch (Exception e) {
          promise.reject("VPN_CONNECTION_ERROR", "Error connecting to VPN", e);
      }
  }

  @ReactMethod
  public void connectLocalVPN(Promise promise) {
      Intent intent = VpnService.prepare(getReactApplicationContext());
      if (intent != null) {
          promise.reject("PrepareError", "Not prepared");
          return;
      }
      startVpnService();
      promise.resolve(true);
  }

  private void startVpnService() {
    Intent intent = new Intent(getReactApplicationContext(), VpnTunnelService.class);
    getReactApplicationContext().startService(intent);
  }
}
