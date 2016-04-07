    //
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

// Controller
#import "OTMapViewController.h"
#import "UIViewController+menu.h"
#import "OTCreateMeetingViewController.h"
#import "OTToursTableViewController.h"
#import "OTCalloutViewController.h"
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTTourJoinRequestViewController.h"
#import "OTTourViewController.h"
#import "OTPublicTourViewController.h"
#import "OTQuitTourViewController.h"
#import "OTGuideViewController.h"
#import "UIView+entourage.h"
#import "OTUserViewController.h"

//#import "UIViewController+MapView.h"
#import "KPAnnotation.h"
#import "KPClusteringController.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"


// View
#import "SVProgressHUD.h"
#import "OTToursTableView.h"

// Model
#import "OTUser.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"

// Service
#import "OTTourService.h"
#import "OTAuthService.h"

#import "UIButton+entourage.h"
#import "UIColor+entourage.h"
#import "UILabel+entourage.h"

// Framework
#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>
#import <QuartzCore/QuartzCore.h>
#import "TTTTimeIntervalFormatter.h"
#import "TTTLocationFormatter.h"

// User
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"



#define PARIS_LAT 48.856578
#define PARIS_LON  2.351828
#define MAPVIEW_HEIGHT 160.f
#define LOCATION_MIN_DISTANCE 10.f

#define TABLEVIEW_FOOTER_HEIGHT 15.0f
#define TABLEVIEW_BOTTOM_INSET 86.0f


/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, OTTourOptionsDelegate, OTTourJoinRequestDelegate, OTMapOptionsDelegate, OTToursTableViewDelegate>

// blur effect

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffect;
@property (weak, nonatomic) IBOutlet UIButton *createTourOnBlurButton;
@property (weak, nonatomic) IBOutlet UILabel *createTourLabel;

// map

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSegmentedControl;
@property (weak, nonatomic) IBOutlet OTToursTableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) NSMapTable *drawnTours;
@property (weak, nonatomic) IBOutlet UIImageView *pointerPin;

// markers

@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic) BOOL isRegionSetted;
@property (nonatomic, strong) KPClusteringController *clusteringController;

// tour

@property (nonatomic, assign) CGPoint mapPoint;
@property BOOL isTourRunning;
@property int seconds;
@property NSString *currentTourType;
@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *pointsToSend;
@property (nonatomic, strong) NSMutableArray *closeTours;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) OTTour *selectedTour;

// tour lifecycle

@property (nonatomic, weak) IBOutlet UIView *launcherView;
@property (nonatomic, weak) IBOutlet UIButton *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton *launcherCloseButton;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *createEncounterButton;

// launcher

@property (nonatomic, weak) IBOutlet UIButton *feetButton;
@property (nonatomic, weak) IBOutlet UIButton *carButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *typeButtons;

// tours

@property (nonatomic, strong) NSMutableArray *tours;
@property (nonatomic, strong) OTToursTableView *toursTableView;

@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;

    self.locations = [NSMutableArray new];
    self.pointsToSend = [NSMutableArray new];
    self.encounters = [NSMutableArray new];
    //self.closeTours = [NSMutableArray new];
    self.drawnTours = [NSMapTable new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

	[self configureNavigationBar];
    //[self configureMapView];
    self.mapSegmentedControl.layer.cornerRadius = 4;
    [self configureTableView];
    
    [self showToursMap];
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    _locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    [self clearMap];
	[self refreshMap];
    
    self.launcherView.hidden = YES;
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.timer invalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self refreshMap];
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

/**************************************************************************************************/
#pragma mark - Private methods
- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
}

