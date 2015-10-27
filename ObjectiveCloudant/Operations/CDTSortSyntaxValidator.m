//
//  CDTSortSyntaxValidator.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 08/10/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CDTSortSyntaxValidator.h"

@implementation CDTSortSyntaxValidator

+ (BOOL)validateSortSyntaxInArray:(NSArray *)sort
{
    // check the fields are either string or 2 element dict of strings
    for (NSObject *item in sort) {
        if ([item isKindOfClass:[NSString class]]) {
            continue;
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            // must be only one key, both strings.
            NSDictionary *sort = (NSDictionary *)item;
            if (sort.count != 1) {
                return NO;
            }

            if (![sort.allKeys[0] isKindOfClass:[NSString class]]) {
                return NO;
            }

            NSString *key = sort.allKeys[0];

            if (![sort[key] isKindOfClass:[NSString class]]) {
                return NO;
            } else if (![sort[key] isEqualToString:@"asc"] &&
                       ![sort[key] isEqualToString:@"desc"]) {
                return NO;
            }

        } else {
            return NO;
        }
    }

    return YES;
}

@end
