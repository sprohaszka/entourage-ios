//
//  OTAskMoreViewController.m
//  entourage
//
//  Created by Nicolas Telera on 08/12/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "OTAskMoreViewController.h"
#import "OTConsts.h"
#import "OTAuthService.h"
#import "NSString+Validators.h"
#import "NSDictionary+Parsing.h"
#import "UIViewController+menu.h"
#import "entourage-Swift.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTAskMoreViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *subscribeButton;

@end

@implementation OTAskMoreViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"discoverEntourage");
    self.navigationController.navigationBarHidden = NO;
    self.subscribeButton.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    [self setupCloseModal];
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self.emailField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openFacebook:(id)sender {
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/622067231241188"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://facebook.com/EntourageReseauCivique"]];
    }
}

- (IBAction)openTwitter:(id)sender {
    NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=r_entour"];
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/r_entour"]];
    }
}

- (IBAction)subscribeToNewsletter:(id)sender {
    if (![self.emailField.text isEqualToString:@""] && [self.emailField.text isValidEmail]) {
        [SVProgressHUD show];
        [[OTAuthService new] subscribeToNewsletterWithEmail:self.emailField.text
                                                    success:^(BOOL active) {
                                                        NSLog(active ? @"Newsletter subscription success" : @"Newsletter subscription failure");
                                                        if (active) {
                                                            [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent") ];
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                           
                                                        }
                                                    } failure:^(NSError *error) {
                                                        [SVProgressHUD showErrorWithStatus: OTLocalizedString(@"requestNotSent")];
                                                        NSLog(@"%@", error);
                                                    }];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"requestImposible") message:OTLocalizedString(@"needValidEmail") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


@end
