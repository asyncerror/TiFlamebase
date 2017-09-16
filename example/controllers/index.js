// ===============================================================================
// FCM Cloud Messaging example
// Attention, the module only has the function to receive messages by Firebase. 
// No other Firebase Cloud Messaging functions were implemented except 
// those listed here.
// @platform iOS
// ===============================================================================

$.index.open();

var flamebase = require("ti.flamebase");

var fcm = flamebase.createFCM();

fcm.registerCallbacks({

    "didReceiveRemoteNotificationCallback": pushReceived,
    "willPresentNotificationCallback": pushReceived,
    "didReceiveNotificationResponseCallback": pushReceived,
    "didRefreshRegistrationTokenCallback": didRefreshRegistrationTokenCallback,
    "userNotificationSettingsCallback": userNotificationSettingsCallback,
    "didFailToRegisterForRemoteNotificationsWithErrorCallback": didFailToRegisterForRemoteNotificationsWithErrorCallback
});

fcm.configure({log:true});

// Ask the user to receive notifications
fcm.registerForNotification();

if(OS_IOS) Ti.App.addEventListener('resume', appResume);

$.label.text += "Pushs will be shown here";

// app open with notification
if(Ti.App.getArguments().UIApplicationLaunchOptionsRemoteNotificationKey) {

    var launchOptions_pushData = Ti.App.getArguments().UIApplicationLaunchOptionsRemoteNotificationKey;

    launchOptions_pushData.type = "didReceiveNotificationResponseCallback";

    pushReceived(launchOptions_pushData);
};

// ===============================================================================
// Handlers
// ===============================================================================

/**
 * App resumed, check notification settings and other stuff if needed.
 */
function appResume() {

    Ti.API.info("[appResume]");

    userNotificationSettingsCallback();
}

/**
 * Notification received while in background or foreground.
 */
function pushReceived(data) {

    var message = data.aps.alert;

    $.label.text += "\ntype: " + data.type;
    $.label.text += "\nmessage: " + data.aps.alert;
    $.label.text += "\n--------------------------------------------";

    if(data.type == "didReceiveNotifcationResponseCallback") {
        // User oppened the app by tapping notification
    }

    Ti.API.info("[pushReceived] type:", data.type, "message:", message);
}

/**
 * Called one time when FCM token is generated.
 * Firebase can refresh the FCM token on some occasions.
 */
function didRefreshRegistrationTokenCallback(data) {

    $.label.text += "\n--------------------------------------------";

    // Make sure you save the APNS Token, because Firebase will not save it.
    if(data.apnsToken != "") {

        $.label.text += "\nAPNS Token: " + data.apnsToken;
        
        // Save it
    }

    $.label.text += "\nFCM Token: " + data.fcmToken;
    $.label.text += "\n--------------------------------------------";

    // if you need get FCM Token later, use:
    // fcm.fcmToken();

    Ti.API.info("[didRefreshRegistrationTokenCallback]", JSON.stringify(data));
}

/**
 * Check the user configuration settings to see if user enabled 
 * Push Notification.
 */
function userNotificationSettingsCallback() {

    if(Ti.App.iOS.currentUserNotificationSettings.types.length == 0) {
        // User disabled Push Notification
    }

    Ti.API.info("[userNotificationSettingsCallback]", Ti.App.iOS.currentUserNotificationSettings.types.length);
}

/**
 */
function didFailToRegisterForRemoteNotificationsWithErrorCallback(data) {

    Ti.API.info("[didFailToRegisterForRemoteNotificationsWithErrorCallback]", JSON.stringify(data));
}
