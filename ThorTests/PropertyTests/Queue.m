//
//  Queue.m
//  Thor
//
//  Created by Rhishikesh Joshi on 04/09/15.
//  Copyright (c) 2015 Helpshift Inc. All rights reserved.
//

#import "Queue.h"

@interface Queue ()
@property (nonatomic) NSMutableArray *items;
@end

@implementation Queue

- (instancetype)init {
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
    }
    return self;
}

- (void)addObject:(id)object {
//    if (![object isEqual:@4]) {
//        [self.items addObject:object];
//    }
    [self.items addObject:object];
}

- (id)removeObject {
    id object = self.items[0];
    [self.items removeObjectAtIndex:0];
    return object;
}

@end
