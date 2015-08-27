//
//  Database.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CouchDB;
@class CDTGetDocumentOperation;
@class CDTCouchDatabaseOperation;

@interface Database : NSObject

/**
 Initialises a new database object with a CouchDB client and database name.
 */
- (instancetype)initWithClient:(CouchDB*)client databaseName:(NSString*)name;

/**
 Add an operation to be executed within the context of this database object.
 
 Internally this sets the database URL and access credentials based on the
 database this object represents and the client it uses to access the remote
 database.
 */
- (void)addOperation:(CDTCouchDatabaseOperation*)operation;

/**
 Synchronously access a document in this database.
 */
- (NSDictionary*)objectForKeyedSubscript:(NSString*)key;

/**
 Convenience method for retrieving the latest version of a document.
 
 Use a CDTGetDocumentOperation for greater control.
 */
- (void)getDocumentWithId:(NSString*)documentId completionHandler:(void (^)(NSDictionary *document, NSError *error))completionHandler;

@end
