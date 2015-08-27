//
//  CDTGetDocumentOperation.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "CDTCouchDatabaseOperation.h"

@interface CDTGetDocumentOperation : CDTCouchDatabaseOperation

@property (nonatomic) bool revs;

/**
 The document that this operation will access or modify.
 
 Must be set before a call can be successfully made.
 */
@property (nonatomic, strong) NSString *docId;

@property(nonatomic, copy) void (^getDocumentCompletionBlock)( NSDictionary *document, NSError *operationError);

@end
