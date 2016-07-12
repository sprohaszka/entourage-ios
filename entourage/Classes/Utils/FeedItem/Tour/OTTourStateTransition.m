//
//  OTTourStateFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourStateTransition.h"
#import "OTTour.h"
#import "OTTourService.h"

@implementation OTTourStateTransition

- (void)stopWithSuccess:(void (^)())success {
    [[OTTourService new] closeTour:self.tour
                       withSuccess:^(OTTour *updatedTour) {
                           NSLog(@"Closed tour: %@", updatedTour.uid);
                           success();
                       } failure:^(NSError *error) {
                           NSLog(@"CLOSEerr %@", error.description);
                       }];
}

- (void)closeWithSuccess:(void (^)(BOOL))success orFailure:(void (^)(NSError*))failure {
    self.tour.status = TOUR_STATUS_FREEZED;
    [[OTTourService new] closeTour:self.tour
                       withSuccess:^(OTTour *updatedTour) {
                           NSLog(@"freezed tour: %@", updatedTour.uid);
                           success(YES);
                       } failure:^(NSError *error) {
                           NSLog(@"FREEZEerr %@", error.description);
                           if(failure)
                               failure(error);
                       }];
}

- (void)quitWithSuccess:(void (^)())success {
    [[OTTourService new] quitTour:self.tour
                          success:^() {
                              NSLog(@"Quited tour: %@", self.tour.uid);
                              success();
                          } failure:^(NSError *error) {
                              NSLog(@"QUITerr %@", error.description);
                          }];
}

- (void)sendJoinRequest:(void (^)(OTTourJoiner *))success orFailure:(void (^)(NSError *, BOOL))failure {
    [[OTTourService new] joinTour:self.tour
        success:^(OTTourJoiner *joiner) {
            NSLog(@"Sent tour join request: %@", self.tour.uid);
            success(joiner);
        } failure:^(NSError *error) {
            NSLog(@"Send tour join request error: %@", error.description);
            failure(error, YES);
        }];
}

@end
