//
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

// Controller
#import "OTMainViewController.h"
#import "UIViewController+menu.h"
#import "OTCreateMeetingViewController.h"
#import "OTToursTableViewController.h"
#import "OTCalloutViewController.h"
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTTourJoinRequestViewController.h"
#import "OTFeedItemViewController.h"
#import "OTPublicTourViewController.h"
#import "OTQuitTourViewController.h"
#import "OTGuideViewController.h"
#import "UIView+entourage.h"
#import "OTUserViewController.h"
#import "OTGuideDetailsViewController.h"
#import "OTTourCreatorViewController.h"
#import "OTEntourageCreatorViewController.h"
#import "OTEntouragesViewController.h"
#import "OTFiltersViewController.h"

#import "OTToursMapDelegate.h"
#import "OTGuideMapDelegate.h"

#import "KPAnnotation.h"
#import "KPClusteringController.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTEntourageAnnotation.h"

#import "OTConsts.h"

// View
#import "SVProgressHUD.h"
#import "OTToursTableView.h"
#import "OTToolbar.h"

// Model
#import "OTUser.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"
#import "OTPOI.h"
#import "OTEntourageFilter.h"

// Service
#import "OTTourService.h"
#import "OTAuthService.h"
#import "OTPOIService.h"
#import "OTFeedsService.h"

#import "UIButton+entourage.h"
#import "UIColor+entourage.h"
#import "UILabel+entourage.h"
#import "MKMapView+entourage.h"

// Framework
#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>
#import <QuartzCore/QuartzCore.h>
#import "TTTTimeIntervalFormatter.h"
#import "TTTLocationFormatter.h"
#import <AudioToolbox/AudioServices.h>

// User
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"

#define MAPVIEW_HEIGHT 160.f
#define MAPVIEW_REGION_SPAN_X_METERS 500
#define MAPVIEW_REGION_SPAN_Y_METERS 500
#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define TOURS_REQUEST_DISTANCE_KM 10
#define LOCATION_MIN_DISTANCE 5.f

#define TABLEVIEW_FOOTER_HEIGHT 15.0f
#define TABLEVIEW_BOTTOM_INSET 86.0f

#define DATA_REFRESH_RATE 60.0 //seconds
#define MAX_DISTANCE 100.0 //meters

#define CENTER_MAP_FRAME CGRectMake(8.0f, 8.0f, 30.0f, 30.0f)


/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMainViewController () <CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, OTTourOptionsDelegate, OTTourJoinRequestDelegate, OTMapOptionsDelegate, OTToursTableViewDelegate, OTTourCreatorDelegate, OTTourQuitDelegate, OTTourTimelineDelegate, EntourageCreatorDelegate, OTFiltersViewControllerDelegate>

@property (nonatomic, weak) IBOutlet OTToolbar *footerToolbar;

// map
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapSegmentedControl;
@property (nonatomic, weak) IBOutlet OTToursTableView *tableView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) CLLocationCoordinate2D encounterLocation;

@property (nonatomic, strong) OTToursMapDelegate *toursMapDelegate;
@property (nonatomic, strong) OTGuideMapDelegate *guideMapDelegate;

@property (nonatomic, strong) NSString *entourageType;

// markers
@property (nonatomic, strong) NSMutableArray *entourages;
@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic) BOOL isRegionSetted;

// tour
@property (nonatomic, assign) CGPoint mapPoint;
@property int seconds;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *pointsToSend;
@property (nonatomic, strong) NSMutableArray *closeTours;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic) BOOL isTourListDisplayed;

// tour lifecycle
@property (nonatomic, weak) IBOutlet UIButton *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *createEncounterButton;

@property (nonatomic, strong) NSMutableArray *feeds;

// tours
@property (nonatomic, strong) OTToursTableView *toursTableView;
@property (nonatomic) CLLocationCoordinate2D requestedToursCoordinate;
@property (nonatomic, strong) NSTimer *refreshTimer;

// POI
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, strong) NSMutableArray *markers;

@end

@implementation OTMainViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    
    self.locations = [NSMutableArray new];
    self.pointsToSend = [NSMutableArray new];
    self.encounters = [NSMutableArray new];
    self.markers = [NSMutableArray new];
    
    self.toursMapDelegate = [[OTToursMapDelegate alloc] initWithMapController:self];
    self.guideMapDelegate = [[OTGuideMapDelegate alloc] initWithMapController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTourConfirmation) name:@kNotificationLocalTourConfirmation object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFilters) name:@kNotificationShowFilters object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoomToCurrentLocation:) name:@kNotificationShowCurrentLocation object:nil];
    
    
    
    //[self configureTableView];
    self.mapView = [[MKMapView alloc] init];
    [self.tableView configureWithMapView:self.mapView];
    self.tableView.toursDelegate = self;
    [self configureMapView];
    
    self.mapSegmentedControl.layer.cornerRadius = 5;
    [self switchToNewsfeed];
    if (self.isTourRunning) {
        [self showNewTourOnGoing];
    } else {
        [self showToursMap];
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [self clearMap];
    
    [self feedMapViewWithEntourages];
    if (self.isTourRunning) {
        self.launcherButton.hidden = YES;
        self.createEncounterButton.hidden = NO;
        self.stopButton.hidden = NO;
        [self feedMapViewWithEncounters];
    }
    else {
        self.launcherButton.hidden = NO;
        self.stopButton.hidden = YES;
        self.createEncounterButton.hidden = YES;
    }
    [self startLocationUpdates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE target:self selector:@selector(getData) userInfo:nil repeats:YES];
    [self.refreshTimer fire];
}

