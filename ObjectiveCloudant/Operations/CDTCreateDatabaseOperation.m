//
//  CDTCreateDatabaseOperation.m
//  ObjectiveCloudant
//
//  Created by Michael Rhodes on 16/09/2015.
//  Copyright © 2015 Small Text. All rights reserved.
//

#import "CDTCreateDatabaseOperation.h"

@interface CDTCreateDatabaseOperation ()

@property (nullable, nonatomic, strong) CDTURLSessionTask *task;

@end

@implementation CDTCreateDatabaseOperation

- (void)buildAndValidate { [super buildAndValidate]; }

#pragma mark Instance methods

- (void)dispatchAsyncHttpRequest
{
    NSString *path = [NSString stringWithFormat:@"/%@", self.databaseName];

    NSURLComponents *components =
        [NSURLComponents componentsWithURL:self.rootURL resolvingAgainstBaseURL:NO];

    components.path = path;
    components.queryItems = components.queryItems ? components.queryItems : @[];
    components.queryItems = [components.queryItems arrayByAddingObjectsFromArray:self.queryItems];

    NSLog(@"%@", [[components URL] absoluteString]);

    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[components URL]
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:10.0];

    [request setHTTPMethod:@"PUT"];

    __weak CDTCreateDatabaseOperation *weakSelf = self;
    self.task = [self.session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable res,
                              NSError *_Nullable error) {
            CDTCreateDatabaseOperation *self = weakSelf;

            if (error) {
                if (self && self.createDatabaseCompletionBlock) {
                    self.createDatabaseCompletionBlock(0, error);
                }
            } else {
                NSInteger statusCode = ((NSHTTPURLResponse *)res).statusCode;
                if (statusCode == 201 || statusCode == 202) {
                    // Success
                    if (self && self.createDatabaseCompletionBlock) {
                        self.createDatabaseCompletionBlock(statusCode, nil);
                    }
                } else {
                    NSString *json =
                        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString *msg =
                        [NSString stringWithFormat:@"Database creation failed with %ld %@.",
                                                   statusCode, json];
                    NSDictionary *userInfo =
                        @{NSLocalizedDescriptionKey : NSLocalizedString(msg, nil)};
                    NSError *error =
                        [NSError errorWithDomain:CDTObjectiveCloudantErrorDomain
                                            code:CDTObjectiveCloudantErrorCreateDatabaseFailed
                                        userInfo:userInfo];
                    if (self && self.createDatabaseCompletionBlock) {
                        self.createDatabaseCompletionBlock(statusCode, error);
                    }
                }
            }

            [self completeOperation];
          }];
    [self.task resume];
}

@end
