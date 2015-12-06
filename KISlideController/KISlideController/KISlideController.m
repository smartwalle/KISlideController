//
//  KISlideController.m
//  Kitalker
//
//  Created by apple on 15/7/6.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KISlideController.h"

#define kLeftViewOffseRate 0.3

@interface KISlideContentView : UIView
@property (nonatomic, assign) UIView *contentView;
@end

@implementation KISlideContentView

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    self.contentView = view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setFrame:self.bounds];
}
@end

@interface KISlideController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<KISlideControllerDelegate> delegate;

@property (nonatomic, assign) CGRect viewBounds;

@property (nonatomic, assign) CGFloat offsetX;

@property(nonatomic, assign) KISlideControllerStatus status;

@property (nonatomic, strong) UIView             *maskView;
@property (nonatomic, strong) KISlideContentView *leftView;
@property (nonatomic, strong) KISlideContentView *mainView;

@property (nonatomic, strong) UIPanGestureRecognizer           *panGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer;

@end

@implementation KISlideController

#pragma makr Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)loadView {
    [super loadView];
    [self setup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateLeftViewController:self.leftViewController];
    [self updateMainViewController:self.mainViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mainView setFrame:self.view.bounds];
    [self.leftView setFrame:self.view.bounds];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mainView setFrame:self.view.bounds];
    [self.leftView setFrame:self.view.bounds];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    
    if (velocity.x > 0 ) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(willOpenSlideController:)]) {
            return [self.delegate willOpenSlideController:self];
        }
    } else {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(willCloseSlideController:)]) {
            return [self.delegate willCloseSlideController:self];
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.mainView];
    if ((CGRectGetWidth(self.viewBounds) - self.slideViewWidth) / 3 > point.x) {
        return YES;
    }
    return NO;
}

#pragma mark Event response
- (void)panGestureRecognizerHandler:(UIPanGestureRecognizer *)handler {
    CGPoint velocity = [handler velocityInView:self.view];
    CGPoint point = [handler translationInView:self.view];
    BOOL moveable = YES;
    
    self.offsetX = self.offsetX + point.x;
    
    if (handler.state == UIGestureRecognizerStateBegan) {
        [self.view sendSubviewToBack:self.leftView];
        [self.view bringSubviewToFront:self.mainView];
        [self.maskView setFrame:self.viewBounds];
    }
    
    CGFloat minX = CGRectGetMinX(self.mainView.frame);
    CGFloat viewWidth = CGRectGetWidth(self.viewBounds);
    
    if ((minX <= 0 && self.offsetX <= 0) || (minX >= self.slideViewWidth && self.offsetX >= 0)) {
        self.offsetX = 0;
        moveable = NO;
    }
    
    if (moveable && minX >= 0 && minX <= self.slideViewWidth) {
        CGFloat progress = [self progressOfSlide];
        
        //改变main view的center
        CGPoint mainViewCenter = self.mainView.center;
        CGFloat newX = self.mainView.center.x + point.x;
        //当向左滑动的时候，即关闭left view，main view 的centen x 不能小于 slide view 的二分之一。
        if (velocity.x < 0) {
            newX = MAX(viewWidth * 0.5, newX);
        }
        mainViewCenter.x = newX;
        [self.mainView setCenter:mainViewCenter];
        
        if (newX <= viewWidth * 0.5) {
            progress = 0;
        }
        
        //改变left view的center
        CGPoint leftViewCenter = self.leftView.center;
        leftViewCenter.x = viewWidth * kLeftViewOffseRate + progress * (viewWidth * 0.5 - viewWidth * kLeftViewOffseRate);
        [self.leftView setCenter:leftViewCenter];
        
        //改变mask view的透明度
        [self.maskView setAlpha:1 - progress];
        
        //改变main view 的scale
        CGFloat mainViewScale = 1.0 - progress * (1.0 - self.contentScale);
        [self updateMainViewScale:mainViewScale];
        
        //改变left view的scale
        CGFloat leftViewScale = self.contentScale + progress * (1.0 - self.contentScale);
        [self updateLeftViewScale:leftViewScale];
        
        [handler setTranslation:CGPointZero inView:self.view];
    } else {
        if (minX < 0) {
            [self closeLeftView];
            self.offsetX = 0;
        } else if (minX > self.slideViewWidth) {
            [self openLeftView];
            self.offsetX = 0;
        }
        return;
    }
    
    if (handler.state == UIGestureRecognizerStateEnded) {
        if (fabs(self.offsetX) > self.slideViewWidth * kLeftViewOffseRate) {
            if (self.status == KISlideControllerStatusOfOpen) {
                [self closeLeftView];
            } else {
                [self openLeftView];
            }
        } else if (fabs(velocity.x) >= 800) {
            if (self.status == KISlideControllerStatusOfOpen && velocity.x < 0) {
                [self closeLeftView];
            } else if (velocity.x > 0) {
                [self openLeftView];
            }
        } else {
            if (self.status == KISlideControllerStatusOfOpen) {
                [self openLeftView];
            } else {
                [self closeLeftView];
            }
        }
        self.offsetX = 0;
    }
}

