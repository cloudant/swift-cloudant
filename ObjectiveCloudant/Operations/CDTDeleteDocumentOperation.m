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

@interface CDTDeleteDocumentOperation ()

@property (nullable, nonatomic, strong) CDTURLSessionTask *task;

@end

@implementation CDTDeleteDocumentOperation

- (BOOL)buildAndValidate
{
    if ([super buildAndValidate]) {
        if (self.revId && self.docId) {
            self.queryItems = @[ [NSURLQueryItem queryItemWithName:@"rev" value:self.revId] ];
            return YES;
        }
    }

    return NO;
}

- (void)callCompletionHandlerWithError:(NSError *)error
{
    if (self && self.deleteDocumentCompletionBlock) {
        self.deleteDocumentCompletionBlock(kCDTNoHTTPStatus, error);
    }
}

#pragma mark Instance methods

- (void)dispatchAsyncHttpRequest
{
    NSString *path = [NSString stringWithFormat:@"/%@/%@", self.databaseName, self.docId];

    NSURLComponents *components =
        [NSURLComponents componentsWithURL:self.rootURL resolvingAgainstBaseURL:NO];

    components.path = path;
    components.queryItems = components.queryItems ? components.queryItems : @[];
    components.queryItems = [components.queryItems arrayByAddingObjectsFromArray:self.queryItems];

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:components.URL
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:10.0];

    [request setHTTPMethod:@"DELETE"];

    __weak CDTDeleteDocumentOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *response, NSError *error) {
            CDTDeleteDocumentOperation *strongSelf = weakSelf;

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
                                                   statusCode, json];
                    NSDictionary *userInfo =
                        @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                    error = [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                                code:CDTObjectiveCloudantErrorCreateDatabaseFailed
                                            userInfo:userInfo];
                }

                strongSelf.deleteDocumentCompletionBlock(statusCode, error);
            }

            [strongSelf completeOperation];
          }];
    [self.task resume];
}

@end
