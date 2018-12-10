//
//  IIFishBind.h
//  FishBindDemo
//
//  Created by WELCommand on 2017/9/4.
//  Copyright © 2017年 WELCommand. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IIFishCallBack : NSObject
@property (nonatomic, weak) id tager;
@property (nonatomic, copy) NSString *selector;
@property (nonatomic, strong) NSArray *args;
@property (nonatomic, assign) id resule;
@end

typedef void(^IIFishCallBackBlock) (IIFishCallBack *callBack, id deadFish);

@interface IIFish : NSObject

+ (instancetype)postBlock:(id)blockObject withBlock:(id)block;

@end




