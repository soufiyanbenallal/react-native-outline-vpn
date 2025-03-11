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