- (void)viewDidAppear:(BOOL)animated {
    [self zoomToCurrentLocation:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshTimer invalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self getData];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

- (void)switchToNewsfeed {
    self.toursMapDelegate.isActive = YES;
    self.guideMapDelegate.isActive = NO;
    self.mapView.delegate = self.toursMapDelegate;
    self.mapSegmentedControl.hidden = NO;
    [self clearMap];
    [self feedMapViewWithTours];
    [self feedMapViewWithEntourages];
    [self.toursMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
    if (self.isTourListDisplayed) {
        [self showToursList];
    }
    [self.footerToolbar setTitle:@"Entourages"];
}

- (void)switchToGuide {
    self.toursMapDelegate.isActive = NO;
    self.guideMapDelegate.isActive = YES;
    self.mapView.delegate = self.guideMapDelegate;
    [self clearMap];
    [self showToursMap];
    [self.guideMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
    [self.footerToolbar setTitle:@"Guide"];// de solidarité"];
}

/**************************************************************************************************/
#pragma mark - Private methods
- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
}



- (void)configureMapView {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance( CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON), MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
    
    [self.mapView setRegion:region animated:YES];
    
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];
    
   	self.mapView.showsUserLocation = YES;
    [self zoomToCurrentLocation:nil];
    
    UIGestureRecognizer *longPressMapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMapOverlay:)];
    [self.mapView addGestureRecognizer:longPressMapGesture];
}

- (void)configureNavigationBar {
    //status bar
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    
    //navigation bar
    [self createMenuButton];
    UIBarButtonItem *chatButton = [self setupChatsButton];
    [chatButton setTarget:self];
    [chatButton setAction:@selector(showEntourages)];
    [self setupLogoImage];
}

- (void)showMapOverlay:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint touchPoint = [longPressGesture locationInView:self.mapView];
    
    if (self.presentedViewController)
        return;
    
    self.mapPoint = touchPoint;
    
    if (self.isTourRunning) {
        self.encounterLocation =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.encounterLocation.latitude longitude:self.encounterLocation.longitude];
        CLLocation *userLocation = [[CLLocation alloc]
                                    initWithLatitude:self.mapView.userLocation.coordinate.latitude
                                    longitude:self.mapView.userLocation.coordinate.longitude];
        
        CLLocationDistance distance = [location distanceFromLocation:userLocation];
        if (distance <=  MAX_DISTANCE) {
            [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:OTLocalizedString(@"distance_100")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {}];
            
            [alert addAction:defaultAction];
        }
    } else {
        self.launcherButton.hidden = NO;
        [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
    }
}

- (void)appWillEnterBackground:(NSNotification*)note {
    if (self.isTourRunning) {
        [self createLocalNotificationForTour:self.tour.uid];
    } else {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)appWillEnterForeground:(NSNotification*)note {
    [self.locationManager startUpdatingLocation];
}

- (void)showEntourages {
    [self performSegueWithIdentifier:@"EntouragesSegue" sender:self];
}

- (void)registerObserver {
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
}


static BOOL didGetAnyData = NO;
- (void)getData {
    NSLog(@"Getting new data ...");
    if (self.toursMapDelegate.isActive) {
        [self getFeeds];
    }
    else {
        [self getPOIList];
    }
}

- (void)didChangePosition {
    if (![self.mapView showsUserLocation]) {
        [self zoomToCurrentLocation:nil];
    }
    
    // check if we need to make a new request
    CLLocationDistance distance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.requestedToursCoordinate), MKMapPointForCoordinate(self.mapView.centerCoordinate))) / 1000.0f;
    if (distance < TOURS_REQUEST_DISTANCE_KM / 4) {
        return;
    }
    [self getFeeds];
}

