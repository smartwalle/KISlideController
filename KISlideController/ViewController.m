//
//  ViewController.m
//  KISlideController
//
//  Created by SmartWalle on 15/12/6.
//  Copyright © 2015年 SmartWalle. All rights reserved.
//

#import "ViewController.h"
#import "KISlideController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor greenColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MENU_CELL = @"MENU_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MENU_CELL];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MENU_CELL];
    }
    [cell setBackgroundColor:[UIColor greenColor]];
    [cell.textLabel setText:[NSString stringWithFormat:@"Main2 %d", indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.slideController openSlideView];
}

@end
