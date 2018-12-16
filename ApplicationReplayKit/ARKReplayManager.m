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
#import "IIFishBind.h"

@interface ARKReplayManager ()

@property (nonatomic, copy) NSArray *numbers;

@property (nonatomic, strong) BHToken *token;
@property (nonatomic, copy) NSArray *parameters;

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
    
//    __weak ARKReplayManager *weakThis = self;
//    [ARKDataSource
//     swizzleInstanceMethod:@selector(numbers)
//     withReplacement:JGMethodReplacementProviderBlock {
//         return JGMethodReplacement(NSArray *, ARKDataSource *) {
//             __strong __typeof(weakThis) strongThis = weakThis;
//
//             if (!strongThis.isReplaying) {
//                 NSArray *orig = JGOriginalImplementation(NSArray *);
//                 strongThis.numbers = orig;
//                 return orig;
//             }
//             else {
//                 return strongThis.numbers;
//             }
//         };
//     }];
    
    return self;
}

- (id)REPLAY_BLOCK:(id)x
{
    @weakify(self);
    IIFish *fish1 = [IIFish postBlock:x];
    IIFish *fish2 =
    [IIFish
     observer:self
     callBack:^(IIFishCallBack *callBack, id deadFish) {
         @strongify(self);
         if (!self.isReplaying) {
             self.parameters = callBack.args;
             
             [callBack.originalInvocation invoke];
         }
         else {
             for (NSInteger i = 0; i < self.parameters.count; ++i) {
                 id value = self.parameters[i];
                 [callBack.originalInvocation
                  setArgument:&value
                  atIndex:i+1];
             }
             [callBack.originalInvocation invoke];
         }
     }];
    [IIFishBind bindFishes:@[fish1, fish2]];
    
    return x;
}

@end