- (void) getFeeds {
    NSLog(@"Getting feeds ...");
    __block CLLocationCoordinate2D oldRequestedCoordinate;
    oldRequestedCoordinate.latitude = self.requestedToursCoordinate.latitude;
    oldRequestedCoordinate.longitude = self.requestedToursCoordinate.longitude;
    self.requestedToursCoordinate = self.mapView.centerCoordinate;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    OTEntourageFilter *entourageFilter = [OTEntourageFilter sharedInstance];
    
    BOOL showTours = [[entourageFilter valueForFilter:kEntourageFilterEntourageShowTours] boolValue];
    BOOL myEntouragesOnly = [[entourageFilter valueForFilter:kEntourageFilterEntourageOnlyMyEntourages] boolValue];
    
    NSDictionary *filterDictionary = @{  @"page": @1,
                                         @"per": @20,
                                         @"latitude": @(self.requestedToursCoordinate.latitude),
                                         @"longitude": @(self.requestedToursCoordinate.longitude),
                                         @"distance": @TOURS_REQUEST_DISTANCE_KM,
                                         @"tour_types": [entourageFilter getTourTypes],
                                         @"entourage_types": [entourageFilter getEntourageTypes],
                                         @"show_tours": showTours ? @"true" : @"false",
                                         @"show_my_entourages_only" : myEntouragesOnly ? @"true" : @"false",
                                         @"time_range" : [entourageFilter valueForFilter:kEntourageFilterTimeframe]
                                         };
    
    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary
                                            success:^(NSMutableArray *feeds) {
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                NSLog(@"Got %lu feed items.", (unsigned long)feeds.count);
                                                
                                                if (feeds.count && !didGetAnyData) {
                                                    [self showToursList];
                                                    didGetAnyData = YES;
                                                }
                                                [self.indicatorView setHidden:YES];
                                                self.feeds = feeds;
                                                [self.tableView removeAll];
                                                [self.tableView addFeedItems:feeds];
                                                [self feedMapViewWithTours];
                                                [self.tableView reloadData];
                                            } failure:^(NSError *error) {
                                                NSLog(@"Error getting feeds: %@", error.description);
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                self.requestedToursCoordinate = oldRequestedCoordinate;
                                                [self registerObserver];
                                                [self.indicatorView setHidden:YES];
                                            }];
}

- (void)getPOIList {
    [[OTPoiService new] poisAroundCoordinate:self.mapView.centerCoordinate
                                    distance:[self mapHeight]
                                     success:^(NSArray *categories, NSArray *pois)
     {
         [self.indicatorView setHidden:YES];
         
         self.categories = categories;
         self.pois = pois;
         
         [self feedMapViewWithPoiArray:pois];
     }
                                     failure:^(NSError *error) {
                                         [self registerObserver];
                                         [self.indicatorView setHidden:YES];
                                     }];
}

- (void)feedMapViewWithEntourages {
    if (self.toursMapDelegate.isActive) {
        NSMutableArray *annotations = [NSMutableArray new];
        
        for (OTEntourage *entourage in self.entourages) {
            OTEntourageAnnotation *pointAnnotation = [[OTEntourageAnnotation alloc] initWithEntourage:entourage];
            [annotations addObject:pointAnnotation];
        }
        
        [self.clusteringController setAnnotations:annotations];
        [self.clusteringController refresh:YES force:YES];
    }
}
- (void)feedMapViewWithTours {
    self.toursMapDelegate.drawnTours = [[NSMapTable alloc] init];
    if (self.toursMapDelegate.isActive) {
        for (OTFeedItem *feedItem in self.feeds) {
            if ([feedItem isKindOfClass:[OTTour class]])
                [self drawTour:(OTTour*)feedItem];
        }
    }
}

- (void)feedMapWithFeedItems {
    if (self.toursMapDelegate.isActive) {
        //NSMutableArray *annotations = [NSMutableArray new];
        self.toursMapDelegate.drawnTours = [[NSMapTable alloc] init];
        
    }
}


- (void)feedMapViewWithEncounters {
    if (self.toursMapDelegate.isActive) {
        NSMutableArray *annotations = [NSMutableArray new];
        
        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        
        [self.clusteringController setAnnotations:annotations];
    }
}


- (void)feedMapViewWithPoiArray:(NSArray *)array {
    if (self.guideMapDelegate.isActive) {
        for (OTPoi *poi in array) {
            OTCustomAnnotation *annotation = [[OTCustomAnnotation alloc] initWithPoi:poi];
            if (![self.markers containsObject:annotation]) {
                [self.markers addObject:annotation];
            }
        }
        [self.clusteringController setAnnotations:self.markers];
    }
}

- (void)drawTour:(OTTour *)tour {
    NSLog(@"drawing %@ tour %d with %lu points ... by %@ - %@", tour.vehicleType, tour.uid.intValue, (unsigned long)tour.tourPoints.count, tour.author.displayName, tour.joinStatus);
    CLLocationCoordinate2D coords[[tour.tourPoints count]];
    int count = 0;
    for (OTTourPoint *point in tour.tourPoints) {
        coords[count++] = point.toLocation.coordinate;
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:[tour.tourPoints count]];
    [self.toursMapDelegate.drawnTours setObject:tour forKey:polyline];
    [self.mapView addOverlay:polyline];
}

