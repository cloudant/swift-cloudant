//
//  Database.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 15/08/2015.
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

@class CouchDB;
@class CDTGetDocumentOperation;
@class CDTCouchDatabaseOperation;

@interface Database : NSObject

/**
 Initialises a new database object with a CouchDB client and database name.
 */
- (nullable instancetype)initWithClient:(nonnull CouchDB *)client
                           databaseName:(nonnull NSString *)name;

/**
 Add an operation to be executed within the context of this database object.

 Internally this sets the database URL and access credentials based on the
 database this object represents and the client it uses to access the remote
 database.
 */
- (void)addOperation:(nonnull CDTCouchDatabaseOperation *)operation;

/**
 Synchronously access a document in this database.
 */
- (nullable NSDictionary *)objectForKeyedSubscript:(nonnull NSString *)key;

/**
 Convenience method for retrieving the latest version of a document.

 Use a CDTGetDocumentOperation for greater control.
 */
- (void)getDocumentWithId:(nonnull NSString *)documentId
        completionHandler:(void (^_Nonnull)(NSDictionary *_Nullable document,
                                            NSError *_Nullable error))completionHandler;

@end
