//
//  Header.h
//  CYMINI
//
//  Created by Tedzhou on 2017/1/16.
//  Copyright © 2017年 4c. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define CrashFreeAssertInDebug YES
//#define CrashFreeAssertInDebug NO
#else
#define CrashFreeAssertInDebug NO
#endif

static inline void CrashFreeAssert(BOOL condition, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString * s = [NSString stringWithFormat:@"%@", str];
    
    if (!(condition)) {
//        LOGSYS_OC(ELogLevel_Error, @"%@", s);
        
        NSArray *stacks = [NSThread callStackSymbols];
        NSMutableString *errorString = [NSMutableString string];
        [stacks enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [errorString appendFormat:@"%@\n", obj];
        }];
    }
    if (CrashFreeAssertInDebug) {
        NSCAssert(condition, str);
    }
}

//#define CrashFreeAssert(condition, ...)                 \
//if (!(condition)) {                                     \
//    LOGSYS_OC(ELogLevel_Error, __VA_ARGS__);            \
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];        \
//    [dateFormatter setDateFormat:@"MM-dd hh:mm"];                           \
//    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];    \
//    NSArray *stacks = [NSThread callStackSymbols];                          \
//    NSMutableString *errorString = [NSMutableString string];                \
//    [stacks enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {  \
//        [errorString appendFormat:@"%@\n", obj];                            \
//    }];                                                                     \
//    [FCKEventReporter trackError:BMWFormatString(@"crash_%@_%@\n%@", dateString, getLoginUid(), errorString) \
//             appkey:[MTAConfig getInstance].appkey                          \
//         isRealTime:YES];                                                   \
//}                                                       \
//if (CrashFreeAssertInDebug) {                           \
//    NSAssert(condition, __VA_ARGS__);                   \
//}                                                       \

#endif /* Header_h */
