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
#import "OTAppDelegate.h"
#import "OTUnreadMessagesService.h"
#import "OTConsts.h"
#import "OTFeedItemFactory.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"

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
@property (strong, nonatomic) IBOutlet UIButton *optionsButton;
@property (nonatomic) BOOL isUnread;
@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) UIView *rightLineView;
@end

@implementation OTMyEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.optionsButton.hidden = YES;
    [self.invitationsCollectionDataSource initialize];
    [self.entouragesTableDataSource initialize];
    [self.toggleCollectionView initialize];
    [self.toggleCollectionView toggle:NO animated:NO];
    [self.optionsBehavior configureWith:self.optionsDelegate];
    self.entouragesDataSource.tableView.rowHeight = UITableViewAutomaticDimension;
    self.entouragesDataSource.tableView.estimatedRowHeight = 200;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadge:)
                                                 name:kUpdateBadgeCountNotification
                                               object:nil];
    
    self.navigationItem.title = OTLocalizedString(@"myEntouragesTitle").uppercaseString;
    [self loadInvitations];
    [self.entouragesDataSource loadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [OTLogger logEvent:@"Screen17_2MyMessagesView"];
    [super viewDidAppear:animated];
    [self configureNavigationBar];
    [self.entouragesDataSource.tableView reloadRowsAtIndexPaths:[self.entouragesDataSource.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
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
    if([self.feedItemDetailsBehavior prepareSegueForDetails:segue]){
        [OTLogger logEvent:@"DiscussionMembersListView"];
        return;
    }
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

- (void)updateBadge: (NSNotification *) notification {
    NSNumber *unreadCount = (NSNumber *)[notification.object objectForKey:kNotificationUpdateBadgeCountKey];
    NSNumber *feedId = (NSNumber *)[notification.object objectForKey:kNotificationUpdateBadgeFeedIdKey];
    for(int i = 0; i<self.entouragesDataSource.items.count; i++){
        OTFeedItem *item = self.entouragesDataSource.items[i];
        if([item.uid isEqual:feedId]){
            item.unreadMessageCount = unreadCount;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [self.entouragesTableDataSource.dataSource.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)loadInvitations {
    [[OTInvitationsService new] getInvitationsWithStatus:INVITATION_PENDING success:^(NSArray *items) {
        [self.toggleCollectionView toggle:[items count] > 0 animated:YES];
        [self.invitationsDataSource updateItems:items];
        [self.invitationsCollectionDataSource refresh];
    } failure:nil];
}

- (void)configureNavigationBar {
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width / 2 , self.navigationController.navigationBar.frame.size.height)];
    [leftButton addTarget:self
                    action:@selector(showAllMessages)
          forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle: OTLocalizedString(@"all_messages_nav_title").uppercaseString forState: UIControlStateNormal];
    leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    leftButton.titleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:14];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    self.leftLineView = [[UIView alloc] initWithFrame:CGRectMake(-20, leftButton.frame.size.height - 3, leftButton.frame.size.width, 3)];
    self.leftLineView.backgroundColor = [UIColor whiteColor];
    [leftButton addSubview:self.leftLineView];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width / 2 , self.navigationController.navigationBar.frame.size.height)];
    [rightButton setTitle: OTLocalizedString(@"unread_messages_nav_title").uppercaseString forState: UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:14];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightButton addTarget:self
             action:@selector(showUnread)
   forControlEvents:UIControlEventTouchUpInside];
    
    self.rightLineView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, rightButton.frame.size.height - 3, rightButton.frame.size.width, 3)];
    self.rightLineView.backgroundColor = [UIColor whiteColor];
    [leftButton addSubview:self.rightLineView];
    self.rightLineView.hidden = YES;
    
    //[self createMenuButton];
    //[self setupChatsButtonWithTarget:self andSelector:@selector(showEntourages)];
    //[self setupLogoImageWithTarget:self andSelector:@selector(logoTapped)];
}

- (void)showAllMessages {
    self.leftLineView.hidden = NO;
    self.rightLineView.hidden = YES;
}

- (void)showUnread {
    self.leftLineView.hidden = YES;
    self.rightLineView.hidden = NO;
    self.isUnread = YES;
}

@end
