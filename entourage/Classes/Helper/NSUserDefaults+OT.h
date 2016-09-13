

#import <Foundation/Foundation.h>

@class OTUser;

static NSString *const kDisclaimer   = @"kDisclaimer";
extern NSString *const kTutorialDone;

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, strong) OTUser *temporaryUser;

+ (BOOL)wasDisclaimerAccepted;

- (BOOL)isTutorialCompleted;

@end
