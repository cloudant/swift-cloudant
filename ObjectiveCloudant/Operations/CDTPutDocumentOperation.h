//
//  CDTPutDocumentOperation.h
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <ObjectiveCloudant/ObjectiveCloudant.h>

@interface CDTPutDocumentOperation : CDTCouchDatabaseOperation

/**
 The document that this operation will modify.

 Must be set before a call can be successfully made.
 */
@property (nonatomic, strong) NSString *docId;

/**
 If updating a document, set this value to the current revision ID.
 */
@property (nonatomic, strong) NSString *revId;

/** Body of document. Must be serialisable with NSJSONSerialization */
@property (nonatomic, strong) NSObject *body;

@property (nonatomic, copy) void (^putDocumentCompletionBlock)
    (NSInteger statusCode, NSString *docId, NSString *revId, NSError *operationError);

@end
