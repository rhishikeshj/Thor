//
//  HsKeyValueBundleStorage.m
//  
//

#import "HsKeyValueBundleStorage.h"

@interface HsKeyValueBundleStorage ()

@property (strong, nonatomic) dispatch_queue_t workerQueue;

@end

@implementation HsKeyValueBundleStorage

- (id) initWithWorkerQueue:(dispatch_queue_t)workerQueue {
    self = [super init];
    if(self) {
        self.workerQueue = workerQueue;
    }
    return self;
}

- (void) initStorage {
    dispatch_sync(self.workerQueue, ^() {
        NSMutableDictionary *helpshiftDefaults = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:KV_STORE] mutableCopy];
        if(helpshiftDefaults == nil) {
            helpshiftDefaults = [[[NSDictionary alloc] init] mutableCopy];
            [helpshiftDefaults setObject:@"helpshift" forKey:@"domain"];
            [[NSUserDefaults standardUserDefaults] setPersistentDomain:helpshiftDefaults forName:KV_STORE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

- (void) destroyStorage {
    dispatch_sync(self.workerQueue, ^() {
        NSMutableDictionary *helpshiftDefaults = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:KV_STORE] mutableCopy];

        if(helpshiftDefaults != nil) {
            [[NSUserDefaults standardUserDefaults] setPersistentDomain:nil forName:KV_STORE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

- (void) setObject:(id)object forKey:(NSString *)key {
    dispatch_sync(self.workerQueue, ^() {
        if(key && object) {
            NSMutableDictionary *helpshiftDefaults = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:KV_STORE] mutableCopy];
            [helpshiftDefaults setObject:object forKey:key];
            [[NSUserDefaults standardUserDefaults] setPersistentDomain:helpshiftDefaults forName:KV_STORE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}

- (id) objectForKey:(NSString *)key {
    __block id returnVal = nil;
    dispatch_sync(self.workerQueue, ^() {
        if(key) {
            NSDictionary *helpshiftDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:KV_STORE];
            returnVal = [helpshiftDefaults objectForKey:key];
        }
    });
    return returnVal;
}


- (void) removeObjectForKey:(NSString *)key {
    dispatch_sync(self.workerQueue, ^() {
        if(key) {
            NSMutableDictionary *helpshiftDefaults = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:KV_STORE] mutableCopy];

            [helpshiftDefaults removeObjectForKey:key];
            [[NSUserDefaults standardUserDefaults] setPersistentDomain:helpshiftDefaults forName:KV_STORE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}
@end
