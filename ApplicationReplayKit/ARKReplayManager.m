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
#import <mach/mach_time.h>
#import "PTFakeTouch.h"

static NSInteger g_seq = 0;
@interface ARKReplayEvent: NSObject
@property (nonatomic, assign) NSInteger seq;
@end
@implementation ARKReplayEvent
- (instancetype)init
{
    self = [super init];
    
    self.seq = g_seq++;
    
    return self;
}
@end

@interface ARKReplayTouchEvent: ARKReplayEvent
@property (nonatomic, assign) CGPoint pointInWindow;
@property (nonatomic, assign) uint64_t timestamp;
@property (nonatomic, assign) uint64_t delayTime;
@property (nonatomic, assign) UITouchPhase phase;
@end
@implementation ARKReplayTouchEvent
@end

@interface ARKReplayMethodEvent: ARKReplayEvent
@property (nonatomic, strong) id result;
@end
@implementation ARKReplayMethodEvent
@end

@interface ARKReplayBlockEvent: ARKReplayEvent
@property (nonatomic, copy) NSArray *parameters;
@property (nonatomic, strong) id result;
@end
@implementation ARKReplayBlockEvent
@end

@interface ARKReplayManager ()

@property (nonatomic, strong) NSMutableArray<ARKReplayTouchEvent *> *touchEvents;
@property (nonatomic, strong) NSMutableArray<ARKReplayMethodEvent *> *methodEvents;
@property (nonatomic, strong) NSMutableArray<ARKReplayBlockEvent *> *blockEvents;

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
    
    _touchEvents = [NSMutableArray array];
    _methodEvents = [NSMutableArray array];
    _blockEvents = [NSMutableArray array];
    
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
    
    
    [self REPLAY_METHOD:[ARKDataSource instance] selector:@selector(numbers)];
    [self REPLAY_TOUCH];
    
    return self;
}

- (void)startRecord
{
    [self.touchEvents removeAllObjects];
    [self.methodEvents removeAllObjects];
    [self.blockEvents removeAllObjects];
    self.isRecording = YES;
    self.isReplaying = NO;
}

- (void)stopRecord
{
    self.isRecording = NO;
}

- (void)replayEvents
{
    self.isReplaying = YES;
    
    NSMutableArray *toDeleteEvents = [NSMutableArray array];
    NSInteger lastTouchEventIndex = 0;
    NSInteger pointId = [PTFakeMetaTouch getAvailablePointId];
    for (NSInteger i = 0; i < self.touchEvents.count; ++i) {
        ARKReplayTouchEvent *touchEvent = self.touchEvents[i];
        [PTFakeMetaTouch fakeTouchId:pointId
                             AtPoint:touchEvent.pointInWindow
                      withTouchPhase:touchEvent.phase
                           timestamp:touchEvent.timestamp];
        [toDeleteEvents addObject:touchEvent];
        if (touchEvent.phase == UITouchPhaseEnded) {
            lastTouchEventIndex = i;
            break;
        }
    }
    
    if (lastTouchEventIndex < (self.touchEvents.count - 1)) { // 还有touch可以重放
        uint64_t time1 = self.touchEvents[lastTouchEventIndex].timestamp;
        uint64_t time2 = self.touchEvents[lastTouchEventIndex + 1].timestamp;
        
        [self.touchEvents removeObjectsInArray:toDeleteEvents];
        dispatch_delay_main_nsec((time2 - time1), ^{
            [self replayEvents];
        });
    }
}

- (void)REPLAY_TOUCH
{
    @weakify(self);
    IIFish *fish1 = [IIFish post:[UIApplication sharedApplication] selector:@selector(sendEvent:)];
    IIFish *fish2 =
    [IIFish
     observer:self
     callBack:^(IIFishCallBack *callBack, id deadFish) {
         @strongify(self);
         
         UIEvent *event = (UIEvent *)callBack.args[0];
         if (self.isRecording) {
             UITouch *touch = event.allTouches.anyObject;
             
             ARKReplayTouchEvent *touchEvent = [ARKReplayTouchEvent new];
             touchEvent.pointInWindow = [touch locationInView:touch.window];
             if (touch.phase == UITouchPhaseBegan) {
                 touchEvent.timestamp = mach_absolute_time();
             }
             else {
                 touchEvent.timestamp = mach_absolute_time();
             }
             touchEvent.phase = touch.phase;
             
             [self.touchEvents addObject:touchEvent];
             
             [callBack.originalInvocation invoke];
         }
         else {
             [callBack.originalInvocation invoke];
         }
     }];
    [IIFishBind bindFishes:@[fish1, fish2]];
}

- (void)REPLAY_METHOD:(id)target selector:(SEL)selector
{
    @weakify(self);
    IIFish *fish1 = [IIFish post:target selector:selector];
    IIFish *fish2 =
    [IIFish
     observer:self
     callBack:^(IIFishCallBack *callBack, id deadFish) {
         @strongify(self);
         
         if (self.isRecording) {
             ARKReplayMethodEvent *event = [ARKReplayMethodEvent new];
             event.result = callBack.resule;
             @synchronized(self) {
                 [self.methodEvents addObject:event];
             }
             
             [callBack.originalInvocation invoke];
         }
         else if (self.isReplaying) {
             ARKReplayMethodEvent *event = [self.methodEvents firstObject];
             @synchronized(self) {
                 [self.methodEvents removeObject:event];
             }
             id result = event.result;
             if (result) {
                 [callBack.originalInvocation setReturnValue:&result];
             }
             [callBack.originalInvocation invoke];
         }
     }];
    [IIFishBind bindFishes:@[fish1, fish2]];
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
         
         if (self.isRecording) {
             ARKReplayBlockEvent *event = [ARKReplayBlockEvent new];
             event.parameters = callBack.args;
             event.result = callBack.resule;
             @synchronized(self) {
                 [self.blockEvents addObject:event];
             }
             
             [callBack.originalInvocation invoke];
         }
         else if (self.isReplaying) {
             ARKReplayBlockEvent *event = [self.blockEvents firstObject];
             @synchronized(self) {
                 [self.blockEvents removeObject:event];
             }
             NSArray *parameters = event.parameters;
             id result = event.result;
             
             for (NSInteger i = 0; i < parameters.count; ++i) {
                 id value = parameters[i];
                 [callBack.originalInvocation
                  setArgument:&value
                  atIndex:i+1];
             }
             if (result) {
                 [callBack.originalInvocation setReturnValue:&result];
             }
             [callBack.originalInvocation invoke];
         }
     }];
    [IIFishBind bindFishes:@[fish1, fish2]];
    
    return x;
}

@end