- (void)configureTableView {
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, -TABLEVIEW_FOOTER_HEIGHT, 0.0f);
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, TABLEVIEW_BOTTOM_INSET)];
    self.tableView.tableFooterView = dummyView;
    self.blurEffect.hidden = YES;
    
    
    //show map on table header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width+8, MAPVIEW_HEIGHT)];
    self.mapView = [[MKMapView alloc] initWithFrame:headerView.bounds];
    [headerView addSubview:self.mapView];
    [headerView sendSubviewToBack:self.mapView];
    [self configureMapView];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 156.0f , headerView.frame.size.width + 130.0f, 4.0f)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = shadowView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)([UIColor colorWithRed:0 green:0 blue:0 alpha:.2].CGColor),  nil];
    [shadowView.layer insertSublayer:gradient atIndex:1];
    [headerView addSubview:shadowView];
    
    NSDictionary *viewsDictionary = @{@"shadow":shadowView};
    NSArray *constraint_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[shadow(4)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    NSArray *constraint_pos_horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-8)-[shadow]-(-8)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    NSArray *constraint_pos_bottom = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[shadow]-0-|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
    shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    [shadowView addConstraints:constraint_height];
    [headerView addConstraints:constraint_pos_horizontal];
    [headerView addConstraints:constraint_pos_bottom];
    self.mapView.center = headerView.center;
    self.tableView.tableHeaderView = headerView;
    self.tableView.toursDelegate = self;
}

- (void)configureMapView {
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];

    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];

   	self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self zoomToCurrentLocation:nil];
    
    UIGestureRecognizer *longPressMapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMapOverlay:)];
    [self.mapView addGestureRecognizer:longPressMapGesture];
    
    UITapGestureRecognizer *hideTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCreateTourOverlay)];
    [self.blurEffect addGestureRecognizer:hideTapGesture];
}

- (void)showMapOverlay:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint touchPoint = [longPressGesture locationInView:self.mapView];

    if (_isTourRunning) {
        self.mapPoint = touchPoint;
        [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
    } else {
        [self showMapOverlayToCreateTourAtPoint:touchPoint];
    }
}

- (void)hideCreateTourOverlay {
    self.blurEffect.hidden = YES;
}

- (void)appWillEnterBackground:(NSNotification*)note {
    if (!self.isTourRunning) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)appWillEnterForeground:(NSNotification*)note {
    [self.locationManager startUpdatingLocation];
}

- (void)configureNavigationBar {
    
    [self createMenuButton];
    UIBarButtonItem *chatButton = [self setupChatsButton];
    [chatButton setTarget:self];
    [chatButton setAction:@selector(showEntourages)];
    [self setupLogoImage];
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
- (void)refreshMap {
    [[OTTourService new] toursAroundCoordinate:self.mapView.centerCoordinate
                                         limit:@10
                                      distance:@100//*[NSNumber numberWithDouble:[self mapHeight]]
                                       success:^(NSMutableArray *closeTours)
                                        {
                                            if (closeTours.count && !didGetAnyData) {
                                                [self showToursList];
                                                didGetAnyData = YES;
                                            }
                                            [self.indicatorView setHidden:YES];
                                            self.tours = closeTours;
                                            [self.tableView addTours:closeTours];
                                            [self feedMapViewWithTours];
                                            [self.tableView reloadData];
                                        }
                                       failure:^(NSError *error) {
                                            [self registerObserver];
                                            [self.indicatorView setHidden:YES];
                                        }];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_tours_only"]) {
        [[OTTourService new] toursByUserId:[[NSUserDefaults standardUserDefaults] currentUser].sid
                            withPageNumber:@1
                          andNumberPerPage:@50
                                   success:^(NSMutableArray *userTours) {
                                       [self.indicatorView setHidden:YES];
                                       self.tours = userTours;
                                       [self.tableView addTours:userTours];
                                       [self feedMapViewWithTours];
                                       [self.tableView reloadData];
                                   } failure:^(NSError *error) {
                                       [self registerObserver];
                                       [self.indicatorView setHidden:YES];
                                   }];
    }
}

- (CLLocationDistance)mapHeight {
	MKMapPoint mpTopRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
	                                       self.mapView.visibleMapRect.origin.y);

	MKMapPoint mpBottomRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
	                                          self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height);

	CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;

	return vDist;
}

