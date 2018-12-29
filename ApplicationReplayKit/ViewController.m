//
//  ViewController.m
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/11/11.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import "ViewController.h"
#import "ARKReplayManager.h"
#import "ARKDataSource.h"

@interface ViewController ()  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *numbers;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateTitle];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"gg"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startRecord)];
    self.navigationItem.leftBarButtonItem = item;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStylePlain target:self action:@selector(stopRecord)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"Replay" style:UIBarButtonItemStylePlain target:self action:@selector(startReplay)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    
    self.numbers = [[ARKDataSource instance] numbers];
    [self.tableView reloadData];
}

- (void)startRecord
{
    [[ARKReplayManager instance] startRecord];
    
    [self updateTitle];
}

- (void)stopRecord
{
    [[ARKReplayManager instance] stopRecord];
    
    [self updateTitle];
}

- (void)startReplay
{
    [[ARKReplayManager instance] replayEvents];
    
    [self updateTitle];
}

- (void)updateTitle
{
    if ([ARKReplayManager instance].isReplaying) {
        self.title = @"Replaying";
    }
    else if ([ARKReplayManager instance].isRecording) {
        self.title = @"Recording";
    }
    else {
        self.title = @"Record Stopped";
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gg"
                                                            forIndexPath:indexPath];
    NSNumber *number = self.numbers[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", number];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.numbers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"showSecondVC" sender:self];
}

@end
