//
//  HsTransport.h
//  Thor
//
//  Created by Rhishikesh Joshi on 01/09/15.
//  Copyright (c) 2015 Helpshift Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HsHttpTaskCompletionBlock) (NSData *data, NSURLResponse *response, NSError *error);

@interface HsTransport : NSObject
- (void) uploadRequestTo:(NSURL *)urlRequest
                withData:(NSData *) data
      andCompletionBlock:(HsHttpTaskCompletionBlock)completionHandler;
- (void) downloadRequestFrom:(NSURL *)urlRequest
         withCompletionBlock:(HsHttpTaskCompletionBlock)completionHandler;
- (NSURLSessionDownloadTask *) downloadTaskFromRequest:(NSURL *) urlRequest;
+ (NSURLSession *) sessionForForegroundRequests;
@end
