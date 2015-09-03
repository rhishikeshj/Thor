//
//  HsKeyValueBundleStorage.h
//  
//

#import <Foundation/Foundation.h>
#import "HsKeyValueStorage.h"

@interface HsKeyValueBundleStorage : NSObject <HsKeyValueStorage>
- (id) init __attribute__((unavailable("Must use initWithWorkerQueue: instead")));
- (id) initWithWorkerQueue:(dispatch_queue_t)workerQueue;
- (void) destroyStorage;
@end
