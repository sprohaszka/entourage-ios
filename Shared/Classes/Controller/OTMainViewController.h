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
#import "OTEntourageEditorViewController.h"

@class MKMapView;
@class KPClusteringController;
@class OTEncounterAnnotation;
@class OTFeedItem;

@interface OTMainViewController : UIViewController <OTConfirmationViewControllerDelegate, EntourageEditorDelegate, UIGestureRecognizerDelegate>

// tour properties
@property (nonatomic, strong) OTFeedItem *selectedFeedItem;
@property (nonatomic, strong) NSString *webview;
@property (nonatomic) BOOL isSolidarityGuide;

- (void)zoomToCurrentLocation:(id)sender;
- (void)zoomMapToLocation:(CLLocation*)location;
- (void)willChangePosition;
- (void)didChangePosition;
- (void)reloadPois;
- (void)reloadFeeds;

- (void)editEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view;
- (void)displayPoiDetails:(MKAnnotationView *)view;

- (void)switchToGuide;
- (IBAction)showFilters;

@end
