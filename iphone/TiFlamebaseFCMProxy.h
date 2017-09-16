//
//  TiFlamebaseFCMProxy.h
//  TiFlamebase
//
//  Created by asyncerror on 08/09/17.
//
//

#import "TiProxy.h"
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseInstanceID/FirebaseInstanceID.h>
#import <FirebaseMessaging/FirebaseMessaging.h>

@interface TiFlamebaseFCMProxy : TiProxy<FIRMessagingDelegate, TiProxyDelegate, UIApplicationDelegate>
{
    
    // The JavaScript callbacks (KrollCallback objects)
    KrollCallback *didReceiveRemoteNotificationCallback;
    KrollCallback *willPresentNotificationCallback;
    KrollCallback *didReceiveNotificationResponseCallback;
    KrollCallback *didRefreshRegistrationTokenCallback;
    KrollCallback *didReceiveMessageCallback;
    KrollCallback *didFailToRegisterForRemoteNotificationsWithErrorCallback;
    KrollCallback *userNotificationSettingsCallback;
}

@end
