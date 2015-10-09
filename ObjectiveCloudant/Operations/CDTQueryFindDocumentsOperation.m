//
//  CDTQueryFindDocumentsOperation.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 07/10/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CDTQueryFindDocumentsOperation.h"
#import "CDTSortSyntaxValidator.h"
#import "CDTCouchOperation+internal.h"

/**
 * Value that indicates no value is set for an integer parameter
 **/
NSInteger const kCDTDefaultOperationIntegerValue = -1;

@interface CDTQueryFindDocumentsOperation ()

@property (nullable, nonatomic, strong) NSData *jsonBody;

@end

@implementation CDTQueryFindDocumentsOperation

- (instancetype)init
{
    self = [super init];

    if (self) {
        _limit = kCDTDefaultOperationIntegerValue;
        _skip = kCDTDefaultOperationIntegerValue;
        _r = kCDTDefaultOperationIntegerValue;
    }

    return self;
}

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.findDocumentsCompletionBlock) {
        self.findDocumentsCompletionBlock(nil, error);
    }
}

- (BOOL)buildAndValidate
{
    if (![super buildAndValidate]) {
        return NO;
    }

    if (self.sort && ![CDTSortSyntaxValidator validateSortSyntaxInArray:self.sort]) {
        return NO;
    }

    // make the dict to send
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
        @"selector" : self.selector
    }];
    if (self.limit > -1) {
        body[@"limit"] = @(self.limit);
    }
    if (self.skip > -1) {
        body[@"skip"] = @(self.skip);
    }
    if (self.r > -1) {
        body[@"r"] = @(self.r);
    }
    if (self.sort) {
        body[@"sort"] = self.sort;
    }

    if (self.fields) {
        body[@"fields"] = self.fields;
    }
    if (self.bookmark) {
        body[@"bookmark"] = self.bookmark;
    }
    if (self.useIndex) {
        body[@"use_index"] = self.useIndex;
    }

    if (![NSJSONSerialization isValidJSONObject:body]) {
        return NO;
    }

    NSError *error = nil;

    self.jsonBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];

    if (!self.jsonBody) {
        return NO;
    }

    return YES;
}

- (void)dispatchAsyncHttpRequest
{
    NSString *path = [NSString stringWithFormat:@"/%@/_find", self.databaseName];

    NSURLComponents *components =
        [NSURLComponents componentsWithURL:self.rootURL resolvingAgainstBaseURL:NO];
    components.path = path;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = self.jsonBody;

    __weak CDTQueryFindDocumentsOperation *weakSelf = self;

    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            CDTQueryFindDocumentsOperation *self = weakSelf;
            if (!self || [self isCancelled]) {
                [self completeOperation];
                return;
            }

            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (error) {
                self.findDocumentsCompletionBlock(nil, error);
            } else if (statusCode / 100 == 2) {
                NSError *jsonError;
                NSDictionary *responseDict =
                    [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (!responseDict) {
                    self.findDocumentsCompletionBlock(nil, jsonError);
                } else {
                    if (self.documentFoundBlock) {
                        for (NSDictionary *doc in responseDict[@"docs"]) {
                            self.documentFoundBlock(doc);
                        }
                    }

                    if (self.findDocumentsCompletionBlock) {
                        self.findDocumentsCompletionBlock(nil, nil);
                    }
                }
            } else {
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *msg = [NSString
                    stringWithFormat:@"Find documents failed with %ld %@.", statusCode, json];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                error = [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorCreateDatabaseFailed
                                        userInfo:userInfo];
                self.findDocumentsCompletionBlock(nil, error);
            }
          }];
    [self.task resume];
}

@end
