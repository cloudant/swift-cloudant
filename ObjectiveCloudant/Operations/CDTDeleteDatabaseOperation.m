//
//  CDTDeleteDatabaseOperation.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CDTDeleteDatabaseOperation.h"
#import "CDTCouchOperation+internal.h"
#import "CDTOperationRequestBuilder.h"

@implementation CDTDeleteDatabaseOperation

- (BOOL)buildAndValidate { return [super buildAndValidate]; }

#pragma mark Instance methods

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.deleteDatabaseCompletionBlock) {
        self.deleteDatabaseCompletionBlock(kCDTNoHTTPStatus, error);
    }
}

- (NSString *)httpPath { return [NSString stringWithFormat:@"/%@", self.databaseName]; }

- (NSString *)httpMethod { return @"DELETE"; }

- (void)dispatchAsyncHttpRequest
{
    CDTOperationRequestBuilder *b = [[CDTOperationRequestBuilder alloc] initWithOperation:self];
    NSURLRequest *request = [b buildRequest];

    __weak CDTDeleteDatabaseOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable res,
                              NSError *_Nullable error) {
            CDTDeleteDatabaseOperation *self = weakSelf;

            if ([self isCancelled]) {
                [self completeOperation];
                return;
            }

            if (error) {
                if (self && self.deleteDatabaseCompletionBlock) {
                    self.deleteDatabaseCompletionBlock(kCDTNoHTTPStatus, error);
                }
            } else {
                NSInteger statusCode = ((NSHTTPURLResponse *)res).statusCode;
                if (statusCode == 200) {
                    // Success
                    if (self && self.deleteDatabaseCompletionBlock) {
                        self.deleteDatabaseCompletionBlock(statusCode, nil);
                    }
                } else {
                    NSString *json =
                        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString *msg =
                        [NSString stringWithFormat:@"Database creation failed with %ld %@.",
                                                   (long)statusCode, json];
                    NSDictionary *userInfo =
                        @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                    NSError *error =
                        [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorDeleteDatabaseFailed
                                        userInfo:userInfo];
                    if (self && self.deleteDatabaseCompletionBlock) {
                        self.deleteDatabaseCompletionBlock(statusCode, error);
                    }
                }
            }

            [self completeOperation];
          }];
    [self.task resume];
}

@end