- (void)feedMapViewWithEncounters {
	NSMutableArray *annotations = [NSMutableArray new];

	for (OTEncounter *encounter in self.encounters) {
		OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
		[annotations addObject:pointAnnotation];
	}
    
    [self.clusteringController setAnnotations:annotations];
}

- (void)feedMapViewWithTours {
    for (OTTour *tour in self.tours) {
        [self drawTour:tour];
    }
}

- (void)drawTour:(OTTour *)tour {
    CLLocationCoordinate2D coords[[tour.tourPoints count]];
    int count = 0;
    for (OTTourPoint *point in tour.tourPoints) {
        coords[count++] = point.toLocation.coordinate;
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:[tour.tourPoints count]];
    //OTTour *t = [self.drawnTours objectForKey:polyline];
    //if (t == nil) {
        [self.drawnTours setObject:tour forKey:polyline];
        [self.mapView addOverlay:polyline];
    //}
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

- (void)eachSecond {
    self.seconds++;
}

- (void)sendTour {
    [[OTTourService new]
         sendTour:self.tour
         withSuccess:^(OTTour *sentTour) {
             self.tour.sid = sentTour.sid;
             self.tour.distance = 0.0;
             
             self.pointerPin.hidden = NO;
             self.launcherView.hidden = YES;
             self.stopButton.hidden = NO;
             self.createEncounterButton.hidden = NO;
             
             self.seconds = 0;
             self.locations = [NSMutableArray new];
             self.isTourRunning = YES;
             
             if ([self.pointsToSend count] > 0) {
                 [self performSelector:@selector(sendTourPoints:) withObject:self.pointsToSend afterDelay:0.0];
             }
             
        } failure:^(NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
        }
     ];
}

- (void)sendTourPoints:(NSMutableArray *)tourPoint {
    __block NSArray *sentPoints = [NSArray arrayWithArray:tourPoint];
    [[OTTourService new] sendTourPoint:tourPoint
                            withTourId:self.tour.sid
                           withSuccess:^(OTTour *updatedTour) {
                               [self.pointsToSend removeObjectsInArray:sentPoints];
                           }
                               failure:^(NSError *error) {
                                   NSLog(@"%@",[error localizedDescription]);
                               }
     ];
}

- (void)hideBlurEffect {
    [self.blurEffect setHidden:YES];
    
}

/********************************************************************************/
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;
        
        if ([kingpinAnnotation isCluster]) {
            JSBadgeView *badgeView;
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterClusterAnnotationIdentifier];
            if (!annotationView) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:kEncounterClusterAnnotationIdentifier];
                annotationView.canShowCallout = NO;
                annotationView.image = [UIImage imageNamed:@"report"];
                badgeView = [[JSBadgeView alloc] initWithParentView:annotationView alignment:JSBadgeViewAlignmentBottomCenter];
            }
            else {
                for (UIView *subview in annotationView.subviews) {
                    if ([subview isKindOfClass:JSBadgeView.class]) {
                        badgeView = (JSBadgeView *)subview;
                    }
                }
            }
            badgeView.badgeText = [NSString stringWithFormat:@"%lu", (unsigned long)kingpinAnnotation.annotations.count];
        }
        else {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
                annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
                if (!annotationView) {
                    annotationView = ((OTEncounterAnnotation *)simpleAnnontation).annotationView;
                }
                annotationView.annotation = simpleAnnontation;
            }
        }
        annotationView.canShowCallout = YES;
    }
    
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	[self refreshMap];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	if (!self.isRegionSetted) {
		self.isRegionSetted = YES;
		[self zoomToCurrentLocation:nil];
	}
}

