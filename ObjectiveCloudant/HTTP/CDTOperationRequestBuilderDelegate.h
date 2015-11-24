//
//  CDTOperationRequestBuilderDelegate.h
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 24/11/2015.
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

#import <Foundation/Foundation.h>

/**
 Contains the methods required for using an NSOperation with CDTOperationRequestBuilder.
 */
@protocol CDTOperationRequestBuilderDelegate

/**
 Base URL for this operation.
 */
- (NSURL *)rootURL;

/**
 URL path for this operation.
 */
- (NSString *)httpPath;

/**
 HTTP method for this operation.
 */
- (NSString *)httpMethod;

@optional

/**
 Query items for this operation.
 */
- (NSArray<NSURLQueryItem *> *)queryItems;

/**
 Request body for this operation; return `nil` if no body (e.g., for GET).
 */
- (NSData *)httpRequestBody;

@end
