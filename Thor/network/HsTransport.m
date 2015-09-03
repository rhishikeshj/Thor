//
//  HsTransport.m
//  Thor
//
//  Created by Rhishikesh Joshi on 01/09/15.
//  Copyright (c) 2015 Helpshift Inc. All rights reserved.
//

#import "HsTransport.h"

@interface HsTransport ()
@property (strong, nonatomic) NSURLSession *session;
@end

@implementation HsTransport

- (id) init {
    self = [super init];
    if (self) {
        self.session = [HsTransport sessionForForegroundRequests];
    }
    return self;
}

- (void) uploadRequestTo:(NSURL *)urlRequest
                withData:(NSData *) data
      andCompletionBlock:(HsHttpTaskCompletionBlock)completionHandler {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    NSURLSessionUploadTask *uploadTask = [_session uploadTaskWithRequest:request fromData:data completionHandler:completionHandler];
    [uploadTask resume];
}

- (NSURLSessionDownloadTask *) downloadTaskFromRequest:(NSURL *) urlRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:request];
    return downloadTask;
}

- (void) downloadRequestFrom:(NSURL *)urlRequest withCompletionBlock:(HsHttpTaskCompletionBlock)completionHandler {
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskFromRequest:urlRequest];
    [downloadTask resume];
}


#pragma mark Session factory

+ (NSURLSessionConfiguration *) configureSessionConfig:(NSURLSessionConfiguration *)inputConfig {
    NSURLSessionConfiguration *outputConfig = [inputConfig copy];

    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];

    [headers setObject:@"application/json; charset=utf-8" forKey:@"Content-Type"];
    [headers setObject:@"application/json" forKey:@"Accept-Encoding"];
    [headers setObject:@"Bond" forKey:@"X-HS-V"];

    outputConfig.HTTPMaximumConnectionsPerHost = 3;
    [outputConfig setHTTPAdditionalHeaders:headers];
    [outputConfig setTimeoutIntervalForRequest:30];
    [outputConfig setTimeoutIntervalForResource:30];

    return outputConfig;
}

+ (NSURLSession *) sessionForForegroundRequests {
    NSURLSessionConfiguration *config = [self configureSessionConfig:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];

    return session;
}

@end