- (NSString *)encounterAnnotationToString:(OTEncounterAnnotation *)annotation {
    OTEncounter *encounter = [annotation encounter];
    NSString *cellTitle = [NSString stringWithFormat:@"%@ a rencontré %@",
                           encounter.userName,
                           encounter.streetPersonName];
    
    return cellTitle;
}

- (void)displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view {
    OTMeetingCalloutViewController *controller = (OTMeetingCalloutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTMeetingCalloutViewController"];
    controller.delegate = self;
    
    OTEncounterAnnotation *encounterAnnotation = (OTEncounterAnnotation *)simpleAnnontation;
    OTEncounter *encounter = encounterAnnotation.encounter;
    [controller setEncounter:encounter];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
    
    //    [controller configureWithEncouter:encounter];
    //[Flurry logEvent:@"Open_Encounter_From_Map" withParameters:@{ @"encounter_id" : encounterAnnotation.encounter.sid }];
}

- (void)displayPoiDetails:(MKAnnotationView *)view {
    KPAnnotation *kpAnnotation = view.annotation;
    __block OTCustomAnnotation *annotation = nil;
    [[kpAnnotation annotations] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[OTCustomAnnotation class]]) {
            annotation = obj;
            *stop = YES;
        }
    }];
    
    if (annotation == nil) return;
    
    [Flurry logEvent:@"Open_POI_From_Map" withParameters:@{ @"poi_id" : annotation.poi.sid }];
    
    [self performSegueWithIdentifier:@"OTGuideDetailsSegue" sender:annotation];
}

- (CLLocationDistance)mapHeight {
    MKMapPoint mpTopRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
                                           self.mapView.visibleMapRect.origin.y);
    
    MKMapPoint mpBottomRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
                                              self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height);
    
    CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;
    
    return vDist;
}

- (void)sendTour {
    [SVProgressHUD showWithStatus:OTLocalizedString(@"tour_create_sending")];
    
    [[OTTourService new]
     sendTour:self.tour
     withSuccess:^(OTTour *sentTour) {
         
         [self.feeds addObject:sentTour];
         [self.tableView addFeedItems:@[sentTour]];
         [self.tableView reloadData];
         [SVProgressHUD dismiss];
         self.tour.uid = sentTour.uid;
         self.tour.distance = @0.0;
         
         self.stopButton.hidden = NO;
         self.createEncounterButton.hidden = NO;
         
         NSString *snapshotStartFilename = [NSString stringWithFormat:@SNAPSHOT_START, sentTour.uid.intValue];
         [self.mapView takeSnapshotToFile:snapshotStartFilename];
         [self showNewTourOnGoing];
         
         self.seconds = 0;
         self.locations = [NSMutableArray new];
         self.isTourRunning = YES;
         
         if ([self.pointsToSend count] > 0) {
             [self performSelector:@selector(sendTourPoints:) withObject:self.pointsToSend afterDelay:0.0];
         }
     } failure:^(NSError *error) {
         [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"tour_create_error", @"")];
         NSLog(@"%@",[error localizedDescription]);
     }
     ];
}

- (void)createLocalNotificationForTour:(NSNumber*)tourId {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    localNotification.alertBody = @"Maraude en cours";
    localNotification.alertAction = @"Stop";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = @{@"tourId": tourId, @"object":@"Maraude en cours"};
    localNotification.applicationIconBadgeNumber = 0;//[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}


- (void)sendTourPoints:(NSMutableArray *)tourPoint {
    __block NSArray *sentPoints = [NSArray arrayWithArray:tourPoint];
    [[OTTourService new] sendTourPoint:tourPoint
                            withTourId:self.tour.uid
                           withSuccess:^(OTTour *updatedTour) {
                               [self.pointsToSend removeObjectsInArray:sentPoints];
                           }
                               failure:^(NSError *error) {
                                   NSLog(@"%@",[error localizedDescription]);
                               }
     ];
}

- (void)addTourPointFromLocation:(CLLocation *)location {
    self.tour.distance = @(self.tour.distance.doubleValue + [location distanceFromLocation:self.locations.lastObject]);
    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:location];
    [self.tour.tourPoints addObject:tourPoint];
    [self.pointsToSend addObject:tourPoint];
    [self sendTourPoints:self.pointsToSend];
}


- (OTPoiCategory*)categoryById:(NSNumber*)sid {
    if (sid == nil) return nil;
    for (OTPoiCategory* category in self.categories) {
        if (category.sid != nil) {
            if ([category.sid isEqualToNumber:sid]) {
                return category;
            }
        }
    }
    return nil;
}

