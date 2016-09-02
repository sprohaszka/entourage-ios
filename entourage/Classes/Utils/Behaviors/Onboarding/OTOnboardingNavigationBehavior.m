//
//  OTOnboardingNavigationBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingNavigationBehavior.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@interface OTOnboardingNavigationBehavior ()

@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTOnboardingNavigationBehavior

- (void)awakeFromNib {
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

- (void)nextFromLogin {
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(self.currentUser.email.length > 0)
        [self nextFromEmail];
    else
        [self gotoEmail];
}

- (void)nextFromEmail {
    if(self.currentUser.firstName.length > 0 && self.currentUser.lastName.length > 0)
        [self nextFromName];
    else
        [self gotoName];
}

- (void)nextFromName {
    if(self.currentUser.avatarURL.length > 0)
        [self gotoRights];
    else
        [self gotoPicture];
}

#pragma mark - private methods

- (void)gotoEmail {
    UIStoryboard *profileDetailsStoryboard = [UIStoryboard storyboardWithName:@"UserProfileDetails" bundle:nil];
    UIViewController *emailViewController = [profileDetailsStoryboard instantiateInitialViewController];
    [self.owner.navigationController pushViewController:emailViewController animated:YES];
}

- (void)gotoName {
    UIStoryboard *profileDetailsStoryboard = [UIStoryboard storyboardWithName:@"UserProfileDetails" bundle:nil];
    UIViewController *nameController = [profileDetailsStoryboard instantiateViewControllerWithIdentifier:@"NameScene"];
    [self.owner.navigationController pushViewController:nameController animated:YES];
}

- (void)gotoPicture {
    UIStoryboard *userPictureStoryboard = [UIStoryboard storyboardWithName:@"UserPicture" bundle:nil];
    UIViewController *pictureViewController = [userPictureStoryboard instantiateInitialViewController];
    [self.owner.navigationController pushViewController:pictureViewController animated:YES];
}

- (void)gotoRights {
    UIStoryboard *rightsStoryboard = [UIStoryboard storyboardWithName:@"Rights" bundle:nil];
    UIViewController *rightsViewController = [rightsStoryboard instantiateInitialViewController];
    [self.owner.navigationController pushViewController:rightsViewController animated:YES];
}

@end
