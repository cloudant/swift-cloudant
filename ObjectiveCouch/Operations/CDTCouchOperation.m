//
//  CDTCouchOperation.m
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

#import "CDTCouchOperation.h"

@implementation CDTCouchOperation

#pragma mark Sub-class overrides

- (void)buildAndValidate { return; }

- (void)main { [self buildAndValidate]; }

#pragma mark HTTP methods

- (void)executeJSONRequestWithMethod:(NSString *)method
                                path:(NSString *)path
                   completionHandler:(void (^)(NSObject *result, NSURLResponse *res,
                                               NSError *error))completionHandler
{
    [self executeRequestWithMethod:method
                              path:path
                 completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                     if (err) {
                         completionHandler(nil, res, err);
                     } else {
                         NSObject *result =
                             [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                         completionHandler(result, res, nil);
                     }
                 }];
}

- (void)executeRequestWithMethod:(NSString *)method
                            path:(NSString *)path
               completionHandler:(void (^)(NSData *result, NSURLResponse *res,
                                           NSError *error))completionHandler
{
    NSURLComponents *components =
        [NSURLComponents componentsWithURL:self.rootURL resolvingAgainstBaseURL:NO];

    components.path = path;
    components.queryItems = components.queryItems ? components.queryItems : @[];
    components.queryItems = [components.queryItems arrayByAddingObjectsFromArray:self.queryItems];

    NSLog(@"%@", [[components URL] absoluteString]);

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[components URL]
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:10.0];

    [request setHTTPMethod:method];

    NSURLSessionDataTask *task =
        [self.session dataTaskWithRequest:request
                        completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                            completionHandler(data, res, err);
                        }];
    [task resume];
}

@end
