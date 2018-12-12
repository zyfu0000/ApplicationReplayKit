//
//  ARKReplayManager.m
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/12/9.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import "ARKReplayManager.h"
#import <libextobjc/extobjc.h>
#import <JGMethodSwizzler.h>
#import "ARKDataSource.h"
#import "BlockHook.h"

@interface ARKReplayManager ()

@property (nonatomic, copy) NSArray *numbers;

@end

@implementation ARKReplayManager

+ (instancetype)instance
{
    static ARKReplayManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ARKReplayManager new];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    
    __weak ARKReplayManager *weakThis = self;
    [ARKDataSource
     swizzleInstanceMethod:@selector(numbers)
     withReplacement:JGMethodReplacementProviderBlock {
         return JGMethodReplacement(NSArray *, ARKDataSource *) {
             __strong __typeof(weakThis) strongThis = weakThis;
             
             if (!strongThis.isReplaying) {
                 NSArray *orig = JGOriginalImplementation(NSArray *);
                 strongThis.numbers = orig;
                 return orig;
             }
             else {
                 return strongThis.numbers;
             }
         };
     }];
    
    return self;
}

- (void)REPLAY_BLOCK:(id)x
{
    
}

@end