/********************************************************************************/
#pragma mark - Location Manager

- (void)startLocationUpdates {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locationManager.distanceFilter = 5; // meters
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        
        //Negative accuracy means invalid coordinates
        if (newLocation.horizontalAccuracy < 0) {
            continue;
        }
        
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        double distance = 1000.0f;
        if ([self.locations count] > 0) {
            CLLocation *previousLocation = self.locations.lastObject;
            distance = [newLocation distanceFromLocation:previousLocation];
        }
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20 && fabs(distance) > LOCATION_MIN_DISTANCE) {
            
            if (self.locations.count > 0) {
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                
                MKCoordinateRegion region = self.mapView.region;
                region.center = newLocation.coordinate;
                [self.mapView setRegion:region animated:YES];
                
                if (self.isTourRunning) {
                    [self addTourPointFromLocation:newLocation];
                    if (self.toursMapDelegate.isActive) {
                        [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                    }
                }
            }
            
            [self.locations addObject:newLocation];
        }
    }
}

- (void)clearMap {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
}

/********************************************************************************/
#pragma mark - UIGestureRecognizerDelegate

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self showToursMap];
        //
        //        CGPoint point = [sender locationInView:self.mapView];
        //        CLLocationCoordinate2D location = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        //        [[OTTourService new] toursAroundCoordinate:location
        //                                             limit:@5
        //                                          distance:@0.04
        //                                           success:^(NSMutableArray *closeTours) {
        //                                               [self.indicatorView setHidden:YES];
        //                                               if (closeTours.count != 0) {
        //                                                   self.closeTours = closeTours;
        //                                                   [self performSegueWithIdentifier:@"OTCloseTours" sender:sender];
        //                                               }
        //                                           } failure:^(NSError *error) {
        //                                               [self registerObserver];
        //                                               [self.indicatorView setHidden:YES];
        //                                           }];
    }
}

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
    [self.popover dismissPopoverAnimated:YES];
}

/********************************************************************************/
#pragma mark - OTConfirmationViewControllerDelegate

- (void)tourSent:(OTTour*)tour {
    
    //check if there is an ongoing tour
    if (self.tour == nil) {
        return;
    }
    //check if we are stoping the current ongoing tour
    if (tour != nil && tour.uid != nil) {
        if (self.tour.uid == nil || ![tour.uid isEqualToNumber:self.tour.uid]) {
            return;
        }
    }
    
    [SVProgressHUD showSuccessWithStatus:@"Maraude terminée!"];
    
    self.tour = nil;
    //self.currentTourType = nil;
    [self.pointsToSend removeAllObjects];
    [self.encounters removeAllObjects];
    
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    self.isTourRunning = NO;
    self.requestedToursCoordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    [self clearMap];
    [self getData];
}

- (void)resumeTour {
    self.isTourRunning = YES;
    self.stopButton.hidden = NO;
    self.createEncounterButton.hidden = NO;
}

/********************************************************************************/
#pragma mark - OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter {
    [self dismissViewControllerAnimated:YES completion:^{
        [self feedMapViewWithEncounters];
    }];
}

/********************************************************************************/
#pragma mark - OTTourOptionsDelegate

- (void)createEncounter {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive) {
            [self performSegueWithIdentifier:@"OTCreateMeeting" sender:nil];
        } else {
            [self showNewEncounterStartDialogFromGuide];
        }
    }];
}

- (void)dismissTourOptions {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.isTourRunning) {
            [self showNewTourOnGoing];
        }
    }];
}

/********************************************************************************/
#pragma mark - OTMapOptionsDelegate

- (void)createTour {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive) {
            [self performSegueWithIdentifier:@"TourCreatorSegue" sender:nil];
        } else {
            //[self showNewTourStartDialogFromGuide];
            [self showAlert:OTLocalizedString(@"poi_create_tour_alert") withSegue:@"TourCreatorSegue"];
        }
    }];
}

- (void)createDemande {
    self.entourageType = ENTOURAGE_DEMANDE;
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive) {
            [self performSegueWithIdentifier:@"EntourageCreator" sender:nil];
        } else {
            //[self showNewTourStartDialogFromGuide];
            [self showAlert:OTLocalizedString(@"poi_create_demande_alert") withSegue:@"EntourageCreator"];
        }
    }];
}

- (void)createContribution {
    self.entourageType = ENTOURAGE_CONTRIBUTION;
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive) {
            [self performSegueWithIdentifier:@"EntourageCreator" sender:nil];
        } else {
            //[self showNewTourStartDialogFromGuide];
             [self showAlert:OTLocalizedString(@"poi_create_contribution_alert") withSegue:@"EntourageCreator"];
        }
    }];
}

