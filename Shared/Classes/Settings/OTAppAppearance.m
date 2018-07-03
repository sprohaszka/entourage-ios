//
//  OTAppAppearance.m
//  entourage
//
//  Created by Smart Care on 07/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAppAppearance.h"
#import "OTAppConfiguration.h"
#import "OTEntourage.h"
#import "OTAPIConsts.h"
#import "OTFeedItemFactory.h"
#import "OTFeedItem.h"
#import "UIImage+processing.h"
#import <AFNetworking/UIButton+AFNetworking.h>
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTUser.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"
#import "UIColor+Expanded.h"

#import "entourage-Swift.h"

@implementation OTAppAppearance

+ (UIImage*)applicationLogo
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIImage imageNamed:@"pfp-logo"];
    }
    
    return [UIImage imageNamed:@"entourageLogo"];
}

+ (NSString*)aboutUrlString
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return PFP_ABOUT_CGU_URL;
    }
    return ABOUT_CGU_URL;
}

+ (NSString *)welcomeDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_welcomeText");
    }
    
    return OTLocalizedString(@"welcomeText");
}

+ (UIImage*)welcomeLogo
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return nil;
    }
    
    return [UIImage imageNamed:@"logoWhiteEntourage"];
}

+ (NSString *)userProfileNameDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userNameDescriptionText");
    }
    
    return OTLocalizedString(@"userNameDescriptionText");
}

+ (NSString *)userProfileEmailDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userEmailDescriptionText");
    }
    
    return OTLocalizedString(@"userEmailDescriptionText");
}

+ (NSString *)notificationsRightsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userNotificationsDescriptionText");
    }
    
    return OTLocalizedString(@"userNotificationsDescriptionText");
}

+ (NSString *)geolocalisationRightsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_geolocalisationDescriptionText");
    }
    
    return OTLocalizedString(@"geolocalisationDescriptionText");
}

+ (NSString *)notificationsNeedDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_notificationNeedDescription");
    }
    
    return OTLocalizedString(@"notificationNeedDescription");
}

+ (NSString *)noFeedsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_more_feeds");
    }
    
    return OTLocalizedString(@"no_more_feeds");
}

+ (NSString *)noMapFeedsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_more_map_feeds");
    }
    
    return OTLocalizedString(@"no_more_map_feeds");
}

+ (NSString *)extendSearchParameterDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_feeds_increase_radius");
    }
    
    return OTLocalizedString(@"no_feeds_increase_radius");
}

+ (NSString *)extendMapSearchParameterDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_map_feeds_increase_radius");
    }
    
    return OTLocalizedString(@"no_map_feeds_increase_radius");
}

+ (NSString*)userPhoneNumberNotFoundMessage {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_lost_code_phone_does_not_exist");
    }
    
    return OTLocalizedString(@"lost_code_phone_does_not_exist");
}

+ (NSString*)userActionsTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_entourages");
    }
    
    return OTLocalizedString(@"entourages");
}

+ (NSString*)editUserDescriptionTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_edit_user_description");
    }
    
    return OTLocalizedString(@"edit_user_description");
}

+ (NSString*)numberOfUserActionsTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_numberOfUserActions");
    }
    
    return OTLocalizedString(@"numberOfUserActions");
}

+ (NSString*)userPrivateCirclesSectionTitle:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([user.roles containsObject:kVisitorUserTag] || [user.roles containsObject:kCoordinatorUserTag]) {
            return OTLocalizedString(@"pfp_visitorPrivateCirclesSectionTitle");
        } else {
            return OTLocalizedString(@"pfp_visitedPrivateCirclesSectionTitle");
        }
    }
    
    return nil;
}

+ (NSString*)userNeighborhoodsSectionTitle:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_neighborhoodsSectionTitle");
    }
    
    return OTLocalizedString(@"neighborhoodsSectionTitle");
}

+ (NSString*)numberOfUserActionsValueTitle:(OTUser *)user {
    /*
     https://jira.mytkw.com/browse/EMA-1949
     During the pilot phase with PFP (first 3 months) we will not try to import the number of Sorties (outings) all the users have been to since they started being members of PFP (that data is more or less available on the current website but we won't import it now). So everyone's score in "Nombre de sorties" will be 0.
    Then when we add the feature to create and join "Sorties" in the Feed this will start to be incremented. So for now in the 5.1 version you can just hard-code 0, to be replaced by the API endpoint later.
     */
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return @"0";
    }
    
    if ([user isPro]) {
        return [NSString stringWithFormat:@"%d", user.tourCount.intValue];
    }
    else {
        return [NSString stringWithFormat:@"%d", user.entourageCount.intValue];
    }
}

+ (NSString *)reportActionSubject {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_mail_signal_subject");
    }
    
    return OTLocalizedString(@"mail_signal_subject");
}

+ (NSString *)reportActionToRecepient {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return CONTACT_PFP_TO;
    }
    
    return SIGNAL_ENTOURAGE_TO;
}

+ (UIColor*)leftTagColor:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return (user.leftTag) ? [UIColor pfpPurpleColor] : [UIColor clearColor];
    }
    
    return [UIColor clearColor];
}

