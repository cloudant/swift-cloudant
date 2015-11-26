//
//  CDTCreateDatabaseOperation.m
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

#import "CDTCreateDatabaseOperation.h"
#import "CDTCouchOperation+internal.h"
#import "CDTOperationRequestBuilder.h"

@implementation CDTCreateDatabaseOperation

- (BOOL)buildAndValidate { return [super buildAndValidate] && self.databaseName; }
- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.createDatabaseCompletionBlock) {
        self.createDatabaseCompletionBlock(0, error);
    }
}

- (NSString *)httpPath { return [NSString stringWithFormat:@"/%@", self.databaseName]; }

- (NSString *)httpMethod { return @"PUT"; }

#pragma mark Instance methods

- (void)dispatchAsyncHttpRequest
{
    CDTOperationRequestBuilder *b = [[CDTOperationRequestBuilder alloc] initWithOperation:self];
    NSURLRequest *request = [b buildRequest];

    __weak CDTCreateDatabaseOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable res,
                              NSError *_Nullable error) {
            CDTCreateDatabaseOperation *strongSelf = weakSelf;

            if ([strongSelf isCancelled]) {
                [strongSelf completeOperation];
                return;
            }

            if (error) {
                if (strongSelf && strongSelf.createDatabaseCompletionBlock) {
                    strongSelf.createDatabaseCompletionBlock(0, error);
                }
            } else {
                NSInteger statusCode = ((NSHTTPURLResponse *)res).statusCode;
                if (statusCode == 201 || statusCode == 202) {
                    // Success
                    if (strongSelf && strongSelf.createDatabaseCompletionBlock) {
                        strongSelf.createDatabaseCompletionBlock(statusCode, nil);
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
                                            code:CDTObjectiveCloudantErrorCreateDatabaseFailed
                                        userInfo:userInfo];
                    if (strongSelf && strongSelf.createDatabaseCompletionBlock) {
                        strongSelf.createDatabaseCompletionBlock(statusCode, error);
                    }
                }
            }

            [strongSelf completeOperation];
          }];
    [self.task resume];
}

@end
