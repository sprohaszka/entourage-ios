//
//  OTLoginViewController.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <IQKeyboardManager/IQKeyboardManager.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "OTLoginViewController.h"
#import "OTLostCodeViewController.h"
#import "OTConsts.h"
#import "OTUserEmailViewController.h"
#import "OTAuthService.h"
#import "UITextField+indentation.h"
#import "UIStoryboard+entourage.h"
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UINavigationController+entourage.h"
#import "UIView+entourage.h"
#import "UIScrollView+entourage.h"
#import "UITextField+indentation.h"
#import "OTUser.h"
#import "UIColor+entourage.h"
#import "OTOnboardingNavigationBehavior.h"
#import "OTPushNotificationsService.h"
#import "OTAskMoreViewController.h"
#import "NSError+OTErrorData.h"
#import "OTLocationManager.h"
#import "OTUserNameViewController.h"
#import "entourage-Swift.h"
#import "OTCountryCodePickerViewDataSource.h"
#import "UIColor+entourage.h"
#import <Mixpanel/Mixpanel.h>
#import "OTDeepLinkService.h"
#import "OTAppState.h"

NSString *const kTutorialDone = @"has_done_tutorial";

@interface OTLoginViewController ()
<
    LostCodeDelegate,
    OTUserNameViewControllerDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet OnBoardingNumberTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet OnBoardingCodeTextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;
@property (nonatomic, weak) IBOutlet OnBoardingButton *continueButton;
@property (nonatomic, weak) IBOutlet UIView *pickerView;
@property (nonatomic, weak) IBOutlet UIPickerView *countryCodePicker;
@property (nonatomic, weak) IBOutlet JVFloatLabeledTextField *countryCodeTxtField;

@property (nonatomic, assign) BOOL phoneIsValid;
@property (nonatomic, weak) NSString *codeCountry;
@property (nonatomic, weak) OTCountryCodePickerViewDataSource *pickerDataSource;

@end

@implementation OTLoginViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    self.phoneIsValid = NO;
    self.phoneTextField.floatingLabelTextColor = [UIColor whiteColor];
    
    if (@available(iOS 10.0, *)) {
        self.phoneTextField.textContentType = UITextContentTypeTelephoneNumber;
    }
    
    self.phoneTextField.inputValidationChanged = ^(BOOL isValid) {
        self.phoneIsValid = YES;
        [self validateForm];
    };
    self.passwordTextField.inputValidationChanged = ^(BOOL isValid) {
        [self validateForm];
    };
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
    
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    [self.continueButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    self.countryCodePicker.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;

    [self.passwordTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.passwordTextField indentRight];
    [self.countryCodeTxtField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.countryCodeTxtField.keepBaseline = YES;
    self.countryCodeTxtField.floatingLabelTextColor = [UIColor clearColor];
    self.countryCodeTxtField.floatingLabelActiveTextColor = [UIColor clearColor];
    self.pickerDataSource = [OTCountryCodePickerViewDataSource sharedInstance];
    self.codeCountry = @"+33";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTLogger logEvent:@"Screen02OnboardingLoginView"];
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.phoneTextField indentRight];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    // restore pre-login value of currentUser if the user is backing from the required onboarding
    if (self.onboardingNavigation.hasPreLoginUser) {
        [NSUserDefaults standardUserDefaults].currentUser = self.onboardingNavigation.preLoginUser;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.countryCodeTxtField.inputView = self.pickerView;
    [self validateForm];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
}

-(IBAction)resendCode:(id)sender {
    [OTLogger logEvent:@"SMSCodeRequest"];
    [OTLogger logEvent:@"Screen03_1OnboardingCodeResendView"];
    [self performSegueWithIdentifier:@"ResendCodeSegue" sender:nil];
}

#pragma mark - Public Methods

