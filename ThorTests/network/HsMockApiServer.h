//
//  HsMockApiServer.h
//  HelpshiftDemo
//

#import <Foundation/Foundation.h>
#import "HsTransport.h"

typedef BOOL (^CheckBlock) (id value);
typedef void (^ProxyResponseBlock)(NSInvocation *);

@interface HsMockApiServer : NSObject <NSURLSessionDelegate>
@property (strong, nonatomic) NSString *url;

- (id) getRequestCheckBlockForPost;
- (id) getRequestDataCheckBlockForPost;

- (id) getRequestCheckBlockForGet;
- (void) configureForegroundGetForSuccessWithData:(id)returnData;

- (void) configureForegroundPostForSuccessWithData:(id)returnData;

- (void) configureForegroundPostForTimestampMismatch;

@end
