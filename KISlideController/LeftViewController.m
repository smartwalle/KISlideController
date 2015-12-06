//
//  LeftViewController.m
//  KISlideController
//
//  Created by SmartWalle on 15/12/6.
//  Copyright © 2015年 SmartWalle. All rights reserved.
//

#import "LeftViewController.h"

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
