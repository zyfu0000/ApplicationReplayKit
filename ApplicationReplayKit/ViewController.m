//
//  ViewController.m
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/11/11.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import "ViewController.h"
#import "PTFakeTouch.h"
#import <Aspects.h>
#import <extobjc.h>

@interface ARKTouch: NSObject
@property (nonatomic, assign) CGPoint pointInWindow;
@property (nonatomic, assign) NSTimeInterval timeStamp;
@property (nonatomic, assign) UITouchPhase phase;
@end
@implementation ARKTouch
@end


@interface ViewController ()  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<ARKTouch *> *touches;

@property (nonatomic, assign) BOOL endRecord;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"gg"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Replay" style:UIBarButtonItemStylePlain target:self action:@selector(replayTouch)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.touches = [NSMutableArray array];
    UIApplication *application = [UIApplication sharedApplication];
    @weakify(self);
    [application
     aspect_hookSelector:@selector(sendEvent:)
     withOptions:AspectPositionBefore
     usingBlock:^(id<AspectInfo> info, UIEvent *event) {
         @strongify(self);
         
         if (!self.endRecord) {
             NSLog(@"event: %@", event);
             
             UITouch *touch = event.allTouches.anyObject;
             ARKTouch *_touch = [ARKTouch new];
             _touch.pointInWindow = [touch locationInView:touch.window];
             _touch.timeStamp = touch.timestamp;
             _touch.phase = touch.phase;
             
             [self.touches addObject:_touch];
         }
     }
     error:nil];
}

- (void)replayTouch
{
    NSInteger pointId = [PTFakeMetaTouch getAvailablePointId];
    for (ARKTouch *touch in self.touches) {
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:touch.pointInWindow withTouchPhase:touch.phase];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gg"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.endRecord = YES;
    
    [self performSegueWithIdentifier:@"showSecondVC" sender:self];
}

@end
