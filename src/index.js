import { NativeModules, Platform } from 'react-native';
const LINKING_ERROR =
  `The package 'react-native-outline-vpn' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';
const OutlineVpn = NativeModules.OutlineVpn
  ? NativeModules.OutlineVpn
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );
const startVpn: startVPN = (data) => {
  const {
    host,
    port,
    password,
    method,
    prefix,
    providerBundleIdentifier,
    serverAddress,
    tunnelId,
    localizedDescription,
  } = data;
  return new Promise((resolve, reject) => {
    if (Platform.OS === 'ios') {
      OutlineVpn.startVpn(
        host,
        port,
        password,
        method,
        prefix,
        providerBundleIdentifier,
        serverAddress,
        tunnelId,
        localizedDescription
      );
    } else {
      OutlineVpn.saveCredential(host, port, password, method, prefix).then(
        (credentialResult) => {
          if (credentialResult) {
            OutlineVpn.getCredential().then(() => {
              OutlineVpn.prepareLocalVPN().then(() => {
                OutlineVpn.connectLocalVPN()
                  .then((vpnResult) => resolve(vpnResult))
                  .catch((e) => reject(e));
              });
            });
          }
        }
      );
    }
  });
};

export default {
  startVpn(options) {
    return startVpn(options);
  },
};
