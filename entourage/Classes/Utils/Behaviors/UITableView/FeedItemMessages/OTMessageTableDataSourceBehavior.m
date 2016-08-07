//
//  OTMessageTableDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageTableDataSourceBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemTimelinePoint.h"
#import "OTFeedItemMessage.h"
#import "OTFeedItemJoiner.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTFeedItem.h"

#define MESSAGE_FONT_REGULAR_DESCRIPTION @"SFUIText-Regular"
#define MESSAGE_FONT_SIZE 17
#define JOIN_REQUESTED_CELL_HEIGHT 295
#define JOIN_ACCEPTED_CELL_HEIGHT 290
#define JOIN_REFUSED_CELL_HEIGHT 290
// Sergiu: sorry for these next terrible hardcoded constants
#define MESSAGE_CELL_SENT_HORIZONTAL_MARGINS 111.0f
#define MESSAGE_CELL_SENT_VERTICAL_MARGINS 43.0f
#define MESSAGE_CELL_RECEIVED_HORIZONTAL_MARGINS 158.0f
#define MESSAGE_CELL_RECEIVED_VERTICAL_MARGINS 54.0f

@interface OTMessageTableDataSourceBehavior () <UITableViewDelegate>

@property (nonatomic, strong) UIFont *messageFont;
@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTMessageTableDataSourceBehavior

- (void)initialize {
    [super initialize];
    self.dataSource.tableView.delegate = self;
    self.messageFont = [UIFont fontWithName:MESSAGE_FONT_REGULAR_DESCRIPTION size:MESSAGE_FONT_SIZE];
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTFeedItemTimelinePoint *item = (OTFeedItemTimelinePoint *)[self getItemAtIndexPath:indexPath];
    if([item class] == [OTFeedItemMessage class])
        return [self heightForMessageCell:(OTFeedItemMessage *)item];
    else if([item class] == [OTFeedItemJoiner class])
        return [self heightForJoinerCell:(OTFeedItemJoiner *)item];
    return 60;
}

#pragma mark - private methods

- (CGFloat)heightForMessageCell:(OTFeedItemMessage *)message {
    CGFloat margins = [self.currentUser.sid isEqual:message.uID] ? MESSAGE_CELL_SENT_HORIZONTAL_MARGINS : MESSAGE_CELL_RECEIVED_HORIZONTAL_MARGINS;
    CGFloat maxWidth = self.dataSource.tableView.contentSize.width - margins;
    CGRect computed = [message.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.messageFont} context:nil];

    CGFloat height = computed.size.height;
    CGFloat verticalMargins = [self.currentUser.sid isEqual:message.uID] ? MESSAGE_CELL_SENT_VERTICAL_MARGINS : MESSAGE_CELL_RECEIVED_VERTICAL_MARGINS;
    height += verticalMargins;
    return height;
}

- (CGFloat)heightForJoinerCell:(OTFeedItemJoiner *)joiner {
    //if([joiner.status isEqualToString:JOIN_PENDING])
        return 290;
    return 60;
}

@end
