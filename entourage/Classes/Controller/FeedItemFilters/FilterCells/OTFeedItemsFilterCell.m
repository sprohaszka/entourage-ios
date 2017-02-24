//
//  OTFeedItemsFilterCell.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemsFilterCell.h"
#import "OTFeedItemFilter.h"
#import "OTDataSourceBehavior.h"

@implementation OTFeedItemsFilterCell

- (void)configureWith:(OTFeedItemFilter *)filter {
    self.lblTitle.text = filter.title;
    [self.swtActive setOn:filter.active animated:YES];
}

- (IBAction)changeActive:(id)sender {
    NSIndexPath *indexPath = [self.tableDataSource.dataSource.tableView indexPathForCell:self];
    OTFeedItemFilter *item = (OTFeedItemFilter *)[self.tableDataSource getItemAtIndexPath:indexPath];
    UISwitch *swtControl = (UISwitch *)sender;
    item.active = swtControl.isOn;
    NSString *message = @"";
    switch (item.key) {
        case FeedItemFilterKeyMedical:
            message = @"ShowOnlyMedicalToursClick";
            break;
        case FeedItemFilterKeySocial:
            message = @"ShowOnlySocialToursClick";
            break;
        case FeedItemFilterKeyDistributive:
            message = @"ShowOnlyDistributionToursClick";
            break;
        case FeedItemFilterKeyDemand:
            message = @"ShowOnlyAsksClick";
            break;
        case FeedItemFilterKeyContribution:
            message = @"ShowOnlyOffersClick";
            break;
        case FeedItemFilterKeyTour:
            message = @"ShowToursOnlyFilterKey";
            break;
        case FeedItemFilterKeyOnlyMyEntourages:
            message = @"ShowOnlyMineFilter";
            break;
        case FeedItemFilterKeyActive:
            message = @"ActiveMessagesFilter";
            break;
        case FeedItemFilterKeyInvitation:
            message = @"InvitationsFilter";
            break;
        case FeedItemFilterKeyOrganiser:
            message = @"OrganizerFilter";
            break;
        case FeedItemFilterKeyClosed:
            message = @"PastFilter";
            break;
        default:
            break;
    }
    [OTLogger logEvent:message];
}

@end
