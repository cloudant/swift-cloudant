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
@property (nullable, nonatomic, strong) NSString *docId;

/**
 If updating a document, set this value to the current revision ID.
 */
@property (nullable, nonatomic, strong) NSString *revId;

/** Body of document. Must be serialisable with NSJSONSerialization */
@property (nullable, nonatomic, strong) NSObject *body;

@property (nonnull, nonatomic, copy) void (^putDocumentCompletionBlock)
    (NSInteger statusCode, NSString *_Nullable docId, NSString *_Nullable revId,
     NSError *_Nullable operationError);

@end
