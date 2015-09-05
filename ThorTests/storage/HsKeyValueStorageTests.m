//
//  HsKeyValueStorageTests.m
//  HelpshiftDemo
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HsKeyValueStorage.h"
#import "HsKeyValueBundleStorage.h"
#import "OCMock.h"

#define RUN_COUNT 10

@interface HsKeyValueBundleStorage ()
@property (strong, nonatomic) dispatch_queue_t workerQueue;

@end

@interface HsKeyValueStorageTests : XCTestCase
@property (strong, nonatomic) id mockedUserDefaults;
@end

@implementation HsKeyValueStorageTests

- (void) setUp {
    [super setUp];
    // mock the nsuserdefaults
    self.mockedUserDefaults = OCMPartialMock([NSUserDefaults standardUserDefaults]);
}

- (void) tearDown {
    [self.mockedUserDefaults stopMocking];
    [super tearDown];
}

- (void) testInitWithParams {
    dispatch_queue_t workerQueue = dispatch_queue_create("com.helpshift.test", DISPATCH_QUEUE_SERIAL);

    id<HsKeyValueStorage> storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];

    XCTAssert(((HsKeyValueBundleStorage *) storage).workerQueue == workerQueue);
}

- (void) testInitStorage {
    dispatch_queue_t workerQueue = dispatch_queue_create("com.helpshift.test", DISPATCH_QUEUE_SERIAL);

    id<HsKeyValueStorage> storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];

    OCMStub([self.mockedUserDefaults persistentDomainForName:KV_STORE]).andReturn(nil);
    [storage initStorage];
    OCMVerify([self.mockedUserDefaults setPersistentDomain:[OCMArg any] forName:KV_STORE]);
    OCMVerify([self.mockedUserDefaults synchronize]);

    [self.mockedUserDefaults stopMocking];

    NSDictionary *helpshiftData = [[NSUserDefaults standardUserDefaults] persistentDomainForName:KV_STORE];
    XCTAssert([helpshiftData objectForKey:@"domain"] != nil);

    self.mockedUserDefaults = OCMPartialMock([NSUserDefaults standardUserDefaults]);

    NSDictionary *someData = @{ @"a" : @"b", @"c" : @42 };
    OCMStub([self.mockedUserDefaults persistentDomainForName:KV_STORE]).andReturn(someData);

    storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];
    [storage initStorage];

    [[self.mockedUserDefaults reject] setPersistentDomain:[OCMArg any] forName:KV_STORE];
    [self.mockedUserDefaults stopMocking];

    [storage setObject:@"some_value" forKey:@"some_key"];

    // Check idempotency of the init call
    [storage initStorage];

    XCTAssert([[storage objectForKey:@"some_key"] isEqualToString:@"some_value"]);

}

- (void) testDestroyStorage {
    dispatch_queue_t workerQueue = dispatch_queue_create("com.helpshift.test", DISPATCH_QUEUE_SERIAL);

    id<HsKeyValueStorage> storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];
    [storage initStorage];

    NSDictionary *someData = @{ @"a" : @"b", @"c" : @42 };
    OCMStub([self.mockedUserDefaults persistentDomainForName:KV_STORE]).andReturn(someData);

    [(HsKeyValueBundleStorage *)storage destroyStorage];
    OCMVerify([self.mockedUserDefaults setPersistentDomain:nil forName:KV_STORE]);
    OCMVerify([self.mockedUserDefaults synchronize]);


    storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];

    OCMStub([self.mockedUserDefaults persistentDomainForName:KV_STORE]).andReturn(nil);

    [(HsKeyValueBundleStorage *)storage destroyStorage];
    OCMVerify([[self.mockedUserDefaults reject] setPersistentDomain:nil forName:KV_STORE]);
    OCMVerify([[self.mockedUserDefaults reject] synchronize]);
    [self.mockedUserDefaults stopMocking];

    storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];
    [storage setObject:@"some_value" forKey:@"some_key"];
    [(HsKeyValueBundleStorage *)storage destroyStorage];

    XCTAssert([storage objectForKey:@"some_key"] == nil);
}

