//
//  ThorNetworkTests.m
//  Thor
//
//  Created by Rhishikesh Joshi on 05/09/15.
//  Copyright (c) 2015 Helpshift Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HsMockApiServer.h"

@interface ThorNetworkTests : XCTestCase

@end

@implementation ThorNetworkTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPostExample {
    HsMockApiServer *server = [[HsMockApiServer alloc] init];
    server.url = @"events/";
    HsTransport *transport = [[HsTransport alloc] init];
    NSDictionary *someData = @{@"ts" : [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:someData options:0 error:nil];
    [server configureForegroundPostForTimestampMismatch];
//    [server configureForegroundPostForSuccessWithData:@{@"status" : @"ok thanks bye"}];

    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/api/lib/events/"];
    [transport uploadRequestTo:url
                      withData:jsonData
            andCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSLog(@"Status code is %lu", ((NSHTTPURLResponse *)response).statusCode);
                NSLog(@"Got data as %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }];
}

@end
