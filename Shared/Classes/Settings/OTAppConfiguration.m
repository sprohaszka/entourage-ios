//
//  OTAppConfiguration.m
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAppConfiguration.h"
#import "OTDeepLinkService.h"
#import "OTPushNotificationsData.h"
#import "OTVersionInfo.h"
#import "OTDeepLinkService.h"
#import "FBSDKCoreKit.h"
#import "OTLocationManager.h"
#import "OTUser.h"
#import "IQKeyboardManager.h"
#import "NSUserDefaults+OT.h"
#import "UIStoryboard+entourage.h"
#import "OTPushNotificationsService.h"
#import "OTPictureUploadService.h"
#import "OTAuthService.h"
#import "OTDeepLinkService.h"
#import "OTMainViewController.h"
#import "OTOngoingTourService.h"
#import "SVProgressHUD.h"
#import "UIColor+entourage.h"
#import "OTUnreadMessagesService.h"
#import "OTLoginViewController.h"
#import "OTLostCodeViewController.h"
#import "OTPhoneViewController.h"
#import "OTCodeViewController.h"
#import "OTAppDelegate.h"
#import "A0SimpleKeychain.h"
#import "UIStoryboard+entourage.h"
#import "OTMenuViewController.h"

#import "entourage-Swift.h"

@import Firebase;

const CGFloat OTNavigationBarDefaultFontSize = 17.f;

@interface OTAppConfiguration ()
@end

@implementation OTAppConfiguration

+ (OTAppConfiguration*)sharedInstance {
    static OTAppConfiguration* sharedInstance;
    static dispatch_once_t debugLogToken;
    dispatch_once(&debugLogToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pushNotificationService = [OTPushNotificationsService new];
        self.environmentConfiguration = [[EnvironmentConfigurationManager alloc] initWithBundleId:[[NSBundle mainBundle] bundleIdentifier]];
    }
    return self;
}

- (BOOL)configureApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {

    [self configurePushNotifcations];
    [self configureAnalyticsWithOptions:launchOptions];
    
    [OTAppConfiguration configureApplicationAppearance];
    [OTAppConfiguration configurePhotoUploadingService];
    
    [self launchApplicatioWithOptions:launchOptions];
    
    return YES;
}

- (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        if ([NSUserDefaults standardUserDefaults].isTutorialCompleted) {
            [[OTLocationManager sharedInstance] startLocationUpdates];
            NSDictionary *pnData = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (pnData) {
                [OTAppConfiguration handleAppLaunchFromNotificationCenter:pnData];
            } else {
                [OTAppConfiguration navigateToAuthenticatedLandingScreen];
            }
        }
        else {
            [OTAppConfiguration navigateToUserProfile];
        }
    }
    else
    {
        [OTAppConfiguration navigateToStartupScreen];
    }
}

- (void)popToLogin {
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    [SVProgressHUD show];
    
    [pnService clearTokenWithSuccess:^() {
        [SVProgressHUD dismiss];
        [OTAppConfiguration clearUserData];
        [OTAppConfiguration navigateToStartupScreen];
        
    } orFailure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [OTAppConfiguration clearUserData];
        [OTAppConfiguration navigateToStartupScreen];
    }];
}

- (void)updateBadge: (NSNotification *) notification {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[OTUnreadMessagesService new] totalCount].integerValue];
}

+ (void)clearUserData {
    [[NSUserDefaults standardUserDefaults] setCurrentUser:nil];
    [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour:nil];
    [[NSUserDefaults standardUserDefaults] setTourPoints:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPhone];
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPassword];
}

#pragma mark - Application State

+ (void)applicationDidBecomeActive:(UIApplication *)application {
    // Call the 'activateApp' method to log an app event for use
    // in analytics and advertising reporting.
    [FBSDKAppEvents activateApp];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                [mixpanel.people set:@{@"EntourageNotifEnable": @"YES"}];
                [FIRAnalytics setUserPropertyString:@"YES" forName:@"EntourageGeolocEnable"];
            }
            else {
                [mixpanel.people set:@{@"EntourageNotifEnable": @"NO"}];
                [FIRAnalytics setUserPropertyString:@"NO" forName:@"EntourageGeolocEnable"];
            }
        }];
    }
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
        [[OTLocationManager sharedInstance] startLocationUpdates];
    }
}

+ (void)applicationDidEnterBackground:(UIApplication *)application {
    if([OTOngoingTourService sharedInstance].isOngoing) {
        return;
    }
    [[OTLocationManager sharedInstance] stopLocationUpdates];
}

+ (void)handleAppLaunchFromNotificationCenter:(NSDictionary *)userInfo {
    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];
    if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST]) {
        [[OTDeepLinkService new] navigateTo:pnData.joinableId withType:pnData.joinableType];
    }
}

+ (BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url
{
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.runsOnStaging) {
        if ([[url scheme] isEqualToString:@"entourage-staging"]) {
            [[OTDeepLinkService new] handleDeepLink:url];
            return YES;
        }
    } else {
        if ([[url scheme] isEqualToString:@"entourage"]) {
            [[OTDeepLinkService new] handleDeepLink:url];
            return YES;
        }
    }

    return NO;
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        //NSArray *arrayWithStrings = [url.absoluteString componentsSeparatedByString:@"/"];
        //NSString *entourageId = arrayWithStrings.lastObject;
        //[[OTDeepLinkService new] navigateTo:entourageId];
        [[OTDeepLinkService new] handleUniversalLink:url];
    }
    return true;
}