- (void)togglePOI {
    [self dismissViewControllerAnimated:NO
                             completion:^{
                                 if (self.toursMapDelegate.isActive) {
                                     [self switchToGuide];
                                 } else {
                                     [self switchToNewsfeed];
                                 }
                             }];
}

- (void)dismissMapOptions {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/********************************************************************************/
#pragma mark - OTTourCreatorDelegate

- (void)createTour:(NSString*)tourType withVehicle:(NSString*)vehicleType {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    self.currentTourType = tourType;
    self.tour = [[OTTour alloc] initWithTourType:tourType andVehicleType:vehicleType];
    [self.pointsToSend removeAllObjects];
    if ([self.locations count] > 0) {
        OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:self.locations.lastObject];
        [self.tour.tourPoints addObject:tourPoint];
        [self.pointsToSend addObject:tourPoint];
    }
    [self sendTour];
}

/********************************************************************************/
#pragma mark - EntourageCreatorDelegate

- (void)didCreateEntourage {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/********************************************************************************/
#pragma mark - OTTourJoinRequestDelegate

- (void)dismissTourJoinRequestController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

/********************************************************************************/
#pragma mark - OTTourQuitDelegate

- (void)didQuitTour {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

/**************************************************************************************************/
#pragma mark - OTTourDetailsOptionsDelegate

- (void)promptToCloseTour {
    [self dismissViewControllerAnimated:NO completion:^{
        [self stopTour:nil];
    }];
}

/**************************************************************************************************/
#pragma mark - OTFiltersViewControllerDelegate

- (void) filterChanged {
    [self getData];
}

/**************************************************************************************************/
#pragma mark - Actions

- (void)showFilters {
    [self performSegueWithIdentifier:@"FiltersSegue" sender:self];
}


- (IBAction)zoomToCurrentLocation:(id)sender {
    
    if (self.mapView.userLocation.location != nil) {
        CLLocationDistance distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.mapView.centerCoordinate), MKMapPointForCoordinate(self.mapView.userLocation.coordinate));
        BOOL animatedSetCenter = (distance < MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS);
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:animatedSetCenter];
    }
}

static bool isShowingOptions = NO;
- (IBAction)launcherTour:(UIButton *)sender {
    
    isShowingOptions = !isShowingOptions;
    [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
}

- (IBAction)showPOI:(id)sender {
    [self launcherTour:self.launcherButton];
    
    [self togglePOI];
}

- (IBAction)closeLauncher:(id)sender {
    self.launcherButton.hidden = NO;
}

- (IBAction)stopTour:(id)sender {
    [UIView animateWithDuration:0.5 animations:^(void) {
        CGRect mapFrame = self.mapView.frame;
        mapFrame.size.height = MAPVIEW_HEIGHT;
        self.mapView.frame = mapFrame;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.launcherButton.hidden = YES;
        self.createEncounterButton.hidden = YES;
        self.mapSegmentedControl.hidden = YES;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        
    }];
    NSString *snapshotEndFilename = [NSString stringWithFormat:@SNAPSHOT_STOP, self.tour.uid.intValue];
    [self.mapView takeSnapshotToFile:snapshotEndFilename];
    
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:sender];
}


/**************************************************************************************************/
#pragma mark - Feeds Table View Delegate

- (void)showFeedInfo:(OTFeedItem *)feedItem {
    self.selectedFeedItem = feedItem;
    
    [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
    return;
    
    if ([self.selectedFeedItem.joinStatus isEqualToString:@"accepted"]) {
        [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"OTPublicTourSegue" sender:self];
    }
}

- (void)showUserProfile:(NSNumber*)userId {
    [[OTAuthService new] getDetailsForUser:userId
                                   success:^(OTUser *user) {
                                       NSLog(@"got user %@", user);
                                       [self performSegueWithIdentifier:@"UserProfileSegue" sender:user];
                                       
                                   } failure:^(NSError *error) {
                                       NSLog(@"@fails getting user %@", error.description);
                                   }];
    
}

- (void)doJoinRequest:(OTFeedItem*)feedItem {
    self.selectedFeedItem = feedItem;
    
    if ([feedItem.joinStatus isEqualToString:@"not_requested"])
    {
        [self performSegueWithIdentifier:@"OTTourJoinRequestSegue" sender:nil];
    }
    else  if ([feedItem.joinStatus isEqualToString:@"pending"])
    {
        [self performSegueWithIdentifier:@"OTPublicTourSegue" sender:nil];
    }
    else
    {
        OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
        if (currentUser.sid.intValue == feedItem.author.uID.intValue) {
            if (self.isTourRunning && feedItem.uid.intValue == self.tour.uid.intValue) {
                [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
            } else {
                //TODO: freeze! :D
                feedItem.status = TOUR_STATUS_FREEZED;
                [[OTTourService new] closeTour:(OTTour*)feedItem
                                   withSuccess:^(OTTour *closedTour) {
                                       [self dismissViewControllerAnimated:YES completion:^{
                                           [self.tableView reloadData];
                                           
                                       }];
                                       [SVProgressHUD showSuccessWithStatus:@""];
                                   } failure:^(NSError *error) {
                                       [SVProgressHUD showErrorWithStatus:@"Erreur"];
                                       NSLog(@"%@",[error localizedDescription]);
                                   }];
            }
        } else {
            [self performSegueWithIdentifier:@"QuitTourSegue" sender:self];
        }
    }
}

/**************************************************************************************************/
#pragma mark - Segmented control
- (IBAction)changedSegmentedControlValue:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        [self showToursList];
    }
}

