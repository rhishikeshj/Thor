//
//  HsMockApiServer.m
//  HelpshiftDemo
//

#import "HsMockApiServer.h"
#import "OCMock.h"
#import "HsTransport.h"

@interface HsMockApiServer ()
@property (strong, nonatomic) id mockFgUrlSession;
@property (strong, nonatomic) NSString *shortUrl;
@property (strong, nonatomic) HsHttpTaskCompletionBlock someBlock;
@end

@implementation HsMockApiServer

- (instancetype) init {
    self = [super init];
    if(self) {
        self.mockFgUrlSession = OCMPartialMock([HsTransport sessionForForegroundRequests]);
    }
    return self;
}

- (void) configureForegroundGetForSuccessWithData:(id)returnData {
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:returnData options:0 error:nil];

    OCMStub([[[self.mockFgUrlSession stub]
              andDo:[self getGetResponseBlockForSuccessWithData:responseData]]
             dataTaskWithRequest:[self getRequestCheckBlockForGet]
             completionHandler:[OCMArg any]]);
}

- (void) configureForegroundPostForSuccessWithData:(id)returnData {
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:returnData options:0 error:nil];

    OCMStub([[[self.mockFgUrlSession stub] andDo:[self getPostResponseBlockForSuccessWithData:responseData]]
             uploadTaskWithRequest:[self getRequestCheckBlockForPost]
             fromData:[self getRequestDataCheckBlockForPost]
             completionHandler:[OCMArg any]]);
}


- (void) configureForegroundPostForTimestampMismatch {
    OCMStub([[[self.mockFgUrlSession stub] andDo:[self getPostResponseBlockForTimestampMismatch]]
             uploadTaskWithRequest:[self getRequestCheckBlockForPost]
             fromData:[self getRequestDataCheckBlockForPost]
             completionHandler:[OCMArg any]]);
}

- (NSDictionary *) reverseParseParamString:(NSString *)paramString {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSArray *components = [paramString componentsSeparatedByString:@"&"];

    for(NSString *string in components)
    {
        NSArray *words = [string componentsSeparatedByString:@"="];
        NSString *value = [words objectAtIndex:1];
        NSString *path = [[value stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                          stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:path forKey:[words objectAtIndex:0]];
    }
    return params;
}

- (void) verifyUrlForRequest:(NSURLRequest *)request {  // throws Url mismatch exception
    NSString *requestPath = [NSString stringWithFormat:@"%@://%@%@/", request.URL.scheme, request.URL.host, request.URL.path];

    if(![requestPath isEqualToString:self.url]) {
        @throw [NSException exceptionWithName:@"Url mismatch" reason:@"url mismatch" userInfo:nil];
    }
}

- (id) getRequestCheckBlockForPost {
    CheckBlock requestCheckBlock = ^BOOL (id value) {
        NSMutableURLRequest *request = (NSMutableURLRequest *) value;
        [self verifyUrlForRequest:request];
        return YES;
    };

    return [OCMArg checkWithBlock:requestCheckBlock];
}

- (id) getRequestCheckBlockForGet {
    CheckBlock requestCheckBlock = ^BOOL (id value) {
        NSMutableURLRequest *request = (NSMutableURLRequest *) value;
        [self verifyUrlForRequest:request];
        return YES;
    };

    return [OCMArg checkWithBlock:requestCheckBlock];
}

- (id) getRequestDataCheckBlockForPost {
    CheckBlock requestCheckBlock = ^BOOL (id value) {
        NSString *bodyString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
        NSLog(@"Body string is %@", bodyString);
        return YES;
    };

    return [OCMArg checkWithBlock:requestCheckBlock];
}

- (ProxyResponseBlock) getPostResponseBlockForSuccessWithData:(NSData *)data {
    ProxyResponseBlock postBlock = ^(NSInvocation *invocation) {
        void (^passedBlock)(NSData *data, NSURLResponse *response, NSError *error);
        [invocation getArgument:&passedBlock atIndex:4];
        NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:self.url]
                                                                     statusCode:200
                                                                    HTTPVersion:@"HTTP 1.1"
                                                                   headerFields:@{}];
        passedBlock(data, urlResponse, nil);
    };

    return postBlock;
}


- (ProxyResponseBlock) getPostResponseBlockForTimestampMismatch {
    ProxyResponseBlock postBlock = ^(NSInvocation *invocation) {
        void (^passedBlock)(NSData *data, NSURLResponse *response, NSError *error);
        [invocation getArgument:&passedBlock atIndex:4];
        NSString *timeStamp = [[NSString alloc] initWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
        NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:self.url]
                                                                     statusCode:422
                                                                    HTTPVersion:@"HTTP 1.1"
                                                                   headerFields:@{ @"HS-UEpoch" : timeStamp }];
        passedBlock(nil, urlResponse, nil);
    };

    return postBlock;
}

- (ProxyResponseBlock) getGetResponseBlockForSuccessWithData:(NSData *)returnData {
    ProxyResponseBlock getBlock = ^(NSInvocation *invocation) {
        void (^passedBlock)(NSData *data, NSURLResponse *response, NSError *error);
        [invocation getArgument:&passedBlock atIndex:3];
        passedBlock(returnData, nil, nil);
    };

    return getBlock;
}

- (void) setUrl:(NSString *)url {
    NSString *urlString = url;
    unichar firstChar = [url characterAtIndex:0];

    if(firstChar == '/') {
        urlString = [urlString substringFromIndex:1];
    }

    NSString *uri = [NSString stringWithFormat:@"/api/lib/%@", urlString];
    self->_shortUrl = uri;

    NSMutableString *finalUrlString = [[NSMutableString alloc] init];

    [finalUrlString appendString:[NSString stringWithFormat:@"%@%@%@", @"http://", @"localhost:8080", uri]];

    self->_url = finalUrlString;
}

#pragma mark NSURLSession delegates

- (void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
}

- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
}

#pragma mark UrlSession Task delegates

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
}

#pragma mark UrlSession Data delegates

- (void) URLSession:(NSURLSession *)session
           dataTask:(NSURLSessionDataTask *)dataTask
     didReceiveData:(NSData *)data {
    NSLog(@"Received response for upload : %@", data);
}

#pragma mark Download task delegates

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [[NSData alloc] initWithContentsOfURL:location];
    NSLog(@"Received data : %@", data);
}

@end
