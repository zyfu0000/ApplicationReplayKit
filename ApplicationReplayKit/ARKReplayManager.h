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

@property (nonatomic, assign) BOOL isReplaying;

@end
