//
//  CDTSessionCookieInterceptor.m
//
//
//  Created by Rhys Short on 08/09/2015.
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

#import "CDTSessionCookieInterceptor.h"
#import "CDTInterceptableSession.h"

/** Number of seconds to wait for _session to respond. */
static const NSInteger CDTSessionCookieRequestTimeout = 600;

@interface CDTSessionCookieInterceptor ()

/** Form encoded username and password. */
@property (nonnull, strong, nonatomic) NSData *sessionRequestBody;

/** Whether it looks worthwhile for us to make the session request (no bad failures so far). */
@property (nonatomic) BOOL shouldMakeSessionRequest;

/** Current session cookie. */
@property (nullable, strong, nonatomic) NSString *cookie;

/** NSURLSession to make calls to _session using (shouldn't be same one we're intercepting). */
@property (nonnull, nonatomic, strong) CDTInterceptableSession *urlSession;

@end

@implementation CDTSessionCookieInterceptor

- (nullable instancetype)initWithUsername:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (self) {

        // The _session endpoint requires a form-encoded username/password combination.
        // We might as well set that up now.
        _sessionRequestBody =
            [[NSString stringWithFormat:@"name=%@&password=%@", username, password]
                dataUsingEncoding:NSUTF8StringEncoding];

        _shouldMakeSessionRequest = YES;
        _urlSession = [[CDTInterceptableSession alloc] init];
    }
    return self;
}

/**
 The interceptor adds a session cookie to every request, unless we've encountered an error
 retrieving a cookie that doesn't look recoverable. If we don't yet have a session cookie,
 this method handles making a request to the `_session` endpoint to retrieve one.

 @param context The context representing the current request state
 */
- (nonnull CDTHTTPInterceptorContext *)interceptRequestInContext:
    (nonnull CDTHTTPInterceptorContext *)context
{
    if (self.shouldMakeSessionRequest) {
        if (!self.cookie) {
            // We don't have a cookie -- either a new session entirely or the old one expired.
            self.cookie = [self startNewSessionAtURL:context.request.URL];
        }
        [context.request setValue:self.cookie forHTTPHeaderField:@"Cookie"];
    }

    return context;
}

/**
 We assume a 401 means that the cookie we applied at request time was rejected. Therefore
 clear it and tell the HTTP mechanism to retry the request. For all other responses, there's
 nothing for this interceptor to do.

 @param context The context representing the current request and response state
 */
- (nonnull CDTHTTPInterceptorContext *)interceptResponseInContext:
    (nonnull CDTHTTPInterceptorContext *)context
{
    if (context.response.statusCode == 401) {
        self.cookie = nil;
        context.shouldRetry = YES;
    }

    return context;
}

/**
 Handles retrieving a cookie ("logging in") for the credentials this interceptor
 was initialised with.

 If the request fails, this method will also set the `shouldMakeSessionRequest` property
 to `NO` if the error didn't look transient.

 @param url The base URL used to obtain a new session
 */
- (nullable NSString *)startNewSessionAtURL:(NSURL *)url
{
    NSURLComponents *components =
        [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    components.path = @"/_session";

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = self.sessionRequestBody;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSString *cookie = nil;
    CDTURLSessionTask *task = [self.urlSession
        dataTaskWithRequest:request
          completionHandler:^(NSData *__nullable data, NSURLResponse *__nullable response,
                              NSError *__nullable error) {

            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;

            if (httpResp && httpResp.statusCode / 100 == 2) {
                // Success! Get the cookie from the header if login succeeded.
                if (data && [self hasSessionStarted:data]) {
                    NSString *cookieHeader = httpResp.allHeaderFields[@"Set-Cookie"];
                    cookie = [cookieHeader componentsSeparatedByString:@";"][0];
                }
            } else if (!httpResp) {
                // Network failure of some kind; often transient. Try again next time.
                NSLog(@"Error making cookie response, error:%@", [error localizedDescription]);
            } else if (httpResp.statusCode / 100 == 5) {
                // Server error of some kind; often transient. Try again next time.
                NSLog(@"Failed to get cookie from the server, response code was %ld.",
                      (long)httpResp.statusCode);
            } else if (httpResp.statusCode == 401) {
                // Credentials are not valid, fail and don't retry.
                NSLog(@"Credentials are incorrect, cookie "
                      @"authentication will not be attempted "
                      @"again by this interceptor object");
                self.shouldMakeSessionRequest = NO;
            } else {
                // Most other HTTP status codes are non-transient failures; don't retry.
                NSLog(@"Failed to get cookie from the server,response code %ld. Cookie "
                      @"authentication will not be attempted again by this interceptor "
                      @"object",
                      (long)httpResp.statusCode);
                self.shouldMakeSessionRequest = NO;
            }

            dispatch_semaphore_signal(sema);

          }];
    [task resume];
    dispatch_semaphore_wait(
        sema, dispatch_time(DISPATCH_TIME_NOW, CDTSessionCookieRequestTimeout * NSEC_PER_SEC));

    return cookie;
}

/**
 Check the content of a response to make sure the reply indicates we're really logged in.

 @param data The response data returned after requesting a new session
 */
- (BOOL)hasSessionStarted:(nonnull NSData *)data
{
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    // Only check for ok:true, https://issues.apache.org/jira/browse/COUCHDB-1356
    // means we cannot check that the name returned is the one we sent.
    return [[jsonResponse objectForKey:@"ok"] boolValue];
}

@end
