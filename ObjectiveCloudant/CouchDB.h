//
//  Cloudant.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
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

@class CDTDatabase;
@class CDTCouchOperation;

@interface CouchDB : NSObject

/**
 Create a client for a given CouchDB instance using username and password.

 @param url Root URL for CouchDB instance.
 @param username Username to use. May be `nil`.
 @param password Password to use. May be `nil`.
 */
+ (nullable CouchDB *)clientForURL:(nonnull NSURL *)url
                          username:(nullable NSString *)username
                          password:(nullable NSString *)password;

/**
 Retrieve a database object for this client.
 */
- (nullable Database *)objectForKeyedSubscript:(nonnull NSString *)key;

/**
 Add an operation to be executed within the context of this client object.

 Internally this sets the CouchDB instance root URL and access credentials
 based on the settings this client was initialised with.
 */
- (void)addOperation:(nonnull CDTCouchOperation *)operation;

@end
