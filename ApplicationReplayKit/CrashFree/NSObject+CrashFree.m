//
//  NSObject+CrashFree.m
//  CYMINI
//
//  Created by Tedzhou on 2017/1/11.
//  Copyright © 2017年 4c. All rights reserved.
//

#import "NSObject+CrashFree.h"
#import "NSObject+Swizzle.h"
#import "CrashFreeAssert.h"

@implementation NSObject (CrashFree)

+ (void)swizzleForCrashFree
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(forwardInvocation:)
                 withMethod:@selector(cf_forwardInvocation:)];
        
        [self swizzleMethod:@selector(methodSignatureForSelector:)
                 withMethod:@selector(cf_methodSignatureForSelector:)];
    });
}

- (NSMethodSignature *)cf_methodSignatureForSelector:(SEL)arg1
{
    NSMethodSignature *sig;
    
    if ([self respondsToSelector:(SEL)arg1])
    {
        sig = [self cf_methodSignatureForSelector:arg1];
    }
    else
    {
        // 自己搞个 signature，否则要 crash
        // void (*defaultMethod)(id, sel)
        sig = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    
    return  sig;
}

- (void)cf_forwardInvocation:(NSInvocation *)anInvocation
{
    // 好像你要 crash 了呀
    CrashFreeAssert(NO, @"[CRASH-FREE] unrecognized selector @selector(%@) sent to %@, \n%@",
                    NSStringFromSelector(anInvocation.selector),
                    self,
                    [NSThread callStackSymbols]);

    
}
@end
