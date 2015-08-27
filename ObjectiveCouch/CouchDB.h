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
 Root URL for the CouchDB instance.
 */
@property (nonatomic,strong) NSURL *rootURL;

/**
 Create a client for a given CouchDB instance using username and password.
 
 @param url Root URL for CouchDB instance.
 @param username Username to use. May be `nil`.
 @param password Password to use. May be `nil`.
 */
+ (CouchDB*)clientForURL:(NSURL*)url 
                 username:(NSString*)username 
                 password:(NSString*)password;

- (Database*)objectForKeyedSubscript:(NSString*)key;

/**
 Adds necessary information to the request to allow it to connect to the
 server represented by this client:
 - NSURLSession to use.
 - rootURL
 - username/password
 - (interceptors?)
 */
- (void)prepareOperation:(CDTCouchOperation*)operation;

@end