- (void)startLocationUpdates {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locationManager.distanceFilter = 5; // meters
    
    [self.locationManager startUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    
    if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)view.annotation;
        if ([kingpinAnnotation isCluster]) {
            // Do nothing
        }
        else {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
                [self displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        NSLog(@"LOC %.4f, %.4f of %lu", newLocation.coordinate.latitude, newLocation.coordinate.longitude, (unsigned long)locations.count);
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
        
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
            
                if (self.isTourRunning) {
                    self.tour.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:newLocation];
                    [self.tour.tourPoints addObject:tourPoint];
                    [self.pointsToSend addObject:tourPoint];
                    [self sendTourPoints:self.pointsToSend];
                }
            }
        
            [self.locations addObject:newLocation];
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *) overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
        
        OTTour *tour = [self.drawnTours objectForKey:polyline];
        if ([tour.tourType isEqualToString:@"medical"]) {
            aRenderer.strokeColor = [UIColor redColor];
        }
        else if ([tour.tourType isEqualToString:@"barehands"]) {
            aRenderer.strokeColor = [UIColor blueColor];
        }
        else if ([tour.tourType isEqualToString:@"alimentary"]) {
            aRenderer.strokeColor = [UIColor greenColor];
        }
        
        if (self.isTourRunning && tour == nil) {
            if ([self.currentTourType isEqualToString:@"medical"]) {
                aRenderer.strokeColor = [UIColor redColor];
            }
            else if ([self.currentTourType isEqualToString:@"barehands"]) {
                aRenderer.strokeColor = [UIColor blueColor];
            }
            else if ([self.currentTourType isEqualToString:@"alimentary"]) {
                aRenderer.strokeColor = [UIColor greenColor];
            }
        }
        
        aRenderer.lineWidth = 4;
        return aRenderer;
    }
    return nil;
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

- (void)tourSent {
    [SVProgressHUD showSuccessWithStatus:@"Maraude terminée!"];
    [self hideBlurEffect];
    
    self.tour = nil;
    self.currentTourType = nil;
    [self.pointsToSend removeAllObjects];
    [self.encounters removeAllObjects];
    
    self.pointerPin.hidden = YES;
    self.launcherView.hidden = YES;
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    self.isTourRunning = NO;
    [self clearMap];
}

- (void)resumeTour {
    [self hideBlurEffect];
    self.isTourRunning = YES;
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
        [self performSegueWithIdentifier:@"OTCreateMeeting" sender:nil];
    }];
}

- (void)dismissTourOptions {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/********************************************************************************/
#pragma mark - OTMapOptionsDelegate

- (void)createTour {
    [self dismissViewControllerAnimated:NO completion:^{
        [self showNewTourStart];
    }];
}

- (void)togglePOI {
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"GuideSegue" sender:nil];
    }];
}

