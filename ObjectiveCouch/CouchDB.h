//
//  Cloudant.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ObjectiveCouch/Builder.h>

@class Database;
@class CDTCouchOperation;

@interface CouchDB : NSObject

/**
 Create a client for a given CouchDB instance using username and password.

 @param url Root URL for CouchDB instance.
 @param username Username to use. May be `nil`.
 @param password Password to use. May be `nil`.
 */
+ (CouchDB *)clientForURL:(NSURL *)url username:(NSString *)username password:(NSString *)password;

/**
 Retrieve a database object for this client.
 */
- (Database *)objectForKeyedSubscript:(NSString *)key;

/**
 Add an operation to be executed within the context of this client object.

 Internally this sets the CouchDB instance root URL and access credentials
 based on the settings this client was initialised with.
 */
- (void)addOperation:(CDTCouchOperation *)operation;

@end
