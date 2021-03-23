//
//  AppDelegate.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/8.
//

#import "AppDelegate.h"
#import "Config.h"

#import "WebRTCManager.h"

#import "CallViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[CallViewController alloc]init]];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    
//   [[WebRTCManager shareInstance]initIceServers:defaultIceServers];
//    
//  
//    NSString *url = [NSString stringWithFormat:@"%@",socket_server];
//    [[SocketManager shareInstance]initSocket: url];
    
   
   
    return YES;
}



@end
