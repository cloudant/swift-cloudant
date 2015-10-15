//
//  CDTGetDocumentOperation.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
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

#import "CDTCouchDatabaseOperation.h"

@interface CDTGetDocumentOperation : CDTCouchDatabaseOperation

/** Set to YES to return revision information (revs=true) */
@property (nonatomic) bool revs;

/**
 *  The revision at which you want the document.
 *  Optional: If ommited CouchDB will return the
 *  document it determines is the current winning revision
 */
@property (nullable, nonatomic, strong) NSString *revId;

/**
 The document that this operation will access or modify.

 Must be set before a call can be successfully made.
 */
@property (nullable, nonatomic, strong) NSString *docId;

@property (nullable, nonatomic, copy) void (^getDocumentCompletionBlock)
    (NSDictionary *_Nullable document, NSError *_Nullable operationError);

@end
