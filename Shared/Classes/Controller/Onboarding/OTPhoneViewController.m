//
//  OTPhoneViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

#import "OTPhoneViewController.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "UIScrollView+entourage.h"
#import "UIColor+entourage.h"
#import "NSError+OTErrorData.h"
#import "OTConsts.h"
#import "OTDeepLinkService.h"
#import "entourage-Swift.h"
#import "OTCountryCodePickerViewDataSource.h"

@interface OTPhoneViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet OnBoardingNumberTextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, weak) IBOutlet OnBoardingButton *validateButton;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *countryCodeTxtField;
@property (weak, nonatomic) IBOutlet UIPickerView *countryCodePicker;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, strong) NSArray *array;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) NSString *codeCountry;
@property (weak, nonatomic) OTCountryCodePickerViewDataSource *pickerDataSource;

@end

@implementation OTPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ vous envoie un SMS afin de vérifier votre numéro de portable.", appName];
    
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    
    if (@available(iOS 10.0, *)) {
        self.phoneTextField.textContentType = UITextContentTypeTelephoneNumber;
    }
    
    self.phoneTextField.inputValidationChanged = ^(BOOL isValid) {
        self.validateButton.enabled = isValid;
    };
    self.countryCodePicker.dataSource = self;
    self.countryCodePicker.delegate = self;
    self.countryCodeTxtField.delegate = self;
    self.phoneTextField.delegate = self;
    [self.countryCodeTxtField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.countryCodeTxtField.keepBaseline = YES;
    self.countryCodeTxtField.floatingLabelTextColor = [UIColor clearColor];
    self.countryCodeTxtField.floatingLabelActiveTextColor = [UIColor clearColor];
    self.pickerDataSource = [OTCountryCodePickerViewDataSource sharedInstance];
    self.codeCountry = @"+33";
    
    self.countryCodePicker.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    [self.validateButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"Screen30_2InputPhoneView"];
    self.countryCodeTxtField.inputView = self.pickerView;
   
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"TelephoneSubmit"];
    OTUser *temporaryUser = [OTUser new];
    NSString *phoneNumber = [self.phoneTextField.text stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
    if(![phoneNumber hasPrefix:@"+"]) {
        if([phoneNumber hasPrefix:@"0"])
            phoneNumber = [phoneNumber substringFromIndex:1];
        phoneNumber = [self.codeCountry stringByAppendingString:phoneNumber];
    }
    temporaryUser.phone = phoneNumber;
    [SVProgressHUD show];
    [[OTOnboardingService new] setupNewUserWithPhone:phoneNumber
        success:^(OTUser *onboardUser) {
            [SVProgressHUD dismiss];
            onboardUser.phone = phoneNumber;
            [NSUserDefaults standardUserDefaults].temporaryUser = onboardUser;
            [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSString *errorMessage = error.localizedDescription;
            NSString *errorCode = [error readErrorCode];
            BOOL showErrorHUD = YES;
            if ([errorCode isEqualToString:INVALID_PHONE_FORMAT]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:OTLocalizedString(@"invalidPhoneNumberFormat") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"close") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:defaultAction];
                UIAlertAction *openLoginAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"already_subscribed") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [OTAppState navigateToLoginScreen:nil sender:self];
                }];
                [alert addAction:openLoginAction];
                [self presentViewController:alert animated:YES completion:nil];
                showErrorHUD = NO;
            }
            else if([errorCode isEqualToString:PHONE_ALREADY_EXIST]) {
                [OTLogger logEvent:@"Screen30_2PhoneAlreadyExistsError"];
                [NSUserDefaults standardUserDefaults].temporaryUser = temporaryUser;
                [SVProgressHUD dismiss];
                [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
                errorMessage = OTLocalizedString(@"alreadyRegisteredShortMessage");
            }
            if (errorMessage) {
                [OTLogger logEvent:@"TelephoneSubmitFail"];
                if(showErrorHUD)
                    [SVProgressHUD showErrorWithStatus:errorMessage];
            } else {
                [NSUserDefaults standardUserDefaults].temporaryUser = temporaryUser;
                [SVProgressHUD showErrorWithStatus: OTLocalizedString(@"alreadyRegisteredMessage")];
                [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
            }
        }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification
                                         andHeightContraint:self.heightContraint];
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
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

@end
