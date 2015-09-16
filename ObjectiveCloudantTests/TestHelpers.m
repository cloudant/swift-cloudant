//
//  TestHelpers.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "TestHelpers.h"

NSString *const REMOTE_DB_PREFIX = @"objective-cloudant";

@implementation TestHelpers

+ (NSString *)generateRandomString:(int)length
{
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

@end
