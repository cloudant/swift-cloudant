//
//  CDTDeleteDocumentOperation.m
//  ObjectiveCloudant
//
//  Created by Rhys Short on 21/09/2015.
//
// (c) IBM Corp. 2015
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "CDTDeleteDocumentOperation.h"
#import "CDTOperationRequestBuilder.h"

@interface CDTDeleteDocumentOperation ()

@property (nullable, nonatomic, strong) CDTURLSessionTask *task;

@end

@implementation CDTDeleteDocumentOperation

- (BOOL)buildAndValidate
{
    if ([super buildAndValidate]) {
        if (self.revId && self.docId) {
            return YES;
        }
    }

    return NO;
}

- (NSArray<NSURLQueryItem *> *)queryItems
{
    return @[ [NSURLQueryItem queryItemWithName:@"rev" value:self.revId] ];
}

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.deleteDocumentCompletionBlock) {
        self.deleteDocumentCompletionBlock(kCDTNoHTTPStatus, error);
    }
}

- (NSString *)httpPath
{
    return [NSString stringWithFormat:@"/%@/%@", self.databaseName, self.docId];
}

- (NSString *)httpMethod { return @"DELETE"; }

#pragma mark Instance methods

- (void)dispatchAsyncHttpRequest
{
    CDTOperationRequestBuilder *b = [[CDTOperationRequestBuilder alloc] initWithOperation:self];
    NSURLRequest *request = [b buildRequest];

    __weak CDTDeleteDocumentOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *response, NSError *error) {
            CDTDeleteDocumentOperation *strongSelf = weakSelf;

            if ([strongSelf isCancelled]) {
                [strongSelf completeOperation];
                return;
            }

            if (strongSelf && strongSelf.deleteDocumentCompletionBlock) {
                if (error) {
                    strongSelf.deleteDocumentCompletionBlock(kCDTNoHTTPStatus, error);
                }

                NSError *error = nil;

                // pass the response back to the complete handler.
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;

                if (statusCode / 100 != 2) {
                    NSString *json =
                        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString *msg =
                        [NSString stringWithFormat:@"Document deletion failed with %ld %@.",
                                                   (long)statusCode, json];
                    NSDictionary *userInfo =
                        @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                    error = [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                                code:CDTObjectiveCloudantErrorDeleteDocumentFailed
                                            userInfo:userInfo];
                }

                strongSelf.deleteDocumentCompletionBlock(statusCode, error);
            }

            [strongSelf completeOperation];
          }];
    [self.task resume];
}

@end