+ (void)navigateToAuthenticatedLandingScreen
{
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        
        OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
        UIWindow *window = [appDelegate window];
        window.rootViewController = [OTAppConfiguration configureMainTabBar];
        [window makeKeyAndVisible];
        
        return;
    }
    
    [UIStoryboard showSWRevealController];
}

+ (void)navigateToUserProfile
{
    [UIStoryboard showUserProfileDetails];
}

+ (void)navigateToStartupScreen
{
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [UIStoryboard showStartup];
}

#pragma mark - App Configurations

- (void)configureAnalyticsWithOptions:(NSDictionary *)launchOptions
{
    [[OTDebugLog sharedInstance] setConsoleOutput];
    
#if !DEBUG
    [Fabric with:@[[Crashlytics class]]];
    [FIRApp configure];
#endif
    
    NSString *mixpanelToken = self.environmentConfiguration.MixpanelToken;
    
    [Mixpanel sharedInstanceWithToken:mixpanelToken launchOptions:launchOptions];
    [Mixpanel sharedInstance].enableLogging = YES;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    mixpanel.minimumSessionDuration = 0;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        [[OTAuthService new] getDetailsForUser:currentUser.sid success:^(OTUser *user) {
            [NSUserDefaults standardUserDefaults].currentUser = user;
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(NSError *error) {
            NSLog(@"@fails getting user %@", error.description);
        }];
        
        [OTLogger setupMixpanelWithUser:currentUser];
        [[OTAuthService new] sendAppInfoWithSuccess:nil failure:nil];
    }
}

- (void)configurePushNotifcations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToLogin) name:[kLoginFailureNotification copy] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge:) name:[kUpdateBadgeCountNotification copy] object:nil];
}

+ (void)configurePhotoUploadingService {
    [OTPictureUploadService configure];
}

+ (UITabBarController*)configureMainTabBar
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Menu tab
    OTMenuViewController *menuViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMenuViewControllerIdentifier"];
    UINavigationController *menuNavController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
    menuNavController.tabBarItem.title = @"menu";
    menuNavController.tabBarItem.image = [UIImage imageNamed:@"menu"];
    
    // Proximity Map Tab
    OTMainViewController *mainMapViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMain"];
    UINavigationController *mainMapNavController = [[UINavigationController alloc] initWithRootViewController:mainMapViewController];
    mainMapNavController.tabBarItem.title = @"à proximité";
    mainMapNavController.tabBarItem.image = [UIImage imageNamed:@"guide"];
    
    tabBarController.viewControllers = @[mainMapNavController, menuNavController];

    return tabBarController;
}

#pragma mark - Push notifications

+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:YES] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];
    @try {
        [pnService saveToken:deviceToken];
    }
    @catch (NSException *ex) {
        
    }
}

+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Push registration failure : %@", [error localizedDescription]);
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:NO] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    UIApplicationState state = [application applicationState];
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive) {
        [pnService handleRemoteNotification:userInfo];
    }
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    UIApplicationState state = [application applicationState];
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        [pnService handleLocalNotification:userInfo];
    }
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    if ([pnService isMixpanelDeepLinkNotification:userInfo]) {
        //for mixpanel deeplinks, shows the push notification
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    } else {
        [pnService handleRemoteNotification:userInfo];
    }
}

#pragma - Appearance

+ (void)configureApplicationAppearance
{
    UIColor *primaryNavigationBarTintColor = [UIColor whiteColor];
    UIColor *secondaryNavigationBarTintColor = [UIColor appOrangeColor];
    UIColor *backgroundThemeColor = [UIColor appOrangeColor];
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        backgroundThemeColor = [UIColor pfpBlueColor];
        secondaryNavigationBarTintColor = [UIColor pfpBlueColor];
    }
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.runsOnStaging) {
        primaryNavigationBarTintColor = [UIColor redColor];
    }

    [[ApplicationTheme shared] setPrimaryNavigationBarTintColor:primaryNavigationBarTintColor];
    [[ApplicationTheme shared] setSecondaryNavigationBarTintColor:secondaryNavigationBarTintColor];
    [[ApplicationTheme shared] setBackgroundThemeColor:backgroundThemeColor];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    UINavigationBar.appearance.barTintColor = primaryNavigationBarTintColor;
    UINavigationBar.appearance.backgroundColor = primaryNavigationBarTintColor;
    
    UIFont *navigationBarFont = [UIFont systemFontOfSize:OTNavigationBarDefaultFontSize weight:UIFontWeightRegular];
    UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor grayColor] };
    [UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0],
                                                          NSFontAttributeName : navigationBarFont } forState:UIControlStateNormal];
    
    UIPageControl.appearance.backgroundColor = [UIColor whiteColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor appGreyishBrownColor];
    
    UITabBar.appearance.backgroundColor = backgroundThemeColor;
    UITabBar.appearance.tintColor = primaryNavigationBarTintColor;
    UITabBar.appearance.barTintColor = backgroundThemeColor;
}

#pragma - Application flows

+ (BOOL)supportsTourFunctionality
{
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)supportsSolidarityGuideFunctionality
{
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

@end
