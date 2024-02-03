//
//  AppDelegate.m
//  Shathi
//
//  Created by Sujan on 5/15/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "AppDelegate.h"
@import GoogleMaps;
@import GooglePlaces;
@import Firebase;
#import "UserAccount.h"
#import "ServerManager.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate,FIRMessagingDelegate>
@end
#endif



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [GMSServices provideAPIKey:@"AIzaSyDh0V-13fNhKpvJaMF-kvfTFEE-tpOZJJk"];
    
    [GMSPlacesClient provideAPIKey:@"AIzaSyDh0V-13fNhKpvJaMF-kvfTFEE-tpOZJJk"];
    
    // Use Firebase library to configure APIs
    [FIRApp configure];
    
    
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            // For iOS 10 display notification (sent via APNS)
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
#endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    
    return YES;
}

//-(void) askForNotificationPermission
//{
//    UIUserNotificationType allNotificationTypes =
//    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
//    UIUserNotificationSettings *settings =
//    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];
//    
//    
//    
//}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken
                                        type:FIRInstanceIDAPNSTokenTypeUnknown];
    
    
    NSString *deviceTokenString = [[NSString stringWithFormat:@"%@",deviceToken] stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceTokenString = [deviceTokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    
    NSLog(@"deviceToken %@",deviceTokenString);
    NSLog(@"refreshedToken %@",refreshedToken);
    
    
    
    [UserAccount sharedManager].gcmRegKey=refreshedToken;
    
    if ([refreshedToken isEqualToString:@"<null>"] || [refreshedToken isEqualToString:@"(null)"] || [refreshedToken isEqual:[NSNull null]] || refreshedToken==nil ) {
        
        NSLog(@"refreshedToken is null");
        
    }else{
        
        [UserAccount sharedManager].gcmRegKey=refreshedToken;
        
        NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
        
        [postData setObject:[NSString stringWithFormat:@"%@",[UserAccount sharedManager].gcmRegKey] forKey:@"gcm_registration_key"];
        
        
        [[ServerManager sharedManager] patchUpdateGcmKey:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
            
            
            NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken method");
            
        }];
        
    }
    
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    
    NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
    // [END receive_apns_token_error]
    NSDictionary *userInfo = @{@"error" :error.localizedDescription};
    
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"userInfo %@",userInfo);
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"rideNotification" object:self userInfo:userInfo];
    
    completionHandler(UIBackgroundFetchResultNoData);
}


- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    
    
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
    
    
    [UserAccount sharedManager].gcmRegKey=refreshedToken;
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%@",[UserAccount sharedManager].gcmRegKey] forKey:@"gcm_registration_key"];
    
    
    [[ServerManager sharedManager] patchUpdateGcmKey:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
        
        
    }];
    
}

- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
    
      NSLog(@"app become active applicationDidBecomeActive ");
   
    [[ServerManager sharedManager] getBackgroundScenarioWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            
            NSLog(@"user info applicationDidBecomeActive%@",responseObject);
            
            int status = [[responseObject objectForKey:@"status"]intValue];
            
            
            [UserAccount sharedManager].userStatus = status;
            
            NSLog(@"[UserAccount sharedManager].status %d",[UserAccount sharedManager].userStatus);
            
            if (status != 1) {

                [[NSNotificationCenter defaultCenter] postNotificationName:@"becomeActiveNotification" object:self userInfo:responseObject];
            }
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
