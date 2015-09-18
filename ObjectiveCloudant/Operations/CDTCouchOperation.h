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
#import "CDTInterceptableSession.h"

extern NSString *_Nonnull const CDTObjectiveCloudantErrorDomain;

/**
 * Replication errors.
 */
typedef NS_ENUM(NSInteger, CDTObjectiveCloudantErrors) {
    /**
     Creating a database failed.
     */
    CDTObjectiveCloudantErrorCreateDatabaseFailed,
    /**
     Deleting a database failed.
     */
    CDTObjectiveCloudantErrorDeleteDatabaseFailed
};

/**
 Base class for operations accessing Cloudant HTTP endpoints.

 Centralises the HTTP connections made to Cloudant.
 */
@interface CDTCouchOperation : NSOperation {
    BOOL executing;
    BOOL finished;
}

/// ------------------------------------------
/// @name Set up connection and server details
/// ------------------------------------------

/**
 Session used for HTTP requests.

 Must be set before a call can be successfully made.
 */
@property (nullable, nonatomic, strong) CDTInterceptableSession *session;

/**
 Root URL for the CouchDB instance.

 Must be set before a call can be successfully made.
 */
@property (nullable, nonatomic, strong) NSURL *rootURL;

/// ---------------------------------
/// @name Sub-class overrides
/// ---------------------------------

/** Extra query parameters to add to outgoing request. */
@property (nullable, nonatomic, strong) NSArray<NSURLQueryItem *> *queryItems;

/**
 An opportunity for subclasses to add items to headers, query string, POST body etc.

 Typically an operation would add to queryItems here.
 */
- (void)buildAndValidate;

/**
 Override point for sub-classes. Dispatch an async HTTP request. Call `completeOperation` when
 complete.
 */
- (void)dispatchAsyncHttpRequest;

/// ---------------------------------
/// @name Life-cycle management
/// ---------------------------------

/**
 Executes necessary NSOperation completion KVO work. MUST be called by sub-classes when complete.
 */
- (void)completeOperation;

@end
