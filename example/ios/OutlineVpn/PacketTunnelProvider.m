//
//  PacketTunnelProvider.m
//  OutlineVpn
//
//  Created by Zafer ATLI on 16.03.2025.
//

#import "PacketTunnelProvider.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <netdb.h>

@import Tun2socks;

@interface PacketTunnelProvider ()<Tun2socksTunWriter>
@property id<Tun2socksOutlineTunnel> tunnel;
@property (nonatomic, copy) void (^startCompletion)(NSNumber *);
@property (nonatomic, copy) void (^stopCompletion)(NSNumber *);
@property (nonatomic, nullable) NSString *transportConfig;
@property (nonatomic) dispatch_queue_t packetQueue;
@property (nonatomic) BOOL isUdpSupported;
@end

@implementation PacketTunnelProvider

- (id)init {
  self = [super init];
  NSString *appGroup = @"group.outlineexample.vpn";
  NSURL *containerUrl = [[NSFileManager defaultManager]
                         containerURLForSecurityApplicationGroupIdentifier:appGroup];
  NSString *logsDirectory = [[containerUrl path] stringByAppendingPathComponent:@"Logs"];
  
  _packetQueue = dispatch_queue_create("org.outline.packetqueue", DISPATCH_QUEUE_SERIAL);
  [self showConfig];
  return self;
}

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
  NSLog(@"Starting tunnel");
  NEPacketTunnelNetworkSettings *networkSettings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"10.0.0.3"];
  
  // IP address configuration
  networkSettings.IPv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"10.0.0.2"] subnetMasks:@[@"255.255.255.0"]];
  
  // Routing configuration
  networkSettings.IPv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
  
  // DNS settings
  // networkSettings.DNSSettings = [[NEDNSSettings alloc] initWithServers:@[@"1.1.1.1", @"8.8.8.8"]];
  
  // Applying the network settings
  [self setTunnelNetworkSettings:networkSettings completionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Failed to set network settings: %@", error);
      completionHandler(error);
      return;
    }
    
    // Start tun2socks after network settings are applied
    dispatch_async(dispatch_get_main_queue(), ^{
    });
    [self startTun2Socks];
    completionHandler(nil);
  }];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
  NSLog(@"VPN Config Stop tunnel with reason");
  // Add code here to start the process of stopping the tunnel.
  completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
  NSLog(@"Starting tunnel");
  
  // Add code here to handle the message.
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
  NSLog(@"Starting tunnel");
  
  // Add code here to get ready to sleep.
  completionHandler();
}

- (void)wake {
  NSLog(@"Starting tunnel");
  
  // Add code here to wake up.
}

