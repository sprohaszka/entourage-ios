//
//  OTTourViewController.h
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"

@protocol OTTourTimelineDelegate <NSObject>

@required
- (void)promptToCloseTour;

@end

@interface OTFeedItemViewController : UIViewController

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTTourTimelineDelegate> delegate;

- (void)configureWithTour:(OTFeedItem *)feedItem;

@end
