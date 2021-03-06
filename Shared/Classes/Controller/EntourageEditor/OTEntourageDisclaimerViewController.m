//
//  OTEntourageDisclaimerViewController.m
//  entourage
//
//  Created by sergiu.buceac on 06/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEntourageDisclaimerViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTAPIConsts.h"

@interface OTEntourageDisclaimerViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *switchAccept;
@property (nonatomic, strong) UIBarButtonItem *rejectDisclaimerButton;

@property (nonatomic, weak) IBOutlet UILabel *firstTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *thirdsTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *firstDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *thirdsDescriptionLabel;

@end

@implementation OTEntourageDisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.rejectDisclaimerButton = [self setupCloseModal];
    [self.rejectDisclaimerButton setAction:@selector(doRejectDisclaimer)];
    
    [self setupContent];
}

- (void)setupContent {
    
    if (self.isForCreatingEvent) {
        self.navigationItem.title = OTLocalizedString(@"addActionDisclaimerTitle");
        self.firstTitleLabel.text = OTLocalizedString(@"addEventDisclaimerFirstTitle");
        self.secondTitleLabel.text = OTLocalizedString(@"addEventDisclaimerSecondTitle");
        self.thirdsTitleLabel.text = OTLocalizedString(@"addEventDisclaimerThirdTitle");
        
        self.firstDescriptionLabel.text = OTLocalizedString(@"addEventDisclaimerFirstDescription");
        self.secondDescriptionLabel.text = OTLocalizedString(@"addEventDisclaimerSecondDescription");
        self.thirdsDescriptionLabel.text = OTLocalizedString(@"addEventDisclaimerThirdDescription");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"Screen19_0EthicsPopupView"];
}

- (IBAction)showChart:(id)sender {
    [OTLogger logEvent:@"LinkToEthicsChartClick"];
    NSString *url = PUBLIC_ENTOURAGE_CREATION_CHART;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)disclaimerAccepted:(id)sender {
    [OTLogger logEvent:@"AcceptEthicsChartClick"];
    if (self.switchAccept.isOn) {
        self.rejectDisclaimerButton.enabled = NO;
        [self performSelector:@selector(acceptDisclaimer) withObject:nil afterDelay:0.5];
    }
}

- (void)doRejectDisclaimer {
    [OTLogger logEvent:@"CloseEthicsPopupClick"];
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasRejected)])
        [self.disclaimerDelegate disclaimerWasRejected];
}

- (void)acceptDisclaimer {
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasAccepted)])
        [self.disclaimerDelegate disclaimerWasAccepted];
}

@end