- (void)dismissMapOptions {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/********************************************************************************/
#pragma mark - OTTourJoinRequestDelegate

- (void)dismissTourJoinRequestController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

/********************************************************************************/
#pragma mark - Segue
typedef NS_ENUM(NSInteger) {
    SegueIDCreateMeeting,
    SegueIDConfirmation,
    SegueIDSelectedTour,
    SegueIDPublicTour,
    SegueIDTourOptions,
    SegueIDMapOptions,
    SegueIDTourJoinRequest,
    SegueIDQuitTour,
    SegueIDGuideSolidarity
} SegueID;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary *seguesDictionary = @{@"OTCreateMeeting" : [NSNumber numberWithInteger:SegueIDCreateMeeting]};
    
    NSString *segueIDString = segue.identifier;
    NSInteger segueID = [[seguesDictionary numberForKey:segueIDString] integerValue];
    switch (segueID) {
            
        default:
            break;
    }
    if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
        controller.user = (OTUser*)sender;
    } else
    if ([segue.identifier isEqualToString:@"OTCreateMeeting"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTCreateMeetingViewController *controller = (OTCreateMeetingViewController*)navController.topViewController;
        controller.delegate = self;
        [controller configureWithTourId:self.tour.sid andLocation:self.mapView.region.center];
        controller.encounters = self.encounters;
    } else if ([segue.identifier isEqualToString:@"OTConfirmationPopup"]) {
        OTConfirmationViewController *controller = (OTConfirmationViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor clearColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.delegate = self;
        self.isTourRunning = NO;
        [controller configureWithTour:self.tour
                   andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]];
    } else if ([segue.identifier isEqualToString:@"OTSelectedTour"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTTourViewController *controller = (OTTourViewController *)navController.topViewController;
        controller.tour = self.selectedTour;
        [controller configureWithTour:self.selectedTour];
    } else if ([segue.identifier isEqualToString:@"OTPublicTourSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTPublicTourViewController *controller = (OTPublicTourViewController *)navController.topViewController;
        controller.tour = self.selectedTour;
    } else if ([segue.identifier isEqualToString:@"OTTourOptionsSegue"]) {
        OTTourOptionsViewController *controller = (OTTourOptionsViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithWhite:1.f alpha:.88f];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tourOptionsDelegate = self;
        if (!CGPointEqualToPoint(self.mapPoint, CGPointZero) ) {
            controller.c2aPoint = self.mapPoint;
        }
    } else if ([segue.identifier isEqualToString:@"OTMapOptionsSegue"]) {
        OTMapOptionsViewController *controller = (OTMapOptionsViewController *)segue.destinationViewController;;
        controller.mapOptionsDelegate = self;
        [controller setIsPOIVisible:NO];
    } else if ([segue.identifier isEqualToString:@"OTTourJoinRequestSegue"]) {
        OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tour = self.selectedTour;
        controller.tourJoinRequestDelegate = self;
    } else if ([segue.identifier isEqualToString:@"QuitTourSegue"]) {
        OTQuitTourViewController *controller = (OTQuitTourViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tour = self.selectedTour;
        //controller.tourJoinRequestDelegate = self;
    } else if ([segue.identifier isEqualToString:@"GuideSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTGuideViewController *controller = (OTGuideViewController *)navController.childViewControllers[0];
        [controller setIsTourRunning:self.isTourRunning];
    }
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)zoomToCurrentLocation:(id)sender {
	float spanX = 0.01;
	float spanY = 0.01;
	MKCoordinateRegion region;

	region.center.latitude = self.mapView.userLocation.coordinate.latitude;
	region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    
    if (region.center.latitude < .00001 && region.center.longitude < .00001) {
        region.center = CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON);
    }

	region.span.latitudeDelta = spanX;
	region.span.longitudeDelta = spanY;
	[self.mapView setRegion:region animated:YES];
}

static bool isShowingOptions = NO;
- (IBAction)launcherTour:(UIButton *)sender {
    
    /*
    if (isShowingOptions) {
        self.blurEffect.hidden = YES;
    } else {
        [self showMapOverlayToCreateTour];
    }
     */
    isShowingOptions = !isShowingOptions;
    [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
    //[sender setSelected:!sender.isSelected];
}

- (IBAction)createTour:(id)sender {
    [self launcherTour:self.launcherButton];
    self.launcherButton.hidden = YES;
    
    [self showNewTourStart];
}

- (IBAction)showPOI:(id)sender {
    [self launcherTour:self.launcherButton];
    
    [self togglePOI];
}

- (IBAction)closeLauncher:(id)sender {
    self.launcherButton.hidden = NO;
    self.launcherView.hidden = YES;
}

- (IBAction)feetButtonDidTap:(id)sender {
    [self.feetButton setSelected:YES];
    [self.carButton setSelected:NO];
}

- (IBAction)carButtonDidTap:(id)sender {
    [self.carButton setSelected:YES];
    [self.feetButton setSelected:NO];
}

- (IBAction)typeButtonDidTap:(UIView *)sender {
    for (UIButton *button in self.typeButtons) {
        button.selected = (button == sender);
    }
}

- (IBAction)startTour:(id)sender {
    self.tour = [[OTTour alloc] initWithTourType:[self selectedTourType] andVehicleType:[self selectedVehiculeType]];
    [self.pointsToSend removeAllObjects];
    if ([self.locations count] > 0) {
        OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:self.locations.lastObject];
        [self.tour.tourPoints addObject:tourPoint];
        [self.pointsToSend addObject:tourPoint];
    }
    [self sendTour];
    [self showNewTourOnGoing];
}

- (IBAction)stopTour:(id)sender {
    [self.blurEffect setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^(void) {
        CGRect mapFrame = self.mapView.frame;
        mapFrame.size.height = MAPVIEW_HEIGHT;
        self.mapView.frame = mapFrame;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.launcherButton.hidden = YES;
        self.mapSegmentedControl.hidden = YES;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];

    }];
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:sender];
}

/**************************************************************************************************/
#pragma mark - Utils

- (NSString *)selectedVehiculeType {
    if (self.feetButton.selected) {
        return NSLocalizedString(@"tour_vehicle_feet", @"");
    }
    else if (self.carButton.selected) {
        return NSLocalizedString(@"tour_vehicle_car", @"");
    }
    return nil;
}

- (NSString *)selectedTourType {
    NSInteger selectedType = 0;
    for (UIButton *button in self.typeButtons) {
        if (button.selected) {
            selectedType = button.tag;
        }
    }
    switch (selectedType) {
        case OTTypesBareHands:
            self.currentTourType = NSLocalizedString(@"tour_type_bare_hands", @"");
            break;
        case OTTypesMedical:
            self.currentTourType = NSLocalizedString(@"tour_type_medical", @"");
            break;
        case OTTypesAlimentary:
            self.currentTourType = NSLocalizedString(@"tour_type_alimentary", @"");
            break;
    }
    return self.currentTourType;
}

/**************************************************************************************************/
#pragma mark - Tours Table View Delegate

- (void)showTourInfo:(OTTour*)tour {
    self.selectedTour = tour;
    
    if ([self.selectedTour.joinStatus isEqualToString:@"accepted"]) {
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

- (void)doJoinRequest:(OTTour*)tour {
    self.selectedTour = tour;
    
    if ([tour.joinStatus isEqualToString:@"not_requested"])
    {
        [self performSegueWithIdentifier:@"OTTourJoinRequestSegue" sender:nil];
    }
    else  if ([tour.joinStatus isEqualToString:@"pending"])
    {
        [self performSegueWithIdentifier:@"OTPublicTourSegue" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"QuitTourSegue" sender:self];
    }
}

/**************************************************************************************************/
#pragma mark - Segmented control
- (IBAction)changedSegmentedControlValue:(UISegmentedControl *)sender {
    [self.blurEffect setHidden:NO];
    
    if (sender.selectedSegmentIndex == 1) {
        [self showToursList];
    }
}

/**************************************************************************************************/
#pragma mark - "Screens"

- (void)showToursList {
    [self.blurEffect setHidden:YES];
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;

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
    [self.blurEffect setHidden:YES];
    self.launcherButton.hidden = !self.createEncounterButton.hidden;

    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f;
    [self.mapSegmentedControl setSelectedSegmentIndex:0];
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        self.mapSegmentedControl.hidden = NO;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];

    }];

}

