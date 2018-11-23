//
//  BMWMacro.h
//  MiaoWan
//
//  Created by Zhiyang Fu on 11/3/15.
//  Copyright © 2015 4c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  dispatch_after的简易版本
 */
FOUNDATION_EXTERN void dispatch_delay_main_nsec(uint64_t nsec, dispatch_block_t block);
FOUNDATION_EXTERN void dispatch_delay_main(NSTimeInterval seconds, dispatch_block_t block);
FOUNDATION_EXTERN void dispatch_delay(NSTimeInterval seconds, dispatch_queue_t queue, dispatch_block_t block);
FOUNDATION_EXTERN void dispatch_main_async(dispatch_block_t block);
FOUNDATION_EXTERN void dispatch_main_sync_safe(dispatch_block_t block);