+ (UIColor*)rightTagColor:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if (user.rightTag) {
            return ([user.roles containsObject:kCoordinatorUserTag]) ?
            [UIColor pfpGreenColor] : [UIColor pfpPurpleColor];
        }
    }
    
    return [UIColor clearColor];
}

+ (NSAttributedString*)formattedDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size {
    
    UIColor *typeColor = [ApplicationTheme shared].backgroundThemeColor;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([item isNeighborhood] || [item isPrivateCircle]) {
            return [[NSAttributedString alloc] initWithString:@"Voisinage"];
        } else if  ([item isConversation]) {
            return [[NSAttributedString alloc] initWithString:@""];
        }
    }
    
    if ([item.entourage_type isEqualToString:@"contribution"]) {
        typeColor = [UIColor brightBlue];
    } else if ([item.entourage_type isEqualToString:@"ask_for_help"]) {
        typeColor = [UIColor appOrangeColor];
    }
    
    NSString *itemType = OTLocalizedString(item.entourage_type);
    NSDictionary *atttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size],
                                   NSForegroundColorAttributeName:typeColor};
    
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString: itemType attributes:atttributtes];
    NSAttributedString *byAttrString = [[NSAttributedString alloc] initWithString: OTLocalizedString(@"by") attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size]}];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:item.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_BOLD_DESCRIPTION size:size]}];
    
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:byAttrString];
    [typeByNameAttrString appendAttributedString:nameAttrString];
    
    return typeByNameAttrString;
}

+ (NSString*)iconNameForEntourageItem:(OTEntourage*)item {
    NSString *icon = [NSString stringWithFormat:@"%@_%@", item.entourage_type, item.category];
    
    if ([item isPrivateCircle]) {
        icon = @"private-circle";
    } else if ([item isNeighborhood]){
        icon = @"neighborhood";
    }
    
    return icon;
}

+ (UIColor*)announcementFeedContainerColor {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIColor pfpNeighborhoodColor];
    }
    
    return [ApplicationTheme shared].backgroundThemeColor;
}

+ (UIColor*)iconColorForFeedItem:(OTFeedItem *)feedItem {
    UIColor *color = [ApplicationTheme shared].backgroundThemeColor;
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isNeighborhood] || [feedItem isPrivateCircle]) {
            color = [UIColor pfpNeighborhoodColor];
        } else if ([feedItem isPrivateCircle]) {
            color = [UIColor pfpPrivateCircleColor];
        }
        return color;
    }
    
    BOOL isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    color = [UIColor appGreyishColor];
    if (isActive) {
        OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
        if (feedItem.author.uID.intValue == currentUser.sid.intValue) {
            color = [UIColor appOrangeColor];
        } else {
            if ([JOIN_ACCEPTED isEqualToString:feedItem.joinStatus] ||
                [JOIN_PENDING isEqualToString:feedItem.joinStatus]) {
                color = [UIColor appOrangeColor];
            } else if ([JOIN_REJECTED isEqualToString:feedItem.joinStatus]) {
                color = [UIColor appTomatoColor];
            } else {
                color = [UIColor appGreyishColor];
            }
        }
    }
    
    return color;
}

+ (UIView*)navigationTitleViewForFeedItem:(OTFeedItem*)feedItem {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    id iconName = [[[OTFeedItemFactory createFor:feedItem] getUI] categoryIconSource];
    id titleString = [[[OTFeedItemFactory createFor:feedItem] getUI] navigationTitle];
    
    UIButton *iconView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    iconView.backgroundColor = UIColor.whiteColor;
    iconView.layer.cornerRadius = 18;
    iconView.userInteractionEnabled = NO;
    iconView.clipsToBounds = YES;
    
    UIImage *placeholder = [UIImage imageNamed:@"user"];
    
    if ([feedItem isConversation]) {
        NSString *urlPath = feedItem.author.avatarUrl;
        if (urlPath != nil && [urlPath class] != [NSNull class] && urlPath.length > 0) {
            NSURL *url = [NSURL URLWithString:urlPath];
            [iconView setImageForState:UIControlStateNormal withURL:url placeholderImage:placeholder];
        } else {
            [iconView setImage:placeholder forState:UIControlStateNormal];
        }
    } else {
        [iconView setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 130, 40)];
    title.text = titleString;
    title.textColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [titleView addSubview:iconView];
    [titleView addSubview:title];
    
    return titleView;
}

+ (NSString *)joinEntourageLabelTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_join_group_title");
    }
    
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        return OTLocalizedString(@"join_entourage_lbl");
    }
    else {
        return OTLocalizedString(@"join_tour_lbl");
    }
}

+ (NSString *)joinEntourageButtonTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_join_group_button");
    }
    
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        return OTLocalizedString(@"join_entourage_btn");
    }
    else {
        return OTLocalizedString(@"join_tour_btn");
    }
}

+ (UIColor*)colorForNoDataPlacholderImage {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [[UIColor pfpBlueColor] colorWithAlphaComponent:0.1];
    }
    
    return [UIColor colorWithHexString:@"e9f1f4"];
}

+ (UIColor*)colorForNoDataPlacholderText {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIColor colorWithHexString:@"025e7f"];
    }
    
    return [UIColor colorWithHexString:@"4a4a4a"];
}

@end
