//
//  PropertyTests.m
//  Thor
//
//  Created by Rhishikesh Joshi on 04/09/15.
//  Copyright (c) 2015 Helpshift Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Fox/Fox.h"
#import "Queue.h"

@interface PropertyTests : XCTestCase

@end

@implementation PropertyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSArray *)sortNumbers:(NSArray *)numbers {
    NSMutableArray *sortedNumbers = [[numbers sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
//    if (sortedNumbers.count >= 5) {
//        id tmp = sortedNumbers[0];
//        sortedNumbers[0] = sortedNumbers[1];
//        sortedNumbers[1] = tmp;
//    }
    return sortedNumbers;
}

- (void)testSortBySmallestNumber {
    id<FOXGenerator> arraysOfIntegers = FOXArray(FOXInteger());
    FOXAssert(FOXForAll(arraysOfIntegers, ^BOOL(NSArray *integers) {
        // subject under test
        NSArray *sortedNumbers = [self sortNumbers:integers];
        // assertion
        NSNumber *previousNumber = nil;
        for (NSNumber *n in sortedNumbers) {
            if (!previousNumber || [previousNumber integerValue] <= [n integerValue]) {
                previousNumber = n;
            } else {
                return NO; // fail
            }
        }
        return YES; // succeed
    }));
}


- (void)testQueueBehavior {
    // define the state machine with its initial state.
    FOXFiniteStateMachine *stateMachine = [[FOXFiniteStateMachine alloc] initWithInitialModelState:@[]];

    // define the state transition for -[Queue addObject:]
    // we'll only be using randomly generated integers as arguments.
    // note that nextModelState should not mutate the original model state.
    [stateMachine addTransition:[FOXTransition byCallingSelector:@selector(addObject:)
                                                   withGenerator:FOXInteger()
                                                  nextModelState:^id(id modelState, id generatedValue) {
                                                      return [modelState arrayByAddingObject:generatedValue];
                                                  }]];

    // define the state machine for -[Queue removeObject]
    FOXTransition *removeTransition = [FOXTransition byCallingSelector:@selector(removeObject)
                                                        nextModelState:^id(id modelState, id generatedValue) {
                                                            return [modelState subarrayWithRange:NSMakeRange(1, [modelState count] - 1)];
                                                        }];
    removeTransition.precondition = ^BOOL(id modelState) {
        return [modelState count] > 0;
    };
    removeTransition.postcondition = ^BOOL(id modelState, id previousModelState, id subject, id generatedValue, id returnedObject) {
        // modelState is the state machine's state after following the transition
        // previousModelState is the state machine's state before following the transition
        // subject is the subject under test. You should not provoke any mutation changes here.
        // generatedValue is the value that the removeTransition generated. We're not using this value here.
        // returnedObject is the return value of calling [subject removeObject].
        return [[previousModelState firstObject] isEqual:returnedObject];
    };
    [stateMachine addTransition:removeTransition];

    // generate and execute an arbitrary sequence of API calls
    id<FOXGenerator> executedCommands = FOXExecuteCommands(stateMachine, ^id{
        return [[Queue alloc] init];
    });
    // verify that all the executed commands properly conformed to the state machine.
    FOXAssert(FOXForAll(executedCommands, ^BOOL(NSArray *commands) {
        return FOXExecutedSuccessfully(commands);
    }));
}
@end
