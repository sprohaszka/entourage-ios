//
//  OTDeepLinkService.m
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDeepLinkService.h"
#import "OTAppDelegate.h"
#import "OTActiveFeedItemViewController.h"
#import "OTSWRevealViewController.h"
#import "SVProgressHUD.h"
#import "OTFeedItemFactory.h"
#import "OTUserViewController.h"
#import "OTPublicFeedItemViewController.h"
#import "OTAPIConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTLoginViewController.h"
#import "OTMainViewController.h"
#import "OTSelectAssociationViewController.h"

@interface OTDeepLinkService ()

@property (nonatomic, weak) NSString *link;

@end

@implementation OTDeepLinkService

- (void)navigateTo:(NSNumber *)feedItemId withType:(NSString *)feedItemType {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createForType:feedItemType andId:feedItemId] getStateInfo] loadWithSuccess:^(OTFeedItem *feedItem) {
        [SVProgressHUD dismiss];
        [self prepareControllers:feedItem];
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)navigateTo: (NSString *)feedItemId {
    [SVProgressHUD show];
    if(TOKEN) {
        [[[OTFeedItemFactory createForId:feedItemId] getStateInfo] loadWithSuccess2:^(OTFeedItem *feedItem) {
        [SVProgressHUD dismiss];
        [self prepareControllers:feedItem];
        } error:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    }
    else {
        [self navigateToLogin];
        [SVProgressHUD dismiss];
    }
}

- (UIViewController *)getTopViewController {
    UIViewController *result = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([result isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealController = (SWRevealViewController*)result;
        result = revealController.frontViewController;
    }
    if([result isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)result;
        result = navController.topViewController;
    }
    return result;
}

- (void)showProfileFromAnywhereForUser:(NSNumber *)userId {
    UIStoryboard *userProfileStorybard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UINavigationController *rootUserProfileController = (UINavigationController *)[userProfileStorybard instantiateInitialViewController];
    OTUserViewController *userController = (OTUserViewController *)rootUserProfileController.topViewController;
    userController.userId = userId;
    UIViewController *currentController = [self getTopViewController];
    while(currentController.presentedViewController)
        currentController = currentController.presentedViewController;
    [currentController presentViewController:rootUserProfileController animated:YES completion:nil];
}

- (void)navigateToLogin {
    UIStoryboard *introStorybard = [UIStoryboard storyboardWithName:@"Intro" bundle:nil];
    OTLoginViewController *loginController = [introStorybard instantiateViewControllerWithIdentifier:@"OTLoginViewControllerIdentifier"];
    UIViewController *currentController = [self getTopViewController];
    loginController.fromLink = self.link;
    [currentController showViewController:loginController sender:self];
}

- (void)handleFeedAndBadgeLinks: (NSURL *)url {
    NSString *host = url.host;
    NSString *query = url.query;
    self.link = host;
    if(!TOKEN) {
        [self navigateToLogin];
    } else {
        if ([host isEqualToString:@"feed"]) {
            UIStoryboard *mainStorybard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            OTMainViewController *mainController = (OTMainViewController *)[mainStorybard instantiateInitialViewController];
            [self updateAppWindow:mainController];
        } else if ([host isEqualToString:@"badge"]) {
            OTSelectAssociationViewController *selectAssociationController = (OTSelectAssociationViewController *)[self instatiateControllerWithStoryboardIdentifier:@"UserProfileEditor" andControllerIdentifier:@"SelectAssociation"];
            [self showController:selectAssociationController];
        } else if ([host isEqualToString:@"webview"]) {
            OTMainViewController *publicFeedItemController = (OTMainViewController *)[self instatiateControllerWithStoryboardIdentifier:@"Main"
                                    andControllerIdentifier:@"OTMain"];
            NSArray *elts = [query componentsSeparatedByString:@"="];
            publicFeedItemController.webview = elts[1];
            [self showController:publicFeedItemController];
        }
    }
}

- (UIViewController *)instatiateControllerWithStoryboardIdentifier: (NSString *)storyboardId
                                           andControllerIdentifier: (NSString *)controllerId {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardId bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:controllerId];
    return controller;
}

- (void)showController: (UIViewController *)controller {
    OTSWRevealViewController *revealController = [self setupRevealController];
    UINavigationController *mainController = (UINavigationController *)revealController.frontViewController;
    [mainController setViewControllers:@[mainController.topViewController, controller]];
    [self updateAppWindow:revealController];
}

- (void)prepareControllers:(OTFeedItem *)feedItem {
    if([[[OTFeedItemFactory createFor:feedItem] getStateInfo] isPublic]) {
        UIStoryboard *publicFeedItemStorybard = [UIStoryboard storyboardWithName:@"PublicFeedItem" bundle:nil];
        OTPublicFeedItemViewController *publicFeedItemController = (OTPublicFeedItemViewController *)[publicFeedItemStorybard instantiateInitialViewController];
        publicFeedItemController.feedItem = feedItem;
        [self showController:publicFeedItemController];
    }
    else {
        UIStoryboard *activeFeedItemStorybard = [UIStoryboard storyboardWithName:@"ActiveFeedItem" bundle:nil];
        OTActiveFeedItemViewController *activeFeedItemController = (OTActiveFeedItemViewController *)[activeFeedItemStorybard instantiateInitialViewController];
        activeFeedItemController.feedItem = feedItem;
        [self showController:activeFeedItemController];
    }
}

- (OTSWRevealViewController *)setupRevealController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OTSWRevealViewController *revealController = [mainStoryboard instantiateInitialViewController];
    UIViewController *menuController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MenuNavController"];
    UINavigationController *mainController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainNavController"];
    revealController.frontViewController = mainController;
    revealController.rearViewController = menuController;
    return revealController;
}

- (void)updateAppWindow:(UIViewController *)revealController {
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    window.rootViewController = revealController;
    [window makeKeyAndVisible];
}

@end
