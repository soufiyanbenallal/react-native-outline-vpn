import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import Outline from 'react-native-outline-vpn';

export default function App() {
  React.useEffect(() => {
    // THIS VPN INFORMATIONS INTENTIONALLY LEFT EXPOSED, HAS 0 MB LIMIT SO CANNOT ACCESS INTERNET BUT COULD BE USE FOR TEST VPN CONNECTION
    Outline.startVpn({
      host:'185.218.124.25',
      port: 42248,
      password: 'FQZV7mWkAB3l7pzg7tpv9p',
      method: 'chacha20-ietf-poly1305',
      prefix: '\u0005\u00DC\u005F\u00E0\u0001\u0020', //vpn prefix
      providerBundleIdentifier: 'com.outlinevpnexample.OutlineVPN', //apple bundle identifier declared step-2 on guide
      serverAddress: 'OutlineServer', //can be any string which user see MyPreciousVpn
      tunnelId: 'OutlineTunnel', //can be random string
      localizedDescription: 'OutlineVpn', //can be random string

    });
  }, []);

  return (
    <View style={styles.container}>
      <Text>VPN Starting...</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
