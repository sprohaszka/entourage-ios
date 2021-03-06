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
#import "NSDate+OTFormatter.h"
#import "NSDate+ui.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Fitting.h"
#import "OTFeedItemMessage.h"
#import "OTHTTPRequestManager.h"
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
        NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS_NO_TOKEN, PFP_API_URL_TERMS_REDIRECT];
        NSString *urlString = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
        return urlString;
    }
    return ABOUT_CGU_URL;
}

+ (NSString*)policyUrlString
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS_NO_TOKEN, PFP_API_URL_PRIVACY_POLICY_REDIRECT];
        NSString *urlString = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
        return urlString;
    }
    
    return ABOUT_POLICY_URL;
}

+ (NSString *)welcomeTopDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_welcomeTopText");
    }
    
    return OTLocalizedString(@"welcomeTopText");
}

+ (UIImage*)welcomeLogo
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return nil;
    }
    
    return [UIImage imageNamed:@"logoWhiteEntourage"];
}

+ (UIImage*)welcomeImage
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return nil;
    }
    
    return [UIImage imageNamed:@"welcome"];
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

+ (NSString *)defineActionZoneTitleForUser:(OTUser*)user {
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        
        if (user && [user hasActionZoneDefined]) {
            return OTLocalizedString(@"pfp_modifyActionZoneTitle");
        }
            
        return OTLocalizedString(@"pfp_defineActionZoneTitle");
    }
    
    if (user && [user hasActionZoneDefined]) {
        return OTLocalizedString(@"modifyActionZoneTitle");
    }
    
    return OTLocalizedString(@"defineActionZoneTitle");
}

+ (NSString *)geolocalisationRightsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_geolocalisationDescriptionText");
    }
    
    return OTLocalizedString(@"geolocalisationDescriptionText");
}

+ (NSString *)defineActionZoneSampleAddress {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_defineActionZoneSampleAddress");
    }
    
    return OTLocalizedString(@"defineActionZoneSampleAddress");
}

+ (NSAttributedString *)defineActionZoneFormattedDescription {
    UIFont *regularFont = [UIFont fontWithName:@"SFUIText-Regular" size:15];
    UIFont *lightSmallFont = [UIFont fontWithName:@"SFUIText-Light" size:12];
    
    NSDictionary *regAtttributtes = @{NSFontAttributeName : regularFont,
                                   NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *lightAtttributtes = @{NSFontAttributeName : lightSmallFont,
                                              NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        NSString *subtitle1 = OTLocalizedString(@"pfp_defineZoneSubtitle1");
        NSString *subtitle2 = OTLocalizedString(@"pfp_defineZoneSubtitle2");
        
        NSMutableAttributedString *descAttString = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:regAtttributtes];
        [descAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle2 attributes:lightAtttributtes]];
        
        return descAttString;
    }
    
    NSString *subtitle1 = OTLocalizedString(@"defineZoneSubtitle1");
    NSString *subtitle2 = OTLocalizedString(@"defineZoneSubtitle2");
    NSMutableAttributedString *descAttString = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:regAtttributtes];
    [descAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle2 attributes:lightAtttributtes]];
    
    return descAttString;
}

+ (NSString *)notificationsNeedDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_notificationNeedDescription");
    }
    
    return OTLocalizedString(@"notificationNeedDescription");
}

+ (NSString *)noMoreFeedsDescription
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
        if ([user isCoordinator]) {
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

+ (NSString *)eventTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_event");
    }
    
    return OTLocalizedString(@"event");
}

+ (NSString *)eventsFilterTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_filter_events_title");
    }
    
    return OTLocalizedString(@"filter_events_title");
}

+ (NSString *)applicationTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return @"Voisin-Age";
    }
    
    return @"Entourage";
}

+ (NSString *)promoteEventActionSubject:(NSString*)eventName {
    NSString *eventType = [OTAppAppearance eventTitle];
    NSString *eventDetails = [NSString stringWithFormat:@"%@ %@", eventType, eventName];
    NSString *subject = [NSString stringWithFormat:OTLocalizedString(@"promote_event_subject_format"), eventDetails];
    return subject;
}

+ (NSString *)promoteEventActionEmailBody:(NSString*)eventName {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        NSString *body = [NSString stringWithFormat:OTLocalizedString(@"pfp_promote_event_mail_body_format"), eventName];
        return body;
    }
    
    NSString *body = [NSString stringWithFormat:OTLocalizedString(@"promote_event_mail_body_format"), eventName];
    return body;
}



