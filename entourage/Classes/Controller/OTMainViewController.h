//
//  OTMapViewController.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMeetingCalloutViewController.h"
#import "OTCreateMeetingViewController.h"
#import "OTConfirmationViewController.h"

@class MKMapView;
@class KPClusteringController;
@class OTEncounterAnnotation;
@class OTFeedItem;

@interface OTMainViewController : UIViewController <OTMeetingCalloutViewControllerDelegate, OTCreateMeetingViewControllerDelegate, OTConfirmationViewControllerDelegate>

// tour properties
@property NSString *currentTourType;
@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, strong) OTFeedItem *selectedFeedItem;


- (void)zoomToCurrentLocation:(id)sender;
- (void)didChangePosition;
- (void)getData:(BOOL)moreFeeds;

- (void)displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view;
- (void)displayPoiDetails:(MKAnnotationView *)view;

@end
