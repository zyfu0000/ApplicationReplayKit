//
//  SecondViewController.m
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/11/18.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import "SecondViewController.h"
#import "ARKDataSource.h"
#import <extobjc.h>
#import "ARKReplayManager.h"
#import "BlockHook.h"

@interface SecondViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *numbers;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"gg"];
 
//    // 同步重写方法的调用
//    self.numbers = [[ARKDataSource instance] numbers];
//    [self.tableView reloadData];

    @weakify(self);
    [[ARKDataSource instance] asyncNumbers:BLOCK_CALL_ASSERT(^(NSArray *numbers) {
        @strongify(self);
        self.numbers = [[ARKDataSource instance] numbers];
        [self.tableView reloadData];
    })];
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
}

@end
