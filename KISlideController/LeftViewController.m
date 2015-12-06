//
//  LeftViewController.m
//  KISlideController
//
//  Created by SmartWalle on 15/12/6.
//  Copyright © 2015年 SmartWalle. All rights reserved.
//

#import "LeftViewController.h"
#import "MainViewController.h"
#import "ViewController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor greenColor]];
}

- (BOOL)willOpenSlideController:(KISlideController *)controller {
    return YES;
}

- (void)didOpenSlideController:(KISlideController *)controller {
    NSLog(@"did open %d", controller.status);
}

- (BOOL)willCloseSlideController:(KISlideController *)controller {
    return YES;
}

- (void)didCloseSlideController:(KISlideController *)controller {
    NSLog(@"did close %d", controller.status);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [cell.textLabel setText:[NSString stringWithFormat:@"Menu %d", indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *vc = nil;
    if (indexPath.row % 2 == 0) {
        vc = [[ViewController alloc] init];
    } else {
        vc = [[MainViewController alloc] init];
    }
    [self.slideController setMainViewController:vc];
    [self.slideController closeSlideView];
}

@end
