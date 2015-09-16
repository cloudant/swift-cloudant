//
//  TestHelpers.h
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const REMOTE_DB_PREFIX;

@interface TestHelpers : NSObject

+ (NSString *)generateRandomString:(int)length;

@end