+ (NSString *)reportActionToRecepient {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return CONTACT_PFP_TO;
    }
    
    return SIGNAL_ENTOURAGE_TO;
}

+ (UIColor*)tagColor:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if (user.roleTag) {
            return ([user.roles containsObject:kCoordinatorUserTag]) ?
            [UIColor pfpGreenColor] : [UIColor pfpPurpleColor];
        }
    } else {
        if (user.roleTag) {
            return [UIColor appOrangeColor];
        }
    }
    
    return [UIColor clearColor];
}

+ (NSString *)descriptionForMessageItem:(OTEntourage *)item hasToShowDate:(BOOL)isShowDate {

    if ([item isNeighborhood] ||
        [item isPrivateCircle]) {
        return @"Voisinage";
    }
    if ([item isConversation]) {
        return @"";
    }
    if ([item isOuting]) {
        return [self eventDateDescriptionForMessageItem:item hasToShowDate:isShowDate];
    }
    
    return [NSString stringWithFormat:OTLocalizedString(@"formater_by"), OTLocalizedString(item.entourage_type)];
}

+ (NSAttributedString*)formattedDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size  hasToShowDate:(BOOL)isShowDate {
    NSAttributedString *formattedDescription = [[NSAttributedString alloc] initWithString: [self descriptionForMessageItem:item hasToShowDate:isShowDate] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:size]}];
    
    if ([item isNeighborhood] ||
        [item isPrivateCircle] ||
        [item isConversation] ||
        [item isOuting]) {
        return formattedDescription;
    }

    NSAttributedString *formattedUserName = [[NSAttributedString alloc] initWithString:item.author.displayName attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:size]}];
    
    NSMutableAttributedString *formattedDescriptionWithUser = formattedDescription.mutableCopy;
    [formattedDescriptionWithUser appendAttributedString:formattedUserName];
    
    return formattedDescriptionWithUser;
}

+ (NSAttributedString*)formattedAuthorDescriptionForMessageItem:(OTEntourage*)item {
    
    UIColor *textColor = [UIColor colorWithHexString:@"4a4a4a"];
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        textColor = [OTAppAppearance iconColorForFeedItem:item];
    }

    NSString *organizerText = @"\nOrganisé";
    NSString *fontName = @"SFUIText-Medium";
    CGFloat fontSize = DEFAULT_DESCRIPTION_SIZE;
    
    NSDictionary *atttributtes = @{NSFontAttributeName :
                                       [UIFont fontWithName:fontName size:fontSize],
                                   NSForegroundColorAttributeName:textColor};
    NSMutableAttributedString *organizerAttributedText = [[NSMutableAttributedString alloc] initWithString:organizerText attributes:atttributtes];
    
    NSAttributedString *byAttrString = [[NSAttributedString alloc] initWithString: OTLocalizedString(@"by") attributes:@{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]}];
    
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:item.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]}];
    
    NSMutableAttributedString *orgByNameAttrString = organizerAttributedText.mutableCopy;
    [orgByNameAttrString appendAttributedString:byAttrString];
    [orgByNameAttrString appendAttributedString:nameAttrString];
    
    return orgByNameAttrString;
}

+ (NSString*)eventDateDescriptionForMessageItem:(OTEntourage*)item  hasToShowDate:(BOOL)isShowDate {
    
    NSString *eventName = OTLocalizedString(@"event").capitalizedString;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        eventName = OTLocalizedString(@"pfp_event").capitalizedString;
    }
    
    if (isShowDate && item.startsAt) {
        NSString *_message = @"";
        if ([[NSCalendar currentCalendar] isDate:item.startsAt inSameDayAsDate:item.endsAt]) {
           _message = [NSString stringWithFormat:@"%@ %@", eventName, [NSString stringWithFormat:OTLocalizedString(@"le_"),[item.startsAt asStringWithFormat:@"EEEE dd/MM"]]];
        }
        else {
            NSString *_dateStr = [NSString stringWithFormat:OTLocalizedString(@"du_au"), [item.startsAt asStringWithFormat:@"dd/MM"],[item.endsAt asStringWithFormat:@"dd/MM"]];
            _message = [NSString stringWithFormat:@"%@ %@", eventName,_dateStr ];
        }
        
        return _message;
    } else {
        return eventName;
    }
}

