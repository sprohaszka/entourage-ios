//
//  OTMyEntouragesViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesViewController.h"
#import "OTCollectionSourceBehavior.h"
#import "OTInvitationsCollectionSource.h"
#import "OTToggleVisibleBehavior.h"
#import "OTMyEntouragesDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTInvitationsService.h"
#import "SVProgressHUD.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTMyEntouragesOptionsBehavior.h"
#import "OTFeedItemDetailsBehavior.h"
#import "OTManageInvitationBehavior.h"
#import "OTUserProfileBehavior.h"

@interface OTMyEntouragesViewController ()

@property (nonatomic, strong) IBOutlet OTCollectionSourceBehavior *invitationsDataSource;
@property (nonatomic, strong) IBOutlet OTInvitationsCollectionSource *invitationsCollectionDataSource;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior *toggleCollectionView;
@property (nonatomic, strong) IBOutlet OTMyEntouragesDataSource *entouragesDataSource;
@property (nonatomic, strong) IBOutlet OTTableDataSourceBehavior *entouragesTableDataSource;
@property (nonatomic, strong) IBOutlet OTMyEntouragesOptionsBehavior *optionsBehavior;
@property (nonatomic, strong) IBOutlet OTFeedItemDetailsBehavior *feedItemDetailsBehavior;
@property (nonatomic, strong) IBOutlet OTManageInvitationBehavior* manageInvitation;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;

@end

@implementation OTMyEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.invitationsCollectionDataSource initialize];
    [self.entouragesTableDataSource initialize];
    [self.toggleCollectionView initialize];
    [self.toggleCollectionView toggle:NO animated:NO];
    [self.optionsBehavior configureWith:self.optionsDelegate];
    self.entouragesDataSource.tableView.rowHeight = UITableViewAutomaticDimension;
    self.entouragesDataSource.tableView.estimatedRowHeight = 200;
    
    self.title = OTLocalizedString(@"myEntouragesTitle").uppercaseString;
    [self loadInvitations];
    [self.entouragesDataSource loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.entouragesDataSource.tableView reloadRowsAtIndexPaths:[self.entouragesDataSource.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.isMovingFromParentViewController)
        [OTLogger logEvent:@"BackToFeedClick"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.optionsBehavior prepareSegueForOptions:segue]) {
        [OTLogger logEvent:@"PlusOnMessagesPageClick"];
        return;
    }
    if([self.feedItemDetailsBehavior prepareSegueForDetails:segue])
        return;
    if([self.manageInvitation prepareSegueForManage:segue])
        return;
    if ([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
    if([segue.identifier isEqualToString:@"FiltersSegue"]) {
        [OTLogger logEvent:@"MessagesFilterClick"];
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTFeedItemFiltersViewController *filtersController = (OTFeedItemFiltersViewController *)controller.topViewController;
        filtersController.filterDelegate = self.entouragesDataSource;
    }
}

- (IBAction)changedEntourages:(id)sender {
    [self.entouragesDataSource loadData];
}

#pragma mark - private methods

- (void)loadInvitations {
    [[OTInvitationsService new] getInvitationsWithStatus:INVITATION_PENDING success:^(NSArray *items) {
        [self.toggleCollectionView toggle:[items count] > 0 animated:YES];
        [self.invitationsDataSource updateItems:items];
        [self.invitationsCollectionDataSource refresh];
    } failure:nil];
}

@end
