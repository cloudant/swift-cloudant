//
//  CDTGetDocumentOperation.m
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
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

@implementation CDTGetDocumentOperation

- (void)buildAndValidate
{
    [super buildAndValidate];

    self.queryItems =
        @[ [NSURLQueryItem queryItemWithName:@"revs" value:(self.revs ? @"true" : @"false")] ];
}

#pragma mark Instance methods

- (void)dispatchAsyncHttpRequest
{
    NSString *path = [NSString stringWithFormat:@"/%@/%@", self.databaseName, self.docId];

    __weak CDTGetDocumentOperation *weakSelf = self;
    [self executeJSONRequestWithMethod:@"GET"
                                  path:path
                     completionHandler:^(NSObject *json, NSURLResponse *res, NSError *err) {
                         CDTGetDocumentOperation *self = weakSelf;
                         NSDictionary *result = nil;

                         if (!err && json) {
                             NSHTTPURLResponse *http = (NSHTTPURLResponse *)res;
                             if (http.statusCode == 200) {
                                 // We know this will be a dict on 200 response
                                 result = (NSDictionary *)json;
                             }
                         }

                         if (self && self.getDocumentCompletionBlock) {
                             self.getDocumentCompletionBlock(result, err);
                         }

                         [self completeOperation];
                     }];
}

@end