+ (NSAttributedString*)formattedEventDateDescriptionForMessageItem:(OTEntourage*)item
                                                              size:(CGFloat)size {
    
    UIColor *textColor = [UIColor colorWithHexString:@"4a4a4a"];
    UIColor *typeColor = textColor;
    NSString *eventName = OTLocalizedString(@"event").capitalizedString;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        typeColor = [UIColor pfpOutingCircleColor];
        eventName = OTLocalizedString(@"pfp_event").capitalizedString;
    }
    
    NSDictionary *atttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size],
                                   NSForegroundColorAttributeName:typeColor};
    NSMutableAttributedString *eventAttrDescString = [[NSMutableAttributedString alloc] initWithString:eventName attributes:atttributtes];
    
    NSString *dateString = [NSString stringWithFormat:@" le %@", [item.startsAt asStringWithFormat:@"EEEE dd/MM"]];
    NSDictionary *dateAtttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size], NSForegroundColorAttributeName:textColor};
    NSMutableAttributedString *dateAttrString = [[NSMutableAttributedString alloc] initWithString:dateString attributes:dateAtttributtes];
    
    if (item.startsAt) {
        [eventAttrDescString appendAttributedString:dateAttrString];
    }
    
    return eventAttrDescString;
}

+ (NSString*)iconNameForEntourageItem:(OTEntourage*)item isAnnotation:(BOOL) isAnnotation {
    NSString *icon = [NSString stringWithFormat:@"%@_%@", item.entourage_type, item.category];
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([item isPrivateCircle]) {
            icon = @"private-circle";
        } else if ([item isNeighborhood]) {
            icon = @"neighborhood";
        } else if ([item isOuting]) {
            icon = @"outing";
        }
        
        return icon;
    }
    
    if ([item isOuting]) {
        if (isAnnotation) {
            icon = @"ask_for_help_event_poi";
        }
        else {
            icon = @"ask_for_help_event";
        }
    }
    
    return icon;
}

+ (UIColor*)announcementFeedContainerColor {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIColor pfpNeighborhoodColor];
    }
    
    return [UIColor whiteColor];
}

+ (UIColor*)iconColorForFeedItem:(OTFeedItem *)feedItem {
    UIColor *color = [ApplicationTheme shared].backgroundThemeColor;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isNeighborhood]) {
            color = [UIColor pfpNeighborhoodColor];
        } else if ([feedItem isPrivateCircle]) {
            color = [UIColor pfpPrivateCircleColor];
        } else if ([feedItem isOuting]) {
            color = [UIColor pfpOutingCircleColor];
        }
        return color;
    }
    
    BOOL isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    color = [UIColor appOrangeColor];
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
                color = [UIColor appOrangeColor];
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
    
+ (UILabel*)navigationTitleLabelForFeedItem:(OTFeedItem*)feedItem {
    id titleString = [[[OTFeedItemFactory createFor:feedItem] getUI] navigationTitle];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    titleLabel.text = titleString;
    titleLabel.textColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    titleLabel.numberOfLines = 1;
    
    return titleLabel;
}
    
