//
//  OTUserNameViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <IQKeyboardManager/IQKeyboardManager.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "OTUserNameViewController.h"

#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"
#import "OTAuthService.h"
#import "OTUserPictureViewController.h"
#import "OTOnboardingNavigationBehavior.h"
#import "OTScrollPinBehavior.h"
#import "entourage-Swift.h"

@interface OTUserNameViewController ()

@property (nonatomic, weak) IBOutlet OnBoardingTextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet OnBoardingTextField *lastNameTextField;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;
@property (weak, nonatomic) IBOutlet OTScrollPinBehavior *scrollBehavior;
@property (weak, nonatomic) IBOutlet OnBoardingButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *nameDescLabel;

@end

@implementation OTUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;

    self.title = @"";
    [self.firstNameTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.lastNameTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    
    if (@available(iOS 10.0, *)) {
        self.firstNameTextField.textContentType = UITextContentTypeGivenName;
        self.lastNameTextField.textContentType = UITextContentTypeFamilyName;
    }
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self loadCurrentData];

    self.continueButton.enabled = [self formIsValid];
    self.firstNameTextField.inputValidationChanged = ^(BOOL isValid) {
        self.continueButton.enabled = [self formIsValid];
    };
    self.lastNameTextField.inputValidationChanged = ^(BOOL isValid) {
        self.continueButton.enabled = [self formIsValid];
    };
    
    [self.continueButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    
    self.nameDescLabel.text = [OTAppAppearance userProfileNameDescription];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTLogger logEvent: @"Screen30_5InputNameView"];
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //[self.scrollBehavior initialize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.firstNameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)loadCurrentData {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(currentUser) {
        self.firstNameTextField.text = currentUser.firstName;
        self.lastNameTextField.text = currentUser.lastName;
    }
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"NameSubmit"];
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.firstName = self.firstNameTextField.text;
    currentUser.lastName = self.lastNameTextField.text;
    [SVProgressHUD show];

    [[OTAuthService new] updateUserInformationWithUser:currentUser success:^(OTUser *user) {
        // TODO phone is not in response so need to restore it manually
        user.phone = currentUser.phone;
        [NSUserDefaults standardUserDefaults].currentUser = user;
        [SVProgressHUD dismiss];

        if ([self.delegate respondsToSelector:@selector(userNameDidChange)]) {
            [self.delegate userNameDidChange];
        } else {
            [self.onboardingNavigation nextFromName];
        }
    } failure:^(NSError *error) {
        [OTLogger logEvent:@"NameSubmitError"];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        NSLog(@"ERR: something went wrong on onboarding user name: %@", error.description);
    }];
}

- (IBAction)textChanged:(id)sender {
    [OTLogger logEvent:@"NameType"];
}

/********************************************************************************/
#pragma mark - Private

- (BOOL)formIsValid {
    return (self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length > 0);
}


@end
