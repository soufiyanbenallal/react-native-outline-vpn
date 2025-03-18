# react-native-outline-vpn

Outline React Native Android & iOS Client

## Installation

```sh
npm install react-native-outline-vpn
```

or

```sh
yarn add react-native-outline-vpn
```

```tsx copy
import Outline from 'react-native-outline-vpn';
// THIS VPN INFORMATIONS INTENTIONALLY LEFT EXPOSED, HAS 0 MB LIMIT SO CANNOT ACCESS INTERNET BUT COULD BE USE FOR TEST VPN CONNECTION
Outline.startVpn({
	host:'185.218.124.25',
	port: 42248,
	password: 'FQZV7mWkAB3l7pzg7tpv9p',
	method: 'chacha20-ietf-poly1305',
	prefix: '\u0005\u00DC\u005F\u00E0\u0001\u0020', //vpn prefix
	providerBundleIdentifier: 'org.reactjs.native.example.OutlineVpnExample.OutlineVpn', //apple bundle identifier declared step-2 on guide
	serverAddress: 'OutlineServer', //can be any string which user see MyPreciousVpn
	tunnelId: 'OutlineTunnel', //can be random string
	localizedDescription: 'OutlineVpn', //can be random string
});
```

> Android hasn't need any additional configuration, but iOS needs some additional configuration. Please check the [documentation](https://rn-outline.vercel.app/) for more information.

Detailed documentation page: [Documantation](https://rn-outline.vercel.app/)

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