+ (UIBarButtonItem *)leftNavigationBarButtonItemForFeedItem:(OTFeedItem*)feedItem
{
    CGFloat iconSize = 36.0f;
    
    if ([feedItem isConversation]) {
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
        iconView.backgroundColor = UIColor.whiteColor;
        iconView.layer.cornerRadius = iconSize / 2;
        iconView.userInteractionEnabled = NO;
        iconView.clipsToBounds = YES;
        iconView.layer.masksToBounds = YES;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImage *placeholder = [[UIImage imageNamed:@"user"] resizeTo:iconView.frame.size];
        NSString *urlPath = feedItem.author.avatarUrl;
        if (urlPath != nil && [urlPath class] != [NSNull class] && urlPath.length > 0) {
            NSURL *url = [NSURL URLWithString:urlPath];
            [iconView sd_setImageWithURL:url placeholderImage:placeholder];
        } else {
            [iconView setImage:placeholder];
        }
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
        return barButtonItem;
    }
    
    id iconName = [[[OTFeedItemFactory createFor:feedItem] getUI] categoryIconSource];
    UIButton *iconView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
    iconView.backgroundColor = UIColor.whiteColor;
    iconView.layer.cornerRadius = iconSize / 2;
    iconView.userInteractionEnabled = NO;
    iconView.clipsToBounds = YES;
    UIImage *iconImage = [UIImage imageNamed:iconName];
    [iconView setImage:iconImage forState:UIControlStateNormal];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeEntourage) {
        if ([feedItem isOuting]) {
            iconView.tintColor = [ApplicationTheme shared].backgroundThemeColor;
            [iconView setImage:[[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
        }
    }

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];

    return barButtonItem;
}

+ (void)leftNavigationBarButtonItemForFeedItem:(OTFeedItem*)feedItem withBarItem:(void (^)(UIBarButtonItem*))completion
{
    CGFloat iconSize = 36.0f;
    
    if ([feedItem isConversation]) {
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
        iconView.backgroundColor = UIColor.whiteColor;
        iconView.layer.cornerRadius = iconSize / 2;
        iconView.userInteractionEnabled = NO;
        iconView.clipsToBounds = YES;
        iconView.layer.masksToBounds = YES;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImage *placeholder = [[UIImage imageNamed:@"user"] resizeTo:iconView.frame.size];
        NSString *urlPath = feedItem.author.avatarUrl;
        if (urlPath != nil && [urlPath class] != [NSNull class] && urlPath.length > 0) {
            NSURL *url = [NSURL URLWithString:urlPath];
            
            [iconView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                [iconView setImage:[image resizeTo:iconView.frame.size]];
                UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
                completion(barButtonItem);
            }];
        } else {
            [iconView setImage:placeholder];
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
            completion(barButtonItem);
        }
        return;
    }
    
    id iconName = [[[OTFeedItemFactory createFor:feedItem] getUI] categoryIconSource];
    UIButton *iconView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
    iconView.backgroundColor = UIColor.whiteColor;
    iconView.layer.cornerRadius = iconSize / 2;
    iconView.userInteractionEnabled = NO;
    iconView.clipsToBounds = YES;
    UIImage *iconImage = [UIImage imageNamed:iconName];
    [iconView setImage:iconImage forState:UIControlStateNormal];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeEntourage) {
        if ([feedItem isOuting]) {
            iconView.tintColor = [ApplicationTheme shared].backgroundThemeColor;
            [iconView setImage:[[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
        }
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
    
    completion(barButtonItem);
}

+ (NSString *)joinEntourageLabelTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"pfp_join_event_title");
        }
        return OTLocalizedString(@"pfp_join_group_title");
    }
    
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"join_event_lbl");
        }
        return OTLocalizedString(@"join_entourage_lbl");
    }
    else {
        return OTLocalizedString(@"join_tour_lbl");
    }
}

+ (NSString *)joinEntourageButtonTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"pfp_join_event_button");
        }
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
    
    return [UIColor colorWithHexString:@"efeff4"];
}

+ (UIColor*)colorForNoDataPlacholderText {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIColor colorWithHexString:@"025e7f"];
    }
    
    return [UIColor colorWithHexString:@"4a4a4a"];
}

+ (NSString*)sampleTitleForNewEvent {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_event_title_example");
    }
    
    return OTLocalizedString(@"event_title_example");
}

+ (NSString*)sampleDescriptionForNewEvent {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_event_desc_example");
    }
    
    return OTLocalizedString(@"event_desc_example");
}

+ (UIImage*)JoinFeedItemConfirmationLogo {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return nil;
    }
    return [UIImage imageNamed:@"logoWhiteEntourage"];
}

+ (NSAttributedString*)formattedEventCreatedMessageInfo:(OTFeedItemMessage*)messageItem {
    UIFont *regularFont = [UIFont fontWithName:@"SFUIText-Regular" size:15.0];
    UIFont *boldFont = [UIFont fontWithName:@"SFUIText-Bold" size:15.0];
    UIFont *semiboldFont = [UIFont fontWithName:@"SFUIText-Semibold" size:15.0];
    UIColor *regularColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    NSString *authorAndAction = [NSString stringWithFormat:@"%@ a créé une", messageItem.userName];
    NSString *event = [OTAppAppearance eventTitle];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE dd/MM à HH:mm"];
    NSString *date = [formatter stringFromDate:messageItem.startsAt];
    
    NSString *fullText = [NSString stringWithFormat:@"%@ %@:\n%@\n\n%@", authorAndAction, event, messageItem.title, date];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullText attributes:@{NSFontAttributeName: regularFont,                                                                               NSForegroundColorAttributeName: regularColor}];
    
    NSRange eventRange = NSMakeRange(authorAndAction.length + 1, event.length);
    NSRange titleRange = NSMakeRange(authorAndAction.length + event.length + 3, messageItem.title.length);
    [attributedString addAttributes:@{NSFontAttributeName: semiboldFont,                                                                               NSForegroundColorAttributeName: [UIColor pfpOutingCircleColor]} range:eventRange];
    [attributedString addAttributes:@{NSFontAttributeName: boldFont,                                                                               NSForegroundColorAttributeName: regularColor} range:titleRange];
    
    return attributedString;
}