#pragma mark Methods
- (void)setup {
    self.leftView = [[KISlideContentView alloc] init];
    [self.leftView setBackgroundColor:[UIColor clearColor]];
    [self.leftView setUserInteractionEnabled:YES];
    [self.view addSubview:self.leftView];
    
    self.maskView = [[UIView alloc] init];
    [self.maskView setBackgroundColor:[UIColor blackColor]];
    [self.maskView setUserInteractionEnabled:NO];
    [self.maskView setAlpha:1.0];
    [self.view addSubview:self.maskView];
    
    self.mainView = [[KISlideContentView alloc] init];
    [self.mainView setBackgroundColor:[UIColor clearColor]];
    [self.mainView setUserInteractionEnabled:YES];
    [self.view addSubview:self.mainView];
    
    [self.mainView addGestureRecognizer:self.panGestureRecognizer];
    [self.mainView addGestureRecognizer:self.screenEdgePanGestureRecognizer];
    [self.panGestureRecognizer requireGestureRecognizerToFail:self.screenEdgePanGestureRecognizer];
}

- (void)setMainViewController:(UIViewController *)mainViewController
           leftViewController:(UIViewController *)leftViewController {
    [self setMainViewController:mainViewController];
    [self setLeftViewController:leftViewController];
}

- (void)updateLeftViewController:(UIViewController *)viewController {
    if (viewController != nil && [self isViewLoaded]) {
        [self.leftView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
    if (_leftViewController != leftViewController) {
        if ([self isViewLoaded]) {
            [_leftViewController.view removeFromSuperview];
            [_leftViewController removeFromParentViewController];
        }
    }
    _leftViewController = leftViewController;
    [self setDelegate:(id)_leftViewController];
    [self updateLeftViewController:_leftViewController];
}

- (void)updateMainViewController:(UIViewController *)viewController {
    if (viewController != nil && [self isViewLoaded]) {
        [self.mainView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }
}

- (void)setMainViewController:(UIViewController *)mainViewController {
    if (_mainViewController != mainViewController) {
        if ([self isViewLoaded]) {
            [_mainViewController.view removeFromSuperview];
            [_mainViewController removeFromParentViewController];
        }
    }
    _mainViewController = mainViewController;
    [self updateMainViewController:_mainViewController];
}

- (void)updateMainViewScale:(CGFloat)scale {
    self.mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

- (void)updateLeftViewScale:(CGFloat)scale {
    self.leftView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

- (CGFloat)progressOfSlide {
    CGFloat progress = CGRectGetMinX(self.mainView.frame) / self.slideViewWidth;
    return progress;
}

- (void)closeLeftView {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGFloat viewWidth = CGRectGetWidth(self.viewBounds);
                         self.mainView.center = CGPointMake(viewWidth * 0.5,
                                                            self.mainView.center.y);
                         self.leftView.center = CGPointMake(viewWidth * kLeftViewOffseRate,
                                                            self.leftView.center.y);
                         [self updateMainViewScale:1.0];
                         [self updateLeftViewScale:self.contentScale];
                         [self.maskView setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             [self updateStatus:KISlideControllerStatusOfClose];
                         }
                     }];
}

- (void)openLeftView {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGFloat viewWidth = CGRectGetWidth(self.viewBounds);
                         self.mainView.center = CGPointMake(viewWidth * 0.5 + self.slideViewWidth - viewWidth * (1 - self.contentScale) * 0.5,
                                                            self.mainView.center.y);
                         self.leftView.center = CGPointMake(viewWidth * 0.5,
                                                            self.leftView.center.y);
                         [self updateMainViewScale:self.contentScale];
                         [self updateLeftViewScale:1.0];
                         [self.maskView setAlpha:0.0];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             [self updateStatus:KISlideControllerStatusOfOpen];
                         }
                     }];
}

- (void)didOpenLeftViewController {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didOpenSlideController:)]) {
        [self.delegate didOpenSlideController:self];
    }
}

- (void)didCloseLeftViewController {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didCloseSlideController:)]) {
        [self.delegate didCloseSlideController:self];
    }
}

- (void)updateStatus:(KISlideControllerStatus)status {
    if (self.status != status) {
        [self setStatus:status];
        
        if (status == KISlideControllerStatusOfOpen) {
            [self didOpenLeftViewController];
        } else {
            [self didCloseLeftViewController];
        }
    }
}

#pragma mark Getters and Setters
- (CGRect)viewBounds {
    return self.view.bounds;
}

- (CGFloat)slideViewWidth {
    if (_slideViewWidth <= 0.001) {
        _slideViewWidth = CGRectGetWidth(self.viewBounds) * (1 - kLeftViewOffseRate);
    }
    return _slideViewWidth;
}

- (CGFloat)contentScale {
    if (_contentScale <= 0.001) {
        _contentScale = 0.8;
    }
    return _contentScale;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(panGestureRecognizerHandler:)];
        [_panGestureRecognizer setDelegate:self];
        [_panGestureRecognizer setCancelsTouchesInView:YES];
    }
    return _panGestureRecognizer;
}

- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer {
    if (_screenEdgePanGestureRecognizer == nil) {
        _screenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(panGestureRecognizerHandler:)];
        [_screenEdgePanGestureRecognizer setDelegate:self];
        [_screenEdgePanGestureRecognizer setEdges:UIRectEdgeLeft];
        [_screenEdgePanGestureRecognizer setCancelsTouchesInView:YES];
    }
    return _screenEdgePanGestureRecognizer;
}

- (KISlideControllerStatus)status {
    return _status;
}
@end

@implementation UIViewController (KISlideController)

- (KISlideController *)slideController {
    UIViewController *parentController = self.parentViewController;
    if ([parentController isMemberOfClass:[KISlideController class]]) {
        return (KISlideController *)parentController;
    }
    if (parentController != nil) {
        return [parentController slideController];
    }
    return nil;
}

@end
