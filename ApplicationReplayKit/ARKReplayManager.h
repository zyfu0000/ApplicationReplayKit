//
//  ARKReplayManager.h
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/12/9.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARKReplayManager : NSObject

+ (instancetype)instance;

- (id)REPLAY_BLOCK:(id)x;
- (void)replayEvents;
- (void)startRecord;
- (void)stopRecord;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isReplaying;

@end

#define BLOCK_CALL_ASSERT(x) ({                 \
[[ARKReplayManager instance] REPLAY_BLOCK:x]; \
})
