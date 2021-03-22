//
//  YXHUD.m
//  HUD
//
//  Created by Rex on 2017/8/14.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "YXHUD.h"

@implementation YXHUD

#pragma mark -

+ (void)showOnView:(UIView *)view {
    [self showInfo:nil attributedInfo:nil waitIndicator:YES autoHide:NO afterDelay:YXHUDDelayTime onView:view];
}

+ (void)showInfo:(NSString *)info onView:(UIView *)view {
    [self showInfo:info attributedInfo:nil waitIndicator:NO autoHide:YES afterDelay:YXHUDDelayTime onView:view];
}

+ (void)hideOnView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
       [MBProgressHUD hideHUDForView:view animated:YES];
    });
}

+ (void)showInfo:(NSString *)info success:(BOOL)success {
    [self showInfo:info success:success onView:nil];
}

+ (void)showInfo:(NSString *)info success:(BOOL)success onView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    [self hideOnView:view];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationZoomOut;
    hud.removeFromSuperViewOnHide = YES;
    
    UIImage *image = [UIImage imageNamed:success ? @"hud_success" : @"hud_failed"];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.detailsLabel.text = info;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    
    [hud hideAnimated:YES afterDelay:YXHUDDelayTime];
}

#pragma mark -

+ (void)show {
    [self showInfo:@"" attributedInfo:nil waitIndicator:YES autoHide:NO afterDelay:YXHUDDelayTime onView:nil];
}

+ (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [MBProgressHUD hideHUDForView:window animated:YES];
    });
}

+ (void)showInfo:(NSString *)info {
    [self showInfo:info attributedInfo:nil waitIndicator:NO autoHide:YES afterDelay:YXHUDDelayTime onView:nil];
}

+ (void)showInfo:(NSString *)info afterDelay:(NSInteger)time {
    [self showInfo:info attributedInfo:nil waitIndicator:NO autoHide:YES afterDelay:time onView:nil];
}

+ (void)showInfo:(NSString *)info autoHide:(BOOL)hide {
    [self showInfo:info attributedInfo:nil waitIndicator:NO autoHide:hide afterDelay:YXHUDDelayTime onView:nil];
}

+ (MBProgressHUD *)showHUDWithInfo:(NSString *)info {
   return [self showInfo:info attributedInfo:nil waitIndicator:YES autoHide:NO afterDelay:YXHUDDelayTime onView:nil];
}

+ (void)showProgress:(CGFloat)progress {
//    MBBarProgressView
}

+ (MBProgressHUD *)showInfo:(NSString *)info attributedInfo:(NSAttributedString *)attributedInfo waitIndicator:(BOOL)wait autoHide:(BOOL)hide afterDelay:(CGFloat)time onView:(UIView *)view {
    
    NSString *message = @"";
    if ([info isKindOfClass:[NSString class]]) {
        message = info;
    }
    
    __block MBProgressHUD *hud;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (view) {
            [MBProgressHUD hideHUDForView:view animated:YES];
        } else {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [MBProgressHUD hideHUDForView:window animated:YES];
        }
        
        if (view) {
            hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        } else {
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        }
        hud.mode = wait ? MBProgressHUDModeIndeterminate : MBProgressHUDModeText;
        
        if (message.length) {
            hud.detailsLabel.text = message;
        }
        if (attributedInfo.length) {
            hud.detailsLabel.attributedText = attributedInfo;
        }
        hud.detailsLabel.font = [UIFont systemFontOfSize:15];
        hud.animationType = MBProgressHUDAnimationZoomOut;
        
        UITapGestureRecognizer * tap_once = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [hud.bezelView addGestureRecognizer:tap_once];
        UITapGestureRecognizer * tap_twice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        tap_twice.numberOfTapsRequired = 2;
        [hud.backgroundView addGestureRecognizer:tap_twice];
        hud.userInteractionEnabled = wait;
        
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
            hud.hidden = YES;
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                hud.transform = CGAffineTransformMakeRotation(M_PI_2);
            } else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                hud.transform = CGAffineTransformMakeRotation(-M_PI_2);
            }
            hud.center = hud.superview.center;
            hud.hidden = NO;
        }
        if (hide) {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:hide afterDelay:time];
                });
            });
        }
    });

    return hud;
}

+ (void)showAttributedInfo:(NSAttributedString *)attributedInfo {
    [self showInfo:@"" attributedInfo:attributedInfo waitIndicator:NO autoHide:YES afterDelay:YXHUDDelayTime onView:nil];
}

@end
