//
//  CDTCouchOperation.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
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

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *password;

@property (nonatomic,strong) NSArray/* NSURLQueryItem * */ *queryItems;

/**
 Root URL for the CouchDB instance.
 
 Must be set before a call can be successfully made.
 */
@property (nonatomic,strong) NSURL *rootURL;

/**
 Session used for HTTP requests.
 
 Must be set before a call can be successfully made.
 */
@property (nonatomic,strong) NSURLSession *session;


- (void)executeJSONRequestWithMethod:(NSString*)method
                                path:(NSString*)path
                   completionHandler:(void (^)(NSObject *result, NSURLResponse *res, NSError *error))completionHandler;

@end
