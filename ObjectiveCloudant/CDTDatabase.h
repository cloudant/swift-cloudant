//
//  CDTDatabase.h
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

@class CDTCouchDBClient;
@class CDTGetDocumentOperation;
@class CDTCouchDatabaseOperation;

/**
 A object which represents a database on the remote server.

 Note: the database this object represents is assumed to be created,
 use CDTCreateDatabaseOperation to create a database if it doesn't already
 exist.
 */
@interface CDTDatabase : NSObject

/**
 Initialises a new database object with a CouchDB client and database name.

 Note that you are strongly encouraged to obtain a CDTDatabase object from
 CDTCouchDBClient as follows:

     CDTCouchDBClient *client...
     CDTDatabase *database = client["databaseName"];


 @param client The client for the CouchDB instance where this database exists.
 @param name The database name.
 */
- (nullable instancetype)initWithClient:(nonnull CDTCouchDBClient *)client
                           databaseName:(nonnull NSString *)name;

/**
 Add an operation to be executed within the context of this database object.

 Internally this sets the database URL and access credentials based on the
 database this object represents and the client it uses to access the remote
 database.

 @param operation The operation to perform.
 */
- (void)addOperation:(nonnull CDTCouchDatabaseOperation *)operation;

/**
 Synchronously retrieve the latest revision of a document.

 To retrieve a specific revision of a document, use 
 getDocumentWithId:revisionId:completionHandler:

 @param key The document id.
 */
- (nullable NSDictionary *)objectForKeyedSubscript:(nonnull NSString *)key;

/**
 Convenience method for retrieving the latest revision of a document.

 To retrieve a specific revision of a document, use 
 getDocumentWithId:revisionId:completionHandler:

 Use a CDTGetDocumentOperation for greater control.

 @param documentId The id of the document to retrieve from the database
 @param completionHandler A block of code to call when the operation has completed
 */
- (void)getDocumentWithId:(nonnull NSString *)documentId
        completionHandler:
            (void (^_Nonnull)(NSDictionary<NSString *, NSObject *> *_Nullable document,
                              NSError *_Nullable error))completionHandler;

/**
 Convenience method for retrieving a document at a specified revision.

 Use a CDTGetDocumentOperation for greater control.

 @param documentId The id of the document to retrieve from the database
 @param revId The revision of the document to retrieve
 @param completionHandler A block of code to call when the operation has completed
 */
- (void)getDocumentWithId:(nonnull NSString *)documentId
               revisionId:(nonnull NSString *)revId
        completionHandler:
            (void (^_Nonnull)(NSDictionary<NSString *, NSObject *> *_Nullable document,
                              NSError *_Nullable operationError))completionHandler;

/**
 Convenience method for deleting a document from the database

 Use a CDTDeleteDocumentOperation for greater control.

 @param documentId The id of the document to delete
 @param revId The revision of the document to delete
 @param completionHandler A block of code to call when the operation has been completed
 */
- (void)deleteDocumentWithId:(nonnull NSString *)documentId
                  revisionId:(nonnull NSString *)revId
         completetionHandler:
             (void (^_Nonnull)(NSInteger statusCode, NSError *_Nullable error))completionHandler;

/**
 Convenience method for creating a document

 Use a CDTPutDocumentOperation for greater control.

 @param documentId The id of the document to create.
 @param body The body of the document to create
 @param completionHandler A block of code to call when the operation has been completed
 */
- (void)putDocumentWithId:(nonnull NSString *)documentId
                     body:(nonnull NSDictionary<NSString *, NSObject *> *)body
        completionHandler:(void (^_Nonnull)(NSString *_Nullable docId, NSString *_Nullable revId,
                                            NSInteger statusCode,
                                            NSError *_Nullable operationError))completionHandler;
/**
 Convenience method for updating a document

 Use a CDTPutDocumentOperation for greater control.

 @param documentId The id of the document to update.
 @param revId The revision id of the document that is being update
 @param body The body of the document to update
 @param completionHandler A block of code to call when the operation has been completed
 */
- (void)putDocumentWithId:(nonnull NSString *)documentId
               revisionId:(nonnull NSString *)revId
                     body:(nonnull NSDictionary<NSString *, NSObject *> *)body
        completionHandler:(void (^_Nonnull)(NSString *_Nullable docId, NSString *_Nullable revId,
                                            NSInteger statusCode,
                                            NSError *_Nullable operationError))completionHandler;

@end
