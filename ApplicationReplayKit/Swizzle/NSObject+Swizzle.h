//
//  NSObject+Swizzle.h
//  venus
//
//  Created by qian alex on 15/8/3.
//  Copyright (c) 2015年 4c. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

+ (IMP)swizzleReplaceSelector:(SEL)orignalSelector withIMP:(IMP)newIMP;

+ (BOOL)swizzleMethod:(SEL)originSelector withMethod:(SEL)newSelector;

+ (void)swizzleClassMethod:(SEL)originSelector withMethod:(SEL)newSelector;

- (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector;

+ (void)swizzle:(Class)fromClass
 originSelector:(SEL)originalSelector
        toClass:(Class)toClass
swizzledSelector:(SEL)swizzledSelector;

+ (void)swizzleClassMethod:(Class)fromClass
            originSelector:(SEL)originalSelector
                   toClass:(Class)toClass
          swizzledSelector:(SEL)swizzledSelector;

@end