/**************************************************************************************************/
#pragma mark - "Screens"

- (void)showToursList {
    
    self.isTourListDisplayed = YES;
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect mapFrame = self.mapView.frame;
        mapFrame.size.height = MAPVIEW_HEIGHT;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        self.mapSegmentedControl.hidden = YES;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
}

- (void)showToursMap {
    
    if (self.toursMapDelegate.isActive) {
        self.isTourListDisplayed = NO;
    }
    
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f;
    [self.mapSegmentedControl setSelectedSegmentIndex:0];
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        self.mapSegmentedControl.hidden = self.guideMapDelegate.isActive;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
    
}

#pragma mark 6.4 Tours "+" press
- (void)showMapOverlayToCreateTour {
    self.launcherButton.hidden = NO;
}

#pragma mark 15.2 New Tour - on going
- (void)showNewTourOnGoing {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f;
    [self.mapSegmentedControl setSelectedSegmentIndex:0];
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.mapSegmentedControl.hidden = NO;
        self.launcherButton.hidden = YES;
        self.createEncounterButton.hidden = NO;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
    
}

- (void)showTourConfirmation {
    NSLog(@"showing tour confirmation");
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
}

#pragma mark - Guide

//- (void)showNewTourStartDialogFromGuide {
//    [self showAlert:OTLocalizedString(@"poi_create_tour_alert") withSegue:@"TourCreatorSegue"];
//}