- (BOOL)validateForm {
    BOOL status = self.phoneIsValid && (self.passwordTextField.text.length == 6);
    self.continueButton.enabled = status;
    return status;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)launchAuthentication {
    [SVProgressHUD show];
    
    NSString *phoneNumber = [self.phoneTextField.text stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
    if(![phoneNumber hasPrefix:@"+"]) {
        if([phoneNumber hasPrefix:@"0"])
            phoneNumber = [phoneNumber substringFromIndex:1];
        phoneNumber = [self.codeCountry stringByAppendingString:phoneNumber];
    }

    [[OTAuthService new] authWithPhone:phoneNumber
                              password:self.passwordTextField.text
                               success: ^(OTUser *user, BOOL firstLogin) {
        
        [SVProgressHUD dismiss];
        
        // as the logged-out user
        [OTLogger logEvent:@"Login_Success"
            withParameters:@{@"first_login": [NSNumber numberWithBool:firstLogin]}];
        
        NSLog(@"User : %@ authenticated successfully", user.email);
        
        [OTLogger setupMixpanelWithUser:user];
        user.phone = phoneNumber;
        
        if ([OTAppConfiguration supportsTourFunctionality]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
        }
        
        // backup pre-login value of currentUser in case the user backs from the required onboarding
        self.onboardingNavigation.preLoginUser = [NSUserDefaults standardUserDefaults].currentUser;
        
        [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
        [[NSUserDefaults standardUserDefaults] setFirstLoginState:!firstLogin];
        [self.view endEditing:YES];
        [OTAppState continueFromLoginVC];
        
        if (self.fromLink) {
            [[OTDeepLinkService new] handleDeepLink:self.fromLink];
            self.fromLink = nil;
        }
        
    } failure: ^(NSError *error) {
        [SVProgressHUD dismiss];
        [OTLogger logEvent:@"TelephoneSubmitFail"];
        NSString *alertTitle = OTLocalizedString(@"error");
        NSString *alertText = OTLocalizedString(@"connection_error");
        NSString *buttonTitle = OTLocalizedString(@"ok");
        NSString *errorCode = [error readErrorCode];
        if ([errorCode isEqualToString:UNAUTHORIZED]) {
            alertTitle = OTLocalizedString(@"tryAgain");
            alertText = OTLocalizedString(@"invalidPhoneNumberOrCode");
            buttonTitle = OTLocalizedString(@"tryAgain_short");
            [OTLogger logEvent:@"Login_Error"];
            [OTLogger logEvent:@"TelephoneSubmitError"];
        }
        else if([errorCode isEqualToString:INVALID_PHONE_FORMAT]) {
            alertTitle = OTLocalizedString(@"tryAgain");
            alertText = OTLocalizedString(@"invalidPhoneNumberFormat");
            buttonTitle = OTLocalizedString(@"tryAgain_short");
            [OTLogger logEvent:@"Login_Error"];
            [OTLogger logEvent:@"TelephoneSubmitError"];
        }
        else if(error.code == NSURLErrorNotConnectedToInternet) {
            alertTitle = OTLocalizedString(@"tryAgain");
            buttonTitle = OTLocalizedString(@"tryAgain_short");
            alertText = error.localizedDescription;
            [OTLogger logEvent:@"Login_Error"];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertText preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction: defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ResendCodeSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTLostCodeViewController *controller = (OTLostCodeViewController *)navController.viewControllers.firstObject;
        controller.codeDelegate = self;
        controller.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
        long code = [self.countryCodePicker selectedRowInComponent:0];
        controller.countryCodeTextField.text = [self.pickerDataSource getCountryShortNameForRow:code];
        controller.codeCountry = [self.pickerDataSource getCountryCodeForRow:code];
        controller.rowCode = code;
        controller.phoneTextField.text = self.phoneTextField.text;
    }
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)validateButtonDidTap {
    [OTLogger logEvent:@"TelephoneSubmit"];
    [self launchAuthentication];
}

/********************************************************************************/
#pragma mark - LostCodeDelegate

- (void)loginWithNewCode:(NSString *)code {
    [self dismissViewControllerAnimated:YES completion:^() {
        self.passwordTextField.text = code;
        [self validateForm];
        [self validateButtonDidTap];
    }];
}

- (void)loginWithCountryCode:(long)code andPhoneNumber:(NSString *)phone {
    [self dismissViewControllerAnimated:YES completion:^() {
        self.countryCodeTxtField.text = [self.pickerDataSource getCountryShortNameForRow:code];
        self.codeCountry = [self.pickerDataSource getCountryCodeForRow:code];
        self.phoneTextField.text = phone;
        self.phoneIsValid = YES;
        [self validateForm];
    }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint andMarker:self.phoneTextField];
}

/********************************************************************************/
#pragma mark - OTUserNameViewController

- (void)userNameDidChange {
    [OTAppState navigateToAuthenticatedLandingScreen];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerDataSource count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerDataSource getTitleForRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.countryCodeTxtField.text = [self.pickerDataSource getCountryShortNameForRow:row];
    self.codeCountry = [self.pickerDataSource getCountryCodeForRow:row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.pickerDataSource getTitleForRow:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title
                                    attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

@end
