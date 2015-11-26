//
//  CDTPutDocumentOperation.m
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

#import "CDTPutDocumentOperation.h"
#import "CDTCouchOperation+internal.h"
#import "CDTOperationRequestBuilder.h"

@implementation CDTPutDocumentOperation

- (BOOL)buildAndValidate
{
    if ([super buildAndValidate]) {
        if (self.docId && self.body && [NSJSONSerialization isValidJSONObject:self.body]) {
            NSMutableArray *tmp = [NSMutableArray array];

            if (self.revId) {
                [tmp addObject:[NSURLQueryItem queryItemWithName:@"rev" value:self.revId]];
            }

            self.queryItems = [NSArray arrayWithArray:tmp];

            return YES;
        }
    }
    return NO;
}

- (NSString *)httpPath
{
    return [NSString stringWithFormat:@"/%@/%@", self.databaseName, self.docId];
}

- (NSString *)httpMethod { return @"PUT"; }

- (NSData *)httpRequestBody
{
    return [NSJSONSerialization dataWithJSONObject:self.body options:0 error:nil];
}

#pragma mark Instance methods

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.putDocumentCompletionBlock) {
        self.putDocumentCompletionBlock(nil, nil, kCDTNoHTTPStatus, error);
    }
}

- (void)dispatchAsyncHttpRequest
{
    CDTOperationRequestBuilder *b = [[CDTOperationRequestBuilder alloc] initWithOperation:self];
    NSURLRequest *request = [b buildRequest];

    __weak CDTPutDocumentOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable res,
                              NSError *_Nullable error) {
            CDTPutDocumentOperation *self = weakSelf;

            if ([self isCancelled]) {
                [self completeOperation];
                return;
            }

            if (error) {
                if (self && self.putDocumentCompletionBlock) {
                    self.putDocumentCompletionBlock(nil, nil, kCDTNoHTTPStatus, error);
                }
            } else {
                NSInteger statusCode = ((NSHTTPURLResponse *)res).statusCode;
                if (statusCode == 201 || statusCode == 202) {
                    // Success
                    NSDictionary *result =
                        (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                        options:0
                                                                          error:nil];
                    if (self && self.putDocumentCompletionBlock) {
                        self.putDocumentCompletionBlock(result[@"id"], result[@"rev"], statusCode,
                                                        nil);
                    }
                } else {
                    NSString *json =
                        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString *msg =
                        [NSString stringWithFormat:@"Document create or update failed with %ld %@.",
                                                   (long)statusCode, json];
                    NSDictionary *userInfo =
                        @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                    NSError *error =
                        [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorCreateUpdateDocumentFailed
                                        userInfo:userInfo];

                    if (self && self.putDocumentCompletionBlock) {
                        self.putDocumentCompletionBlock(nil, nil, kCDTNoHTTPStatus, error);
                    }
                }
            }

            [self completeOperation];
          }];
    [self.task resume];
}
@end