#pragma mark 6.3 Tours long press on map
- (void)showMapOverlayToCreateTourAtPoint:(CGPoint)point {
    [self.blurEffect setHidden:NO];
    self.launcherButton.hidden = YES;
    self.createTourLabel.hidden = YES;
    self.createTourOnBlurButton.center = point;
}

#pragma mark 6.4 Tours "+" press
- (void)showMapOverlayToCreateTour {
    [self.blurEffect setHidden:NO];
    self.launcherButton.hidden = NO;
    self.createTourLabel.hidden = NO;
    [self.createTourOnBlurButton setNeedsLayout];
    CGPoint center = CGPointMake(self.launcherButton.center.x, self.createTourLabel.center.y);
    self.createTourOnBlurButton.center = center;
    [self.createTourOnBlurButton setNeedsDisplay];
}


#pragma mark 15.1 New Tour - start
- (void)showNewTourStart {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f - self.launcherView.frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.mapSegmentedControl.hidden = YES;
        self.launcherButton.hidden = YES;
        self.launcherView.hidden = NO;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];

    }];

}

#pragma mark 15.2 New Tour - on going
- (void)showNewTourOnGoing {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f;
    
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.mapSegmentedControl.hidden = NO;
        self.launcherButton.hidden = YES;
        self.launcherView.hidden = YES;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
    
}





@end
