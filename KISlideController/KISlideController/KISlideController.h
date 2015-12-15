//
//  KISlideController.h
//  Kitalker
//
//  Created by apple on 15/7/6.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, KISlideControllerStatus) {
    KISlideControllerStatusOfClose = 0,
    KISlideControllerStatusOfOpen  = 1,
};

@class KISlideController;

//left view controlelr 将作为默认的代理对象
@protocol KISlideControllerDelegate <NSObject>
@optional
- (BOOL)willOpenSlideController:(KISlideController *)controller;
- (void)didOpenSlideController:(KISlideController *)controller;

- (BOOL)willCloseSlideController:(KISlideController *)controller;
- (void)didCloseSlideController:(KISlideController *)controller;
@end

@interface KISlideController : UIViewController

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftViewController;

@property (nonatomic, copy) UIColor *mainViewMaskColor;
@property (nonatomic, copy) UIColor *leftViewMaskColor;

//即left view展开后的宽度
@property (nonatomic, assign) CGFloat slideViewWidth;

//默认0.8
@property (nonatomic, assign) CGFloat contentScale;

- (KISlideControllerStatus)status;

- (void)setMainViewController:(UIViewController *)mainViewController
           leftViewController:(UIViewController *)leftViewController;

- (UIViewController *)mainViewController;

- (UIViewController *)leftViewController;

- (void)closeSlideView;

- (void)openSlideView;

@end

@interface UIViewController (KISlideController)
- (KISlideController *)slideController;
@end