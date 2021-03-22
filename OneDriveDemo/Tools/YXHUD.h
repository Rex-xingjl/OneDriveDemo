//
//  YXHUD.h
//  HUD
//
//  Created by Rex on 2017/8/14.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "MBProgressHUD.h"

#define YXHUDDelayTime 1.618f

@interface YXHUD : MBProgressHUD

#pragma mark - Show on Other View

+ (void)showOnView:(UIView *)view;
+ (void)showInfo:(NSString *)info onView:(UIView *)view;
+ (void)hideOnView:(UIView *)view;
+ (void)showInfo:(NSString *)info success:(BOOL)success;
+ (void)showInfo:(NSString *)info success:(BOOL)success onView:(UIView *)view;

#pragma mark - Show On Window

/**
 * 【纯图HUD】
 *  等待图：YES 文字：NO 自动隐藏：NO
 */
+ (void)show;

/**
 * 【隐藏所有HUD】
 */
+ (void)hide;

/**
 * 【纯文字自动隐藏HUD】
 *  等待图：NO 文字：YES 自动隐藏：YES
 */
+ (void)showInfo:(NSString *)info;

/**
 * 【纯文字定时隐藏HUD】
 *  等待图：NO 文字：YES 自动隐藏：YES
 */
+ (void)showInfo:(NSString *)info afterDelay:(NSInteger)time;

/**
 * 【纯文字HUD】
 *  等待图：NO 文字：YES 自动隐藏：custom
 */
+ (void)showInfo:(NSString *)info autoHide:(BOOL)hide;

/**
 * 【等待图加文字HUD】
 *  显示等待图和文字 不会自动隐藏
 */
+ (MBProgressHUD *)showHUDWithInfo:(NSString *)info;

/**
 * 【主方法】
 *  info：文字 wait：等待图 hide：自动隐藏 延时时间：time
 */
+ (MBProgressHUD *)showInfo:(NSString *)info attributedInfo:(NSAttributedString *)attributedInfo waitIndicator:(BOOL)wait autoHide:(BOOL)hide afterDelay:(CGFloat)time onView:(UIView *)view;

/**
 * 【Attributed文字自动隐藏HUD】
 *  等待图：NO 文字：YES 自动隐藏：YES
 */
+ (void)showAttributedInfo:(NSAttributedString *)attributedInfo;

@end
