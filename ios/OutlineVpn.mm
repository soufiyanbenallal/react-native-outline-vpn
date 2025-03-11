#import "OutlineVpn.h"

#import <NetworkExtension/NetworkExtension.h>

@implementation OutlineVpn
NETunnelProviderManager *manager;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(startVpn:(NSString *)host
                  port:(NSInteger)port
                  password:(NSString *)password
                  method:(NSString *)method
                  prefix:(NSString *)prefix
                  providerBundleIdentifier:(NSString *)providerBundleIdentifier
                  serverAddress:(NSString *)serverAddress
                  tunnelId:(NSString *)tunnelId
                  localizedDescription:(NSString *)localizedDescription
                  successCallback:(RCTPromiseResolveBlock)successCallback
                  rejectCallback:(RCTPromiseResolveBlock)rejectCallback)
{
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> *managers, NSError *error) {
        if (error) {
            rejectCallback(@[@"VPN Manager cannot retrived: %@", error.localizedDescription]);
            return;
        }

        __block NETunnelProviderManager *manager;
        if (managers.count > 0) {
            manager = managers.firstObject;
        } else {
            manager = [[NETunnelProviderManager alloc] init];
        }

        manager.localizedDescription = localizedDescription;
        manager.onDemandRules = nil;

        NETunnelProviderProtocol *config = [[NETunnelProviderProtocol alloc] init];
        config.serverAddress = serverAddress;
        config.providerBundleIdentifier = providerBundleIdentifier;

        config.providerConfiguration = @{
            @"tunnelId": tunnelId,
            @"host": host,
            @"port": @(port),
            @"password": password,
            @"method": method,
            @"prefix": prefix,
        };
        manager.protocolConfiguration = config;

        manager.enabled = YES;

        [manager saveToPreferencesWithCompletionHandler:^(NSError *saveError) {
            if (saveError) {
                rejectCallback(@[@"VPN settings couldn't saved: %@", saveError.localizedDescription]);
                return;
            }

            [manager loadFromPreferencesWithCompletionHandler:^(NSError *loadError) {
                if (loadError) {
                    rejectCallback(@[@"VPN settings couldn't reloaded: %@", loadError.localizedDescription]);
                } else {
                    NSError *startError;
                    [manager.connection startVPNTunnelAndReturnError:&startError];
                  if (startError) {
                      rejectCallback(@[@"Failed to start VPN Tunnerl: %@", startError]);
                  } else {
                      successCallback(@[@"VPN started successfuly"]);
                  }
                }
            }];
        }];
    }];

}

@end
