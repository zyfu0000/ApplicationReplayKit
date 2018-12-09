//
//  ARKDataSource.h
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/12/9.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARKDataSource : NSObject

+ (instancetype)instance;

- (NSArray *)numbers;

- (void)asyncNumbers:(void (^)(NSArray *))completion;

@end
