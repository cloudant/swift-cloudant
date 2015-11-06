//
//  CDTHTTPInterceptorContext.h
//
//
//  Created by Rhys Short on 17/08/2015.
//  Copyright (c) 2015 IBM Corp.
//
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
 The filter context represents the input or output state of a request
 or response filter
 */
@interface CDTHTTPInterceptorContext : NSObject

/**
 The HTTP request that is going to be executed.
 */
@property (nonnull, readwrite, nonatomic, strong) NSMutableURLRequest *request;

/**
 Should the request be retried.
 
 @discussion in a response filter, set this property to `YES` to tell
 the HTTP layer to retry the request, including re-running any
 interceptors.
 */
@property (nonatomic) BOOL shouldRetry;

/**
 The HTTP Response received from the server
 */
@property (nullable, readwrite, nonatomic, strong) NSHTTPURLResponse *response;

/**
 * Unavaiable, use -initWithRequest
 *
 * Calling this method from your code will result in
 * an exception being thrown.
 **/
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 * Initalizes a CDTURLSessionInterceptorContext
 *
 * @param request the request this context should represent
 **/
- (nullable instancetype)initWithRequest:(nonnull NSMutableURLRequest *)request
    NS_DESIGNATED_INITIALIZER;

@end
