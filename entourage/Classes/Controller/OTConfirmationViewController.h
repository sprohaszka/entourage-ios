//
//  OTConfirmationViewController.h
//  
//
//  Created by OCTO-NTE on 16/11/2015.
//
//

#import <UIKit/UIKit.h>

@class OTTour;

@protocol OTConfirmationViewControllerDelegate <NSObject>

- (void)tourSent;

@end

@interface OTConfirmationViewController : UIViewController

@property(nonatomic, weak) id<OTConfirmationViewControllerDelegate> delegate;

- (void)configureWithTour:(OTTour *)currentTour
       andEncountersCount:(NSNumber *)encountersCount
              andDistance:(float)distance
              andDuration:(NSTimeInterval)duration;

@end
