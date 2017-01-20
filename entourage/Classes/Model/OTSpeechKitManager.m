//
//  OTSpeechKitManager.m
//  entourage
//
//  Created by Ciprian Habuc on 19/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSpeechKitManager.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "entourage-Swift.h"

#if DEBUG

const unsigned char SpeechKitApplicationKey[] = {0xf6, 0xe4, 0x1f, 0xb5, 0xdc, 0x49, 0xb6, 0x63, 0xd9, 0x59, 0xba, 0xf7, 0xb7, 0xe9, 0x70, 0x44, 0xad, 0x32, 0x82, 0x44, 0xd5, 0xbb, 0x14, 0xe1, 0x24, 0xcb, 0x50, 0x8e, 0xc8, 0x83, 0x79, 0xbf, 0x67, 0x98, 0x74, 0x44, 0xe1, 0x2a, 0xa7, 0xbb, 0x84, 0x61, 0xb2, 0x3b, 0x4a, 0x22, 0x80, 0xf8, 0x55, 0x02, 0x3c, 0x2a, 0xbd, 0x50, 0x0c, 0xe1, 0x1b, 0x5c, 0x70, 0xe3, 0xdf, 0xe9, 0xa2, 0x47};

#else

const unsigned char SpeechKitApplicationKey[] = {0x7f, 0x91, 0xf8, 0xff, 0x2e, 0xc2, 0xcd, 0x4a, 0x31, 0x70, 0x9f, 0x4a, 0x34, 0x5d, 0x4c, 0xc0, 0x2c, 0xc1, 0xce, 0x26, 0xda, 0xdb, 0xd7, 0x3b, 0x28, 0x9c, 0x58, 0x0c, 0xb8, 0xc7, 0x4a, 0x37, 0x58, 0x42, 0x36, 0x86, 0x04, 0x03, 0xd1, 0x35, 0x74, 0x70, 0x80, 0xa8, 0xcd, 0xcc, 0x69, 0xfa, 0x8e, 0x37, 0x20, 0x68, 0x12, 0xf7, 0xa4, 0x3a, 0x94, 0xfc, 0x47, 0x4c, 0xc3, 0x91, 0x83, 0x1c};

#endif

#define NUANCE_HOST_PORT 443

@implementation OTSpeechKitManager

+ (BOOL)setup {
    @try {
        [SpeechKit setupWithID:[ConfigurationManager shared].nuanceAppId host:[ConfigurationManager shared].nuanceHostAddress port:NUANCE_HOST_PORT useSSL:YES delegate:nil];
        return YES;
    } @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"speech_kit_initialise_error")];
        return NO;
    }
}

@end