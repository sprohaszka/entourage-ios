//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTAppConfiguration.h"
#import <FirebaseMessaging/FirebaseMessaging.h>

NSString * const kLoginFailureNotification = @"loginFailureNotification";
NSString * const kUpdateGroupUnreadStateNotification = @"updateGroupUnreadStateNotification";
NSString * const kUpdateTotalUnreadCountNotification = @"updateTotalUnreadCountNotification";

@interface OTAppDelegate () <UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end

@implementation OTAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    
    [[OTAppConfiguration sharedInstance] configureApplication:application withOptions:launchOptions];
    
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [OTAppConfiguration applicationDidBecomeActive:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [OTAppConfiguration applicationWillEnterForeground:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [OTAppConfiguration applicationDidEnterBackground:application];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    return [OTAppConfiguration application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [OTAppConfiguration handleApplication:app openURL:url];
}

#pragma mark - Configure push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [OTAppConfiguration applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [OTAppConfiguration applicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [OTAppConfiguration applicationDidRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {

    [OTAppConfiguration application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [OTAppConfiguration application:application didReceiveLocalNotification:notification];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    [OTAppConfiguration userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    [OTAppConfiguration messaging:messaging didReceiveRegistrationToken:fcmToken];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    [OTAppConfiguration messaging:messaging didReceiveMessage:remoteMessage];
}

@end