- (void)showConfig {
  
  NETunnelProviderProtocol *tunnelProtocol = (NETunnelProviderProtocol *)self.protocolConfiguration;

  NSDictionary *providerConfiguration = tunnelProtocol.providerConfiguration;

    if (providerConfiguration) {
      self.vpnConfig = @{
                 @"tunnelId": providerConfiguration[@"tunnelId"] ?: @"",
                 @"host": providerConfiguration[@"host"] ?: @"",
                 @"port": providerConfiguration[@"port"] ?: @(2222),
                 @"password": providerConfiguration[@"password"] ?: @"",
                 @"method": providerConfiguration[@"method"] ?:@"chacha20-ietf-poly1305",
                 @"prefix": providerConfiguration[@"prefix"] ?: @"",
             };
        NSLog(@"VPN Config: %@", self.vpnConfig);
    } else {
        NSLog(@"Provider configuration is empty!");
        NSError *error = [NSError errorWithDomain:@"CustomVPN" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Provider configuration not retrived"}];
        return;
    }
  
}

- (ShadowsocksClient*)ConnectSS {
    NETunnelProviderProtocol *tunnelProtocol = (NETunnelProviderProtocol *)self.protocolConfiguration;
    NSDictionary *providerConfiguration = tunnelProtocol.providerConfiguration;
  
    ShadowsocksConfig* config = [[ShadowsocksConfig alloc] init];
    config.host = providerConfiguration[@"host"];
    config.port = [providerConfiguration[@"port"] longValue];
    config.password = providerConfiguration[@"password"];
    config.cipherName = providerConfiguration[@"method"];
    
    NSError *error = nil;
    ShadowsocksClient *client = ShadowsocksNewClient(config, &error);
    long returnValue = -1;
    if (error != nil) {
        NSLog(@"Failed to construct client.");
    }
    return client;
}

- (void)showSSStatus:(long)status {
    switch (status) {
        case 0:
            NSLog(@"Shadows Stock Status -> NoError");
            break;
        case 1:
            NSLog(@"Shadows Stock Status -> Unexpected");
            break;
        case 2:
            NSLog(@"Shadows Stock Status -> NoVPNPermissions");
            break;
        case 3:
            NSLog(@"Shadows Stock Status -> AuthenticationFailure");
            break;
        case 4:
            NSLog(@"Shadows Stock Status -> UDPConnectivity");
            break;
        case 5:
            NSLog(@"Shadows Stock Status -> Unreachable");
            break;
        case 6:
            NSLog(@"Shadows Stock Status -> VpnStartFailure");
            break;
        case 7:
            NSLog(@"Shadows Stock Status -> IllegalConfiguration");
            break;
        case 8:
            NSLog(@"Shadows Stock Status -> ShadowsocksStartFailure");
            break;
        case 9:
            NSLog(@"Shadows Stock Status -> ConfigureSystemProxyFailure");
            break;
        case 10:
            NSLog(@"Shadows Stock Status -> NoAdminPermissions");
            break;
        case 11:
            NSLog(@"Shadows Stock Status -> UnsupportedRoutingTable");
            break;
        case 12:
            NSLog(@"Shadows Stock Status -> SystemMisconfigured");
            break;
        default:
            NSLog(@"Shadows Stock Status -> Error not found");
            break;
    }
    
}

- (void)startTun2Socks {
  NSLog(@"startTun2Socks has started!");
  __weak typeof(self) weakSelf = self;
  __block long bytesWritten = 0;
    NSError *err = nil;
    // Tun2socks interface initialization and start
  NSLog(@"startTun2Socks Connect SS Error");
    id client = [self ConnectSS];
    if (client == nil) {
      NSLog(@"startTun2Socks Client Error");
    }
    self.tunnel = Tun2socksConnectShadowsocksTunnel(weakSelf, client, false, &err);
    if (err != nil) {
        NSLog(@"startTun2Socks Connect error %@", err.localizedDescription);
      }
  if([self.tunnel isConnected]){
    NSLog(@"startTun2Socks connected");
  }else {
    NSLog(@"startTun2Socks error");

  }

  [weakSelf.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> *_Nonnull packets,
                                                          NSArray<NSNumber *> *_Nonnull protocols) {
      for (NSData *packet in packets) {
          // Her bir paketi tünele yaz
          [weakSelf.tunnel write:packet ret0_:&bytesWritten error:nil];
          
          if (bytesWritten < 0) {
              NSLog(@"Paket couldnt write.");
          } else {
              NSLog(@"%ld byte wrote.", bytesWritten);
          }
            dispatch_async(weakSelf.packetQueue, ^{
              [weakSelf processPackets];
            });
      }
  }];
}

- (void)startTun2Socks2 {
  NSLog(@"startTun2Socks started successfully");
  __weak typeof(self) weakSelf = self;
  __block long bytesWritten = 0;
  [weakSelf.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> *_Nonnull packets,
                                                          NSArray<NSNumber *> *_Nonnull protocols) {
    for (NSData *packet in packets) {
      [weakSelf.tunnel write:packet ret0_:&bytesWritten error:nil];
    }
    dispatch_async(self.packetQueue, ^{
      [weakSelf processPackets];
    });
  }];
}

- (BOOL)close:(NSError *_Nullable *)error {
  return YES;
}

- (BOOL)write:(NSData *_Nullable)packet n:(long *)n error:(NSError *_Nullable *)error {
  [self.packetFlow writePackets:@[ packet ] withProtocols:@[ @(AF_INET) ]];
  return YES;
}

- (void)processPackets {
  __weak typeof(self) weakSelf = self;
  __block long bytesWritten = 0;
  [weakSelf.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> *_Nonnull packets,
                                                          NSArray<NSNumber *> *_Nonnull protocols) {
    for (NSData *packet in packets) {
      [weakSelf.tunnel write:packet ret0_:&bytesWritten error:nil];
    }
    dispatch_async(weakSelf.packetQueue, ^{
      [weakSelf processPackets];
    });
  }];
}
@end
