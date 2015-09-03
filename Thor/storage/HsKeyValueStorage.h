//
//  HsAppInfoStorage.h
//  
//

#import <Foundation/Foundation.h>

#define KV_STORE @"com.helpshift.marketing.data"

@protocol HsKeyValueStorage
- (void) initStorage;

- (void) setObject:(id)object forKey:(NSString *)key;
- (id) objectForKey:(NSString *)key;
- (void) removeObjectForKey:(NSString *)key;

@end