- (void)showAlert:(NSString *)feedItemAlertMessage withSegue:(NSString *)segueID {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:feedItemAlertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Annuler"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"Quitter"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [self switchToNewsfeed];
        
        [self performSegueWithIdentifier:segueID sender:nil];
    }];
    [alert addAction:quitAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showNewEncounterStartDialogFromGuide {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"poi_create_encounter_alert", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"Quitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self switchToNewsfeed];
    }];
    [alert addAction:quitAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/********************************************************************************/
#pragma mark - Segue
typedef NS_ENUM(NSInteger) {
    SegueIDUserProfile,
    SegueIDCreateMeeting,
    SegueIDConfirmation,
    SegueIDSelectedTour,
    SegueIDPublicTour,
    SegueIDTourOptions,
    SegueIDMapOptions,
    SegueIDTourJoinRequest,
    SegueIDQuitTour,
    SegueIDGuideSolidarity,
    SegueIDGuideSolidarityDetails,
    SegueIDTourCreator,
    SegueIDEntourageCreator,
    SegueIDEntourages,
    SegueIDFilter
} SegueID;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSDictionary *seguesDictionary = @{@"UserProfileSegue" : [NSNumber numberWithInteger:SegueIDUserProfile],
                                       @"OTCreateMeeting":[NSNumber numberWithInteger:SegueIDCreateMeeting],
                                       @"OTConfirmationPopup" : [NSNumber numberWithInteger:SegueIDConfirmation],
                                       @"OTSelectedTour" : [NSNumber numberWithInteger:SegueIDSelectedTour],
                                       @"OTPublicTourSegue" : [NSNumber numberWithInteger:SegueIDPublicTour],
                                       @"OTTourOptionsSegue" : [NSNumber numberWithInteger:SegueIDTourOptions],
                                       @"OTMapOptionsSegue": [NSNumber numberWithInteger:SegueIDMapOptions],
                                       @"OTTourJoinRequestSegue": [NSNumber numberWithInteger:SegueIDTourJoinRequest],
                                       @"QuitTourSegue": [NSNumber numberWithInteger:SegueIDQuitTour],
                                       @"GuideSegue": [NSNumber numberWithInteger:SegueIDGuideSolidarity],
                                       @"OTGuideDetailsSegue": [NSNumber numberWithInteger:SegueIDGuideSolidarityDetails],
                                       @"TourCreatorSegue": [NSNumber numberWithInteger:SegueIDTourCreator],
                                       @"EntourageCreator": [NSNumber numberWithInteger:SegueIDEntourageCreator],
                                       @"EntouragesSegue": [NSNumber numberWithInteger:SegueIDEntourages],
                                       @"FiltersSegue" : [NSNumber numberWithInteger:SegueIDFilter]};
    
    UIViewController *destinationViewController = segue.destinationViewController;
    NSInteger segueID = [[seguesDictionary numberForKey:segue.identifier defaultValue:@-1] integerValue];
    
    
    switch (segueID) {
        case SegueIDUserProfile: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
            controller.user = (OTUser*)sender;
        } break;
        case SegueIDCreateMeeting: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTCreateMeetingViewController *controller = (OTCreateMeetingViewController*)navController.topViewController;
            controller.delegate = self;
            [controller configureWithTourId:self.tour.uid andLocation:self.encounterLocation];
            controller.encounters = self.encounters;
        } break;
        case SegueIDConfirmation: {
            OTConfirmationViewController *controller = (OTConfirmationViewController *)destinationViewController;
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            controller.view.backgroundColor = [UIColor appModalBackgroundColor];
            controller.delegate = self;
            self.isTourRunning = NO;
            [controller configureWithTour:self.tour
                       andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]];
        } break;
        case SegueIDSelectedTour: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTFeedItemViewController *controller = (OTFeedItemViewController *)navController.topViewController;
            controller.feedItem = (OTFeedItem*)self.selectedFeedItem;
            //[controller configureWithTour:(OTFeedItem*)self.selectedFeedItem];
            //controller.delegate = self;
        } break;
        case SegueIDPublicTour: {
            UINavigationController *navController = segue.destinationViewController;
            OTPublicTourViewController *controller = (OTPublicTourViewController *)navController.topViewController;
            controller.tour = (OTTour*)self.selectedFeedItem;
        } break;
            
        case SegueIDMapOptions: {
            OTMapOptionsViewController *controller = (OTMapOptionsViewController *)segue.destinationViewController;;
            if (!CGPointEqualToPoint(self.mapPoint, CGPointZero)) {
                controller.fingerPoint = self.mapPoint;
                self.mapPoint = CGPointZero;
            }
            
            controller.mapOptionsDelegate = self;
            [controller setIsPOIVisible:self.guideMapDelegate.isActive];
        } break;
        case SegueIDTourOptions: {
            OTTourOptionsViewController *controller = (OTTourOptionsViewController *)destinationViewController;
            controller.tourOptionsDelegate = self;
            [controller setIsPOIVisible:self.guideMapDelegate.isActive];
            if (!CGPointEqualToPoint(self.mapPoint, CGPointZero)) {
                controller.c2aPoint = self.mapPoint;
                self.mapPoint = CGPointZero;
            }
        } break;
        case SegueIDTourJoinRequest: {
            OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)destinationViewController;
            controller.view.backgroundColor = [UIColor appModalBackgroundColor];
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            controller.feedItem = self.selectedFeedItem;
            controller.tourJoinRequestDelegate = self;
        } break;
        case SegueIDQuitTour: {
            OTQuitTourViewController *controller = (OTQuitTourViewController *)destinationViewController;
            controller.view.backgroundColor = [UIColor appModalBackgroundColor];
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            controller.tour = (OTTour*)self.selectedFeedItem;
            controller.tourQuitDelegate = self;
        } break;
        case SegueIDGuideSolidarity: {
            UINavigationController *navController = segue.destinationViewController;
            OTGuideViewController *controller = (OTGuideViewController *)navController.childViewControllers[0];
            [controller setIsTourRunning:self.isTourRunning];
        } break;
        case SegueIDGuideSolidarityDetails: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTGuideDetailsViewController *controller = navController.childViewControllers[0];
            controller.poi = ((OTCustomAnnotation*)sender).poi;
            controller.category = [self categoryById:controller.poi.categoryId];
        } break;
        case SegueIDTourCreator: {
            OTTourCreatorViewController *controller = (OTTourCreatorViewController *)destinationViewController;
            controller.view.backgroundColor = [UIColor appModalBackgroundColor];
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            controller.tourCreatorDelegate = self;
        } break;
        case SegueIDEntourageCreator: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTEntourageCreatorViewController *controller = (OTEntourageCreatorViewController *)navController.childViewControllers[0];
            controller.type = self.entourageType;
            CLLocationDegrees lat = self.mapView.userLocation.coordinate.latitude;
            CLLocationDegrees lon = self.mapView.userLocation.coordinate.longitude;
            CLLocation *location = [[CLLocation alloc] initWithLatitude: lat
                                                              longitude:lon];
            controller.location = location;
            controller.entourageCreatorDelegate = self;
        } break;
        case SegueIDEntourages: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTEntouragesViewController *controller = (OTEntouragesViewController*)navController.topViewController;
            controller.mainViewController = self;
        } break;
        case SegueIDFilter: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTFiltersViewController *controller = (OTFiltersViewController*)navController.topViewController;
            controller.isOngoingTour = self.isTourRunning;
            controller.delegate = self;
        } break;
        default:
            break;
    }
}

@end