+ (NSString*)requestToJoinTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"pfp_want_to_join_event");
        } else {
            return OTLocalizedString(@"pfp_want_to_join_entourage");
        }
    }
    
    if ([feedItem isKindOfClass:[OTTour class]]) {
        return OTLocalizedString(@"want_to_join_tour");
    }
    
    return OTLocalizedString(@"want_to_join_entourage");
}

+ (NSString*)quitFeedItemConformationTitle:(OTFeedItem *)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"pfp_quitted_event");
        } else {
            return OTLocalizedString(@"pfp_quitted_item");
        }
    }
    
    return OTLocalizedString(@"quitted_item");
}

+ (NSString*)closeFeedItemConformationTitle:(OTFeedItem *)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"pfp_closed_event");
        } else {
            return OTLocalizedString(@"pfp_quitted_item");
        }
    }
    
    return OTLocalizedString(@"closed_item");
}

+ (NSString*)joinFeedItemConformationDescription:(OTFeedItem *)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_join_entourage_greeting_lbl");
    }
    
    if ([feedItem isOuting]) {
        return OTLocalizedString(@"join_event_greeting_lbl");
    }
    else if ([feedItem isKindOfClass:[OTEntourage class]]) {
        return OTLocalizedString(@"join_entourage_greeting_lbl");
    }
    else {
        return OTLocalizedString(@"join_tour_greeting_lbl");
    }
}



+ (NSString*)addActionTitleHintMessage:(BOOL)isEvent {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_add_title_hint");
    }
    
    if (isEvent) {
        return OTLocalizedString(@"add_event_title_hint");
    }
    return OTLocalizedString(@"add_title_hint");
}

+ (NSString*)addActionDescriptionHintMessage:(BOOL)isEvent {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_add_description_hint");
    }
    
    if (isEvent) {
        return OTLocalizedString(@"add_event_description_hint");
    }
    
    return OTLocalizedString(@"add_description_hint");
}

+ (NSString*)includePastEventsFilterTitle {    
    return OTLocalizedString([OTAppAppearance includePastEventsFilterTitleKey]);
}

+ (NSString*)includePastEventsFilterTitleKey {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return @"pfp_filter_events_include_past_events_title";
    }
    
    return @"filter_events_include_past_events_title";
}

+ (NSString*)inviteSubtitleText:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"pfp_invite_event_subtitle");
        }
        
        return OTLocalizedString(@"pfp_invite_action_subtitle");
    }
    
    if ([feedItem isOuting]) {
        return OTLocalizedString(@"invite_event_subtitle");
    }
    
    return OTLocalizedString(@"invite_action_subtitle");
}

+ (NSString*)lostCodeSimpleDescription {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_lostCodeMessage1");
    }
    
    return OTLocalizedString(@"lostCodeMessage1");
}

+ (NSString*)lostCodeFullDescription {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_lostCodeMessage2");
    }
    
    return OTLocalizedString(@"lostCodeMessage2");
}

+ (NSString*)noMessagesDescription {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_messages_description");
    }
    
    return OTLocalizedString(@"no_messages_description");
}

+ (NSAttributedString*)closedFeedChatItemMessageFormattedText:(OTFeedItemMessage*)message {
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:message.userName attributes:@{NSForegroundColorAttributeName: [ApplicationTheme shared].backgroundThemeColor}];
    NSAttributedString *infoAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", message.text] attributes:@{NSForegroundColorAttributeName: [UIColor appGreyishColor]}];
    NSMutableAttributedString *nameInfoAttrString = nameAttrString.mutableCopy;
    [nameInfoAttrString appendAttributedString:infoAttrString];
    
    return nameInfoAttrString;
}

+ (NSString*)entourageConfidentialityDescription:(OTEntourage*)entourage
                                        isPublic:(BOOL)isPublic {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if (isPublic) {
            return OTLocalizedString(@"pfp_event_confidentiality_description_public");
        }
        return OTLocalizedString(@"pfp_event_confidentiality_description_private");
    } else {
        if (isPublic) {
            return OTLocalizedString(@"event_confidentiality_description_public");
        }
        
        return OTLocalizedString(@"event_confidentiality_description_private");
    }
}

@end
