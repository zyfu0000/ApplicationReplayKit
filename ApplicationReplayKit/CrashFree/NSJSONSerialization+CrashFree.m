//
//  NSJSONSerialization+CrashFree.m
//  CYMINI
//
//  Created by Tedzhou on 2017/1/11.
//  Copyright © 2017年 4c. All rights reserved.
//

#import "NSJSONSerialization+CrashFree.h"
#import "NSObject+Swizzle.h"
#import "CrashFreeAssert.h"

@implementation NSJSONSerialization (CrashFree)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleClassMethod:@selector(JSONObjectWithData:options:error:) withMethod:@selector(cf_JSONObjectWithData:options:error:)];
    });
}

+ (nullable id)cf_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error
{
    if (!data) {
        CrashFreeAssert(NO, @"[CRASH-FREE] json serialize data is nil :\n%@", [NSThread callStackSymbols]);

        return nil;
    }
    
    id obj;
    @try {
        obj = [self cf_JSONObjectWithData:data options:opt error:error];
    } @catch (NSException *exception) {
        NSLog(@"[CRASH-FREE] json serialize exception:\n%@, callstacks:\n%@", exception, [NSThread callStackSymbols]);
        obj = nil;
    } @finally {
        return obj;
    }
}

@end
