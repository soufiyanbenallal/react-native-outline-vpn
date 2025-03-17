/**
 * Start Outline VPN
 * @param callback A callback function that will receive the result of the suppression.
 *                 - result: A number representing the result of the suppression.
 *                           0: Not Supported
 *                           1: Already suppressed
 *                           2: Denied
 *                           3: Cancelled
 *                           4: Success
 */
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

export type startVPN = (data: vpnOptions) => Promise<String | Boolean>;
