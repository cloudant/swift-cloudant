//
//  CDTCouchDatabaseOperation.h
//  ObjectiveCouch
//
//  Created by Michael Rhodes on 27/08/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "CDTCouchOperation.h"

/**
 Root class for operations that make requests to databases.
 */
@interface CDTCouchDatabaseOperation : CDTCouchOperation

/**
 The database that this operation will issue requests to.
 
 Must be set before a call can be successfully made.
 */
@property (nonatomic, strong) NSString *databaseName;

@end
