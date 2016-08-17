//
//  OTMyEntouragesViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesViewController.h"
#import "OTCollectionSourceBehavior.h"
#import "OTCollectionViewDataSourceBehavior.h"
#import "OTToggleVisibleBehavior.h"
#import "OTMyEntouragesDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTInvitationsService.h"
#import "SVProgressHUD.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTMyEntouragesFiltersViewController.h"
#import "OTMyEntouragesOptionsBehavior.h"

@interface OTMyEntouragesViewController ()

@property (strong, nonatomic) IBOutlet OTCollectionSourceBehavior *invitationsDataSource;
@property (strong, nonatomic) IBOutlet OTCollectionViewDataSourceBehavior *invitationsCollectionDataSource;
@property (strong, nonatomic) IBOutlet OTToggleVisibleBehavior *toggleCollectionView;
@property (strong, nonatomic) IBOutlet OTMyEntouragesDataSource *entouragesDataSource;
@property (strong, nonatomic) IBOutlet OTTableDataSourceBehavior *entouragesTableDataSource;
@property (strong, nonatomic) IBOutlet OTMyEntouragesOptionsBehavior *optionsBehavior;

@end

@implementation OTMyEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.invitationsCollectionDataSource initialize];
    [self.entouragesTableDataSource initialize];
    [self.toggleCollectionView initialize];
    [self.toggleCollectionView toggle:NO animated:NO];
    [self.optionsBehavior configureWith:self.optionsDelegate];
    
    self.title = OTLocalizedString(@"myEntouragesTitle").uppercaseString;
    [self loadInvitations];
    [self.entouragesDataSource loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.optionsBehavior prepareSegueForOptions:segue])
        return;
    if([segue.identifier isEqualToString:@"FiltersSegue"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTMyEntouragesFiltersViewController *filtersController = (OTMyEntouragesFiltersViewController *)controller.topViewController;
        filtersController.filterDelegate = self.entouragesDataSource;
    }
}

- (IBAction)changedEntourages:(id)sender {
    [self.entouragesDataSource loadData];
}

#pragma mark - private methods

- (void)loadInvitations {
    [[OTInvitationsService new] entourageGetInvitationsWithSuccess:^(NSArray *items) {
        [self.toggleCollectionView toggle:[items count] > 0 animated:YES];
        [self.invitationsDataSource updateItems:items];
        [self.invitationsCollectionDataSource refresh];
    } failure:nil];
}

@end