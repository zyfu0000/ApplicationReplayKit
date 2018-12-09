//
//  SecondViewController.m
//  ApplicationReplayKit
//
//  Created by Zhiyang Fu on 2018/11/18.
//  Copyright © 2018 Zhiyang Fu. All rights reserved.
//

#import "SecondViewController.h"
#import "ARKDataSource.h"

@interface SecondViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *numbers;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"gg"];
    
    self.numbers = [[ARKDataSource instance] numbers];
    
    [self.tableView reloadData];
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
