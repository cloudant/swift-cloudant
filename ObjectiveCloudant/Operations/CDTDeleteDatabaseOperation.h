//
//  CDTDeleteDatabaseOperation.h
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import <ObjectiveCloudant/ObjectiveCloudant.h>

@interface CDTDeleteDatabaseOperation : CDTCouchOperation

@property (nullable, strong, nonatomic) NSString *databaseName;

@property (nonnull, nonatomic, copy) void (^deleteDatabaseCompletionBlock)
    (NSError *_Nullable operationError);

@end
