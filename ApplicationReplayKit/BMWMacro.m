//
//  BMWMacro.m
//  MiaoWan
//
//  Created by Zhiyang Fu on 11/3/15.
//  Copyright © 2015 4c. All rights reserved.
//

#import "BMWMacro.h"

void dispatch_delay_main_nsec(uint64_t nsec, dispatch_block_t block)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, nsec), dispatch_get_main_queue(), block);
}

void dispatch_delay_main(NSTimeInterval seconds, dispatch_block_t block)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

void dispatch_delay(NSTimeInterval seconds, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), queue, block);
}

void dispatch_main_async(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

void dispatch_main_sync_safe(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

