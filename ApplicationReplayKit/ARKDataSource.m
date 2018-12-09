//
//  ARKDataSource.m
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/12/9.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import "ARKDataSource.h"

@interface ARKDataSource ()

@property (nonatomic, assign) NSInteger count;

@end

@implementation ARKDataSource

+ (instancetype)instance
{
    static ARKDataSource *datasource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        datasource = [ARKDataSource new];
    });
    
    return datasource;
}

- (NSArray *)numbers
{
    if (++self.count % 2 == 0) {
        return @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15];
    }
    else {
        return @[@15,@14,@13,@12,@11,@10,@9,@8,@7,@6,@5,@4,@3,@2,@1];
    }
}

@end
