//
//  CDTCouchOperation.h
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

#import <Foundation/Foundation.h>

/**
 Base class for operations accessing Cloudant HTTP endpoints.

 Centralises the HTTP connections made to Cloudant.
 */
@interface CDTCouchOperation : NSOperation

/**
 An opportunity for subclasses to add items to headers, query string, POST body etc.
 */
- (void)buildAndValidate;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSArray /* NSURLQueryItem * */ *queryItems;

/**
 Root URL for the CouchDB instance.

 Must be set before a call can be successfully made.
 */
@property (nonatomic, strong) NSURL *rootURL;

/**
 Session used for HTTP requests.

 Must be set before a call can be successfully made.
 */
@property (nonatomic, strong) NSURLSession *session;

- (void)executeJSONRequestWithMethod:(NSString *)method
                                path:(NSString *)path
                   completionHandler:(void (^)(NSObject *result, NSURLResponse *res,
                                               NSError *error))completionHandler;

@end
