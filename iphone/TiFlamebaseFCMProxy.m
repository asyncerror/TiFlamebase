//
//  TiFlamebaseFCMProxy.m
//  TiFlamebase
//
//  Created by asyncerror on 08/09/17.
//
//
#import "TiFlamebaseFCMProxy.h"
#import "TiFlamebaseModule.h"
#import "TiUtils.h"
#import "TiApp.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface TiFlamebaseFCMProxy () <UNUserNotificationCenterDelegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation TiFlamebaseFCMProxy

NSString *const kGCMMessageIDKey = @"gcm.message_id";
NSString *const className = @"FCMProxy";

BOOL logInfo = NO;

#pragma mark Proxy Configuration

-(void)configure:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);

    logInfo = [TiUtils boolValue:@"log" properties:args def:NO];
    
    [FIRApp configure];
    
    [FIRMessaging messaging].delegate = self;
    
    if(logInfo) [TiFlamebaseModule log:className funcName:@"configure" message:@""];
}

-(void)registerCallbacks:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    if(logInfo) [TiFlamebaseModule log:className funcName:@"registerCallbacks" message:@""];
    
    ENSURE_ARG_FOR_KEY(didReceiveRemoteNotificationCallback, args, @"didReceiveRemoteNotificationCallback", KrollCallback);
    if(didReceiveRemoteNotificationCallback) {
        didReceiveRemoteNotificationCallback.type = @"didReceiveRemoteNotificationCallback";
        [didReceiveRemoteNotificationCallback retain];
    }

    ENSURE_ARG_FOR_KEY(willPresentNotificationCallback, args, @"willPresentNotificationCallback", KrollCallback);
    if(willPresentNotificationCallback) {
        willPresentNotificationCallback.type = @"willPresentNotificationCallback";
        [willPresentNotificationCallback retain];
    }
    
    ENSURE_ARG_FOR_KEY(didReceiveNotificationResponseCallback, args, @"didReceiveNotificationResponseCallback", KrollCallback);
    if(didReceiveNotificationResponseCallback) {
        didReceiveNotificationResponseCallback.type = @"didReceiveNotificationResponseCallback";
        [didReceiveNotificationResponseCallback retain];
    }
    
    ENSURE_ARG_FOR_KEY(didRefreshRegistrationTokenCallback, args, @"didRefreshRegistrationTokenCallback", KrollCallback);
    if(didRefreshRegistrationTokenCallback) {
        didRefreshRegistrationTokenCallback.type = @"didReceiveNotificationResponseCallback";
        [didRefreshRegistrationTokenCallback retain];
    }
    
    ENSURE_ARG_FOR_KEY(didReceiveMessageCallback, args, @"didReceiveMessageCallback", KrollCallback);
    if(didReceiveMessageCallback) {
        didReceiveMessageCallback.type = @"didReceiveMessageCallback";
        [didReceiveMessageCallback retain];
    }
    
    ENSURE_ARG_FOR_KEY(didFailToRegisterForRemoteNotificationsWithErrorCallback, args, @"didFailToRegisterForRemoteNotificationsWithErrorCallback", KrollCallback);
    if(didFailToRegisterForRemoteNotificationsWithErrorCallback) {
        didFailToRegisterForRemoteNotificationsWithErrorCallback.type = @"didFailToRegisterForRemoteNotificationsWithErrorCallback";
        [didFailToRegisterForRemoteNotificationsWithErrorCallback retain];
    }
    
    ENSURE_ARG_FOR_KEY(userNotificationSettingsCallback, args, @"userNotificationSettingsCallback", KrollCallback);
    if(userNotificationSettingsCallback) {
        userNotificationSettingsCallback.type = @"userNotificationSettingsCallback";
        [userNotificationSettingsCallback retain];

    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kTiUserNotificationSettingsNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        NSString *message = @"Check the user settings with: Ti.App.iOS.currentUserNotificationSettings.types";
        
        if(logInfo) [TiFlamebaseModule log:className funcName:@"didReceiveRemoteNotification" message:message];
        
        [self callbackHandler:userNotificationSettingsCallback data:message];
    }];

}

#pragma mark Proxy Utils

-(void)callbackHandler:(KrollCallback*)callback data:(id)data
{
    if(callback) [self _fireEventToListener:callback.type withObject:data listener:callback thisObject:nil];
}

-(id)fcmToken:(id)args
{
    return [FIRMessaging messaging].FCMToken;
}

-(NSString*)apnsToken
{
    NSData *token = [FIRMessaging messaging].APNSToken;
    
    if(token) {
    
        const unsigned *tokenBytes = [token bytes];
        NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
        return hexToken;
        
    } else return @"";
}

#pragma mark Handle Notification

-(void)registerForNotification:(id)args
{
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        
        if(logInfo) [TiFlamebaseModule log:className funcName:@"registerForNotification" message:@"iOS 7.1 or earlier"];

        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            if(logInfo) [TiFlamebaseModule log:className funcName:@"registerForNotification" message:@"iOS 8 or later"];
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            // For iOS 10 display notification (sent via APNS)
            if(logInfo) [TiFlamebaseModule log:className funcName:@"registerForNotification" message:@"iOS 10 or later"];
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
        // [END register_for_notifications]
    }
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    //if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //}
    
    if(logInfo) [TiFlamebaseModule log:className funcName:@"didReceiveRemoteNotification" message:userInfo];
    
    [self callbackHandler:didReceiveRemoteNotificationCallback data:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    //if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //}
    
    if(logInfo) [TiFlamebaseModule log:className funcName:@"didReceiveRemoteNotification" message:userInfo];
    
    [self callbackHandler:didReceiveRemoteNotificationCallback data:[userInfo mutableCopy]];
    
    completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    //if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //}
    
    if(logInfo) [TiFlamebaseModule log:className funcName:@"willPresentNotification" message:userInfo];
    
    [self callbackHandler:willPresentNotificationCallback data:[userInfo mutableCopy]];
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    //if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    //}
    
    if(logInfo) [TiFlamebaseModule log:className funcName:@"didReceiveNotificationResponse" message:userInfo];
    
    [self callbackHandler:didReceiveNotificationResponseCallback data:[userInfo mutableCopy]];
    
    completionHandler();
}
#endif
// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    //NSLog(@"FCM registration token: %@", fcmToken);fetchCompletionHandler
    
    // TODO: If necessary send token to application server.
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data setObject:fcmToken forKey:@"fcmToken"];
    [data setObject:[self apnsToken] forKey:@"apnsToken"];
    
    if(logInfo) [TiFlamebaseModule log:className funcName:@"didRefreshRegistrationToken" message:data];
    
    [self callbackHandler:didRefreshRegistrationTokenCallback data:data];
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    if(logInfo) [TiFlamebaseModule log:className funcName:@"didReceiveMessage" message:remoteMessage.appData];
    [self callbackHandler:didReceiveMessageCallback data:[remoteMessage.appData mutableCopy]];
}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if(logInfo) [TiFlamebaseModule log:className funcName:@"didFailToRegisterForRemoteNotificationsWithError" message:error.userInfo];
    [self callbackHandler:didFailToRegisterForRemoteNotificationsWithErrorCallback data:[error.userInfo mutableCopy]];
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
/*- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
    // [FIRMessaging messaging].APNSToken = deviceToken;
}*/


@end
