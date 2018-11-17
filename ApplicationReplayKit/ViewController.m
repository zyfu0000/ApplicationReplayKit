//
//  ViewController.m
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/11/11.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import "ViewController.h"
#import <JGMethodSwizzler.h>
#import "PTFakeTouch.h"

@interface ViewController () // <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIButton *button1;

@property (nonatomic, strong) NSMutableArray<UIEvent *> *events;

@property (nonatomic, assign) BOOL endRecord;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.events = [NSMutableArray array];
    
//    UIApplication *application = [UIApplication sharedApplication];
//
//    __weak ViewController *weakThis = self;
//    [application
//     swizzleMethod:@selector(sendEvent:)
//     withReplacement:JGMethodReplacementProviderBlock {
//         return JGMethodReplacement(void, UIApplication *, UIEvent *event) {
//             __strong __typeof(weakThis) strongThis = weakThis;
//
//             if (!strongThis.endRecord) {
//                 NSLog(@"event: %@", event);
//                 [strongThis.events addObject:event];
//             }
//             else {
//                 NSLog(@"event: %@", event);
//             }
//
//            JGOriginalImplementation(void, event);
//         };
//     }];
}

- (IBAction)button1Tapped:(id)sender
{
    NSLog(@"%@", @"button1 tapped");
    
    self.endRecord = YES;
}

- (IBAction)button2Tapped:(id)sender
{
//    for (UIEvent *event in self.events) {
//        [[UIApplication sharedApplication] sendEvent:event];
//    }
    
    NSInteger pointId = [PTFakeMetaTouch getAvailablePointId];
    [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(154.66665649414062,284.66665649414062) withTouchPhase:UITouchPhaseBegan];
    [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(154.66665649414062,284.66665649414062) withTouchPhase:UITouchPhaseEnded];
}

@end
