//
//  CDTDeleteQueryIndexOperation.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 05/10/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CDTDeleteQueryIndexOperation.h"
#import "CDTCouchOperation+internal.h"
#import "CDTOperationRequestBuilder.h"

@implementation CDTDeleteQueryIndexOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _indexType = CDTQueryIndexTypeJson;
    }
    return self;
}

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.deleteIndexCompletionBlock) {
        self.deleteIndexCompletionBlock(kCDTNoHTTPStatus, error);
    }
}

- (BOOL)buildAndValidate
{
    if (![super buildAndValidate]) {
        return NO;
    }

    if (!self.indexName) {
        return NO;
    }
    if (!self.designDocName) {
        return NO;
    }

    return YES;
}

- (NSString *)httpPath
{
    // currently the only supported type.
    NSString *indexType = @"json";
    return [NSString stringWithFormat:@"/%@/_index/%@/%@/%@", self.databaseName, self.designDocName,
                                      indexType, self.indexName];
}

- (NSString *)httpMethod { return @"DELETE"; }

- (void)dispatchAsyncHttpRequest
{
    CDTOperationRequestBuilder *b = [[CDTOperationRequestBuilder alloc] initWithOperation:self];
    NSURLRequest *request = [b buildRequest];

    __weak CDTDeleteQueryIndexOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            CDTDeleteQueryIndexOperation *self = weakSelf;

            if (!self || !self.deleteIndexCompletionBlock || self.isCancelled) {
                [self completeOperation];
                return;
            }

            if (error) {
                self.deleteIndexCompletionBlock(kCDTNoHTTPStatus, error);
            }

            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;

            if (statusCode / 100 == 2) {
                // okay
                self.deleteIndexCompletionBlock(statusCode, nil);
            } else {
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *msg = [NSString
                    stringWithFormat:@"Index deletion failed with %ld %@.", (long)statusCode, json];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                error = [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorDeleteQueryIndexFailed
                                        userInfo:userInfo];
                self.deleteIndexCompletionBlock(statusCode, error);
            }

            [self completeOperation];
          }];
    [self.task resume];
}

@end
