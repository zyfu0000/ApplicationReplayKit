//
//  NSObject+Swizzle.m
//  venus
//
//  Created by qian alex on 15/8/3.
//  Copyright (c) 2015年 4c. All rights reserved.
//

#import "NSObject+Swizzle.h"
#import <objc/objc.h>
#import <objc/runtime.h>

@implementation NSObject (Swizzle)


+ (void)load
{
//    BeaconNetworkUtil getWifiMac
//    + (NSString *)getWifiMac
    
    Class fromCls = NSClassFromString(@"BeaconNetworkUtil");
    Class toCls = NSClassFromString(@"ApolloAccountServiceHelper");

    SEL fromSel = NSSelectorFromString(@"getWifiMac");
    SEL toSel = NSSelectorFromString(@"swizzledBeaconNetworkUtil_getWifiMac");

    [self swizzleClassMethod:fromCls originSelector:fromSel
                     toClass:toCls swizzledSelector:toSel];
}

+ (IMP)swizzleReplaceSelector:(SEL)orignalSelector withIMP:(IMP)newIMP
{
    Class c = [self class];
    Method orignalMethod = class_getInstanceMethod(c, orignalSelector);
    IMP orignalIMP = method_getImplementation(orignalMethod);
    
    BOOL didAddMethod = class_addMethod(self, orignalSelector, newIMP, method_getTypeEncoding(orignalMethod));
    if (didAddMethod)
    {
        method_setImplementation(orignalMethod, newIMP);
    }
    
    return orignalIMP;
}

+ (BOOL)swizzleMethod:(SEL)originSelector withMethod:(SEL)newSelector
{
    Method originMethod = class_getInstanceMethod(self, originSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    if (originMethod && newMethod)
    {
        if (class_addMethod(self, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        {
            class_replaceMethod(self, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }
        else
        {
            method_exchangeImplementations(originMethod, newMethod);
        }
        
        return YES;
    }
    else
    {
        NSLog(@"?????");
    }
    
    return NO;
}

+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class cls = [self class];

    Method originalMethod = class_getClassMethod(cls, origSelector);
    Method swizzledMethod = class_getClassMethod(cls, newSelector);

    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* swizzing super class method, added if not exist */
        class_replaceMethod(metacls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));

    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
- (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class cls = [self class];
    
    /* if current class not exist selector, then get super*/
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    /* add selector if not exist, implement append with method */
    if (class_addMethod(cls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* replace class instance method, added if selector not exist */
        /* for class cluster , it always add new selector here */
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));

    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(cls,
                            newSelector,
                            class_replaceMethod(cls,
                                                origSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}


+ (void)swizzle:(Class)fromClass originSelector:(SEL)originalSelector toClass:(Class)toClass swizzledSelector:(SEL)swizzledSelector
{
    Method addedMethod = class_getInstanceMethod(toClass, swizzledSelector);
    class_addMethod(fromClass, swizzledSelector, method_getImplementation(addedMethod), method_getTypeEncoding(addedMethod));
    
    Method originalMethod = class_getInstanceMethod(fromClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(fromClass, swizzledSelector);
    
    if (class_addMethod(fromClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(fromClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzleClassMethod:(Class)fromClass originSelector:(SEL)originalSelector toClass:(Class)toClass swizzledSelector:(SEL)swizzledSelector
{
    Class metacls = objc_getMetaClass(NSStringFromClass(fromClass).UTF8String);
    Method addedMethod = class_getClassMethod(toClass, swizzledSelector);
    class_addMethod(metacls, swizzledSelector, method_getImplementation(addedMethod), method_getTypeEncoding(addedMethod));
    
    Method originalMethod = class_getClassMethod(fromClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(fromClass, swizzledSelector);
    
    if (class_addMethod(metacls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(metacls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
