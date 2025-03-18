export interface vpnOptions {
  host: string;
  port: number;
  password: string;
  method: string;
  providerBundleIdentifier?: string;
  prefix?: string;
  serverAddress?: string;
  tunnelId?: string;
  localizedDescription?: string;
}

export interface VpnModule {
  startVpn(options: VpnOptions): Promise<boolean | string>;
}

declare const vpnModule: VpnModule;
export default vpnModule;
export type startVPN = (data: vpnOptions) => Promise<String | Boolean>;
