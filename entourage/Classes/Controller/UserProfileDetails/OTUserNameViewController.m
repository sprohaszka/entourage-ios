//
//  OTUserNameViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTUserNameViewController.h"

#import "IQKeyboardManager.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIScrollView+entourage.h"
#import "NSUserDefaults+OT.h"
#import "OTAuthService.h"
#import "OTUserPictureViewController.h"
#import "NSError+message.h"
#import "OTOnboardingNavigationBehavior.h"

@interface OTUserNameViewController ()

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UIButton *validateButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;

@end

@implementation OTUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    
    [self.firstNameTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.lastNameTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.validateButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [self loadCurrentData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.firstNameTextField becomeFirstResponder];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)loadCurrentData {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(currentUser) {
        self.firstNameTextField.text = currentUser.firstName;
        self.lastNameTextField.text = currentUser.lastName;
    }
}

- (IBAction)doContinue {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.firstName = self.firstNameTextField.text;
    currentUser.lastName = self.lastNameTextField.text;
    
    [SVProgressHUD show];
    [[OTAuthService new] updateUserInformationWithUser:currentUser
                                               success:^(OTUser *user) {
                                                   // TODO phone is not in response so need to restore it manually
                                                   user.phone = currentUser.phone;
                                                   [NSUserDefaults standardUserDefaults].currentUser = user;
                                                   [SVProgressHUD dismiss];
                                                   [self.onboardingNavigation nextFromName];
                                               }
                                               failure:^(NSError *error) {
                                                   [SVProgressHUD showErrorWithStatus:[error userUpdateMessage]];
                                                   NSLog(@"ERR: something went wrong on onboarding user name: %@", error.description);
                                               }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];
}

@end