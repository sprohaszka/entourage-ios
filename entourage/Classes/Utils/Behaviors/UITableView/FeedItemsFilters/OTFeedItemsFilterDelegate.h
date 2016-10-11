//
//  OTFeedItemsFilterDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFilters.h"

@protocol OTFeedItemsFilterDelegate <NSObject>

@property (nonatomic, strong, readonly) OTFeedItemFilters *currentFilter;

- (void)filterChanged:(OTFeedItemFilters *)filter;

@end
