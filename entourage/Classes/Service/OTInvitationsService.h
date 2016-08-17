//
//  OTInvitationsService.h
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTEntourage.h"
#import "OTEntourageInvitation.h"

@interface OTInvitationsService : NSObject

- (void)inviteNumbers:(NSArray *)phoneNumbers toEntourage:(OTEntourage *)entourage
              success:(void (^)())success
              failure:(void (^)(NSError *error, NSArray *failedNumbers))failure;

- (void)entourageGetInvitationsWithSuccess:(void (^)(NSArray *))success
                                   failure:(void (^)(NSError *))failure;

- (void)acceptInvitation:(OTEntourageInvitation *)invitation withSuccess:(void (^)())success
                                   failure:(void (^)(NSError *))failure;

@end
