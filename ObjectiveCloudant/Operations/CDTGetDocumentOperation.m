//
//  CDTGetDocumentOperation.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//  Copyright (c) 2015 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CDTGetDocumentOperation.h"
#import "CDTCouchOperation+internal.h"
#import "CDTOperationRequestBuilder.h"

@implementation CDTGetDocumentOperation

- (BOOL)buildAndValidate
{
    if ([super buildAndValidate]) {
        if (self.docId) {
            NSMutableArray *queryItems = [NSMutableArray array];
            [queryItems
                addObject:[NSURLQueryItem queryItemWithName:@"revs"
                                                      value:(self.revs ? @"true" : @"false")]];
            if (self.revId) {
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"rev" value:self.revId]];
            }
            self.queryItems = [queryItems copy];
            return YES;
        }
    }

    return NO;
}

- (NSString *)httpPath
{
    return [NSString stringWithFormat:@"/%@/%@", self.databaseName, self.docId];
}

- (NSString *)httpMethod { return @"GET"; }

#pragma mark Instance methods

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.getDocumentCompletionBlock) {
        self.getDocumentCompletionBlock(nil, error);
    }
}

- (void)dispatchAsyncHttpRequest
{
    CDTOperationRequestBuilder *b = [[CDTOperationRequestBuilder alloc] initWithOperation:self];
    NSURLRequest *request = [b buildRequest];

    __weak CDTGetDocumentOperation *weakSelf = self;
    self.task =
        [self.session dataTaskWithRequest:request
                        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable res,
                                            NSError *_Nullable error) {
                          CDTGetDocumentOperation *self = weakSelf;
                          if (!self || !self.getDocumentCompletionBlock) {
                              return;
                          }
                          if ([self isCancelled]) {
                              [self completeOperation];
                              return;
                          }

                          NSDictionary *result = nil;

                          if (data && ((NSHTTPURLResponse *)res).statusCode == 200) {
                              // We know this will be a dict on 200 response
                              result = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                                       options:0
                                                                                         error:nil];
                              self.getDocumentCompletionBlock(result, error);

                          } else {
                              NSString *json = [[NSString alloc] initWithData:data
                                                                     encoding:NSUTF8StringEncoding];
                              NSString *msg = [NSString
                                  stringWithFormat:@"Get document failed with %ld %@.",
                                                   (long)((NSHTTPURLResponse *)res).statusCode,
                                                   json];
                              NSDictionary *userInfo =
                                  @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                              NSError *error = [NSError
                                  errorWithDomain:CDTObjectiveCloudantErrorDomain
                                             code:CDTObjectiveCloudantErrorGetDocumentFailed
                                         userInfo:userInfo];
                              self.getDocumentCompletionBlock(nil, error);
                          }

                          [self completeOperation];
                        }];
    [self.task resume];
}

@end
