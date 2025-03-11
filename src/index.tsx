import { NativeModules, Platform } from 'react-native';
import { type startVPN, type vpnOptions } from './types';

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

const startVpn: startVPN = (data: vpnOptions) => {
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
      resolve(true);
    } else {
      OutlineVpn.saveCredential(host, port, password, method, prefix).then(
        (credentialResult: any) => {
          if (credentialResult) {
            OutlineVpn.getCredential().then(() => {
              OutlineVpn.prepareLocalVPN().then(() => {
                OutlineVpn.connectLocalVPN()
                  .then(() => resolve(true))
                  .catch((e: any) => reject(e));
              });
            });
          }
        }
      );
    }
  });
};

export default {
  startVpn(options: vpnOptions): Promise<Boolean> {
    return startVpn(options);
  },
};
