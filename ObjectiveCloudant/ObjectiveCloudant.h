//
//  ObjectiveCloudant.h
//  ObjectiveCloudant
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

#import <UIKit/UIKit.h>

//! Project version number for ObjectiveCloudant.
FOUNDATION_EXPORT double ObjectiveCloudantVersionNumber;

//! Project version string for ObjectiveCouch.
FOUNDATION_EXPORT const unsigned char ObjectiveCloudantVersionString[];

/**
 * The types of index that can be used with
 * Cloudant Query.
 */
typedef NS_ENUM(NSUInteger, CDTQueryIndexType) {
    /**
        JSON index type.
     */
    CDTQueryIndexTypeJson,

    /**
        Text index type.
     */
    CDTQueryIndexTypeText
};

// In this header, you should import all the public headers of your framework
// using statements like #import <ObjectiveCloudant/PublicHeader.h>

#import <ObjectiveCloudant/CDTCouchDBClient.h>
#import <ObjectiveCloudant/CDTDatabase.h>
#import <ObjectiveCloudant/CDTCouchOperation.h>
#import <ObjectiveCloudant/CDTCouchDatabaseOperation.h>
#import <ObjectiveCloudant/CDTGetDocumentOperation.h>
#import <ObjectiveCloudant/CDTPutDocumentOperation.h>
#import <ObjectiveCloudant/CDTCreateDatabaseOperation.h>
#import <ObjectiveCloudant/CDTDeleteDatabaseOperation.h>
#import <ObjectiveCloudant/CDTHTTPInterceptor.h>
#import <ObjectiveCloudant/CDTHTTPInterceptorContext.h>
#import <ObjectiveCloudant/CDTInterceptableSession.h>
#import <ObjectiveCloudant/CDTSessionCookieInterceptor.h>
#import <ObjectiveCloudant/CDTDeleteDocumentOperation.h>
#import <ObjectiveCloudant/CDTCreateQueryIndexOperation.h>
#import <ObjectiveCloudant/CDTDeleteQueryIndexOperation.h>
#import <ObjectiveCloudant/CDTQueryFindDocumentsOperation.h>