- (void) testSetObject {
    XCTestExpectation *firstExpectation = [self expectationWithDescription:@"1st queue"];
    XCTestExpectation *secondExpectation = [self expectationWithDescription:@"2nd queue"];

    dispatch_queue_t workerQueue = dispatch_queue_create("com.helpshift.test", DISPATCH_QUEUE_SERIAL);

    id<HsKeyValueStorage> storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];
    [storage initStorage];
    dispatch_async(dispatch_queue_create("kv_test_one", NULL), ^() {
        for(int i = 0; i < RUN_COUNT; i++)
        {
            NSString *key = [NSString stringWithFormat:@"kv_one_%d", i];
            [storage setObject:key forKey:key];
            XCTAssert([[storage objectForKey:key] isEqualToString:key], @"Cant add to the kv store ?");
        }
        [firstExpectation fulfill];
    });

    dispatch_async(dispatch_queue_create("kv_test_two", NULL), ^() {
        for(int i = 0; i < RUN_COUNT; i++)
        {
            NSString *key = [NSString stringWithFormat:@"kv_one_%d", i];
            [storage setObject:key forKey:key];
            XCTAssert([[storage objectForKey:key] isEqualToString:key], @"Cant add to the kv store ?");
        }
        [secondExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20 handler:nil];

    [(HsKeyValueBundleStorage *)storage destroyStorage];

    storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];
    [storage initStorage];

    [storage setObject:nil forKey:@"som"];
    [storage setObject:nil forKey:nil];

    [storage setObject:NULL forKey:@"som"];
    [storage setObject:NULL forKey:NULL];
}

- (void) testGetObjectForKey {
    dispatch_queue_t workerQueue = dispatch_queue_create("com.helpshift.test", DISPATCH_QUEUE_SERIAL);

    id<HsKeyValueStorage> storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];

    NSDictionary *someData = @{ @"a" : @"b", @"c" : @42 };
    OCMStub([self.mockedUserDefaults persistentDomainForName:KV_STORE]).andReturn(someData);

    XCTAssert([[storage objectForKey:@"a"] isEqualToString:@"b"]);
    XCTAssert([[storage objectForKey:@"c"] isEqual:@42]);

    XCTAssert([storage objectForKey:@"non-existent"] == nil);
    XCTAssert([storage objectForKey:nil] == nil);
}

- (void) testRemoveObjectForKey {
    dispatch_queue_t workerQueue = dispatch_queue_create("com.helpshift.test", DISPATCH_QUEUE_SERIAL);

    id<HsKeyValueStorage> storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];

    NSMutableDictionary *someData = [[NSMutableDictionary alloc] init];
    [someData setObject:@"b" forKey:@"a"];
    [someData setObject:@"b1" forKey:@"a1"];
    [someData setObject:@"b2" forKey:@"a2"];
    [someData setObject:@"b3" forKey:@"a3"];
    [someData setObject:@"b4" forKey:@"a4"];
    [someData setObject:@"b5" forKey:@"a5"];
    [someData setObject:@"b6" forKey:@"a6"];
    [someData setObject:@"b7" forKey:@"a7"];
    [someData setObject:@42 forKey:@"c"];

    OCMStub([self.mockedUserDefaults persistentDomainForName:KV_STORE]).andReturn(someData);

    [someData removeObjectForKey:@"a"];
    OCMExpect([self.mockedUserDefaults setPersistentDomain:[OCMArg checkWithBlock:^BOOL (id value) {
                                                                return [value isEqual:someData];
                                                            }] forName:KV_STORE]);
    [storage removeObjectForKey:@"a"];
    OCMVerifyAll(self.mockedUserDefaults);
    OCMVerify([self.mockedUserDefaults synchronize]);

    OCMExpect([self.mockedUserDefaults setPersistentDomain:[OCMArg checkWithBlock:^BOOL (id value) {
                                                                return [value isEqual:someData];
                                                            }] forName:KV_STORE]);
    [storage removeObjectForKey:@"a8"];
    OCMVerifyAll(self.mockedUserDefaults);
    OCMVerify([self.mockedUserDefaults synchronize]);

    [someData removeObjectForKey:@"a7"];
    OCMExpect([self.mockedUserDefaults setPersistentDomain:[OCMArg checkWithBlock:^BOOL (id value) {
                                                                return [value isEqual:someData];
                                                            }] forName:KV_STORE]);
    [storage removeObjectForKey:@"a7"];
    OCMVerifyAll(self.mockedUserDefaults);
    OCMVerify([self.mockedUserDefaults synchronize]);

    [storage removeObjectForKey:nil];
    OCMVerify([[self.mockedUserDefaults reject] setPersistentDomain:[OCMArg any] forName:KV_STORE]);
    OCMVerify([[self.mockedUserDefaults reject] synchronize]);
}

- (void) testPerformance {
    dispatch_queue_t workerQueue = dispatch_queue_create("com.helpshift.test", DISPATCH_QUEUE_SERIAL);

    id<HsKeyValueStorage> storage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQueue];

    [self measureBlock:^() {
        [storage setObject:@"Rhishikesh Joshi" forKey:@"name"];
        XCTAssert([[storage objectForKey:@"name"] isEqualToString:@"Rhishikesh Joshi"]);
    }];
}
@end
