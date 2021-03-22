//
//  UIAlertController+Category.h
//  COMEngine
//
//  Created by Rex on 2019/4/9.
//  Copyright © 2019 yunxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^rex_EnsureBlock)(void);
typedef void(^rex_CancelBlock)(void);

typedef void(^rex_TextFieldBlock)(UITextField *textField);
typedef void(^rex_TextEnsureBlock)(NSString * text);
typedef void(^rex_ActionBlock)(NSInteger index, UIAlertAction * action);

@interface UIAlertController (Category)

/**
 *  显示 一个按钮的 AlertView界面
 *  @param target     显示的控制器
 *  @param title      提示框的标题
 *  @param actionTitle     按钮标题
 *  @param ensureBlock    按钮回调block
 */

+ (void)showOneActionAlert:(id)target
                     Title:(NSString *)title
                   Message:(NSString *)message
               ActionTitle:(NSString *)actionTitle
               EnsureBlock:(rex_EnsureBlock)ensureBlock;

/**
 *  显示 两个按钮的 AlertView界面 （不带取消按钮事件）
 *  @param target     显示的控制器    @param title   提示框的标题
 *  @param ensureBlock    右侧按钮回调block
 */
+ (void)showTwoActionAlert:(id)target
                     Title:(NSString *)title
                   Message:(NSString *)message
                 LeftTitle:(NSString *)left
                RightTitle:(NSString *)right
               EnsureBlock:(rex_EnsureBlock)ensureBlock;
/**
 *  显示 两个按钮的 AlertView界面 （带取消按钮事件）
 *  @param target     显示的控制器    @param title   提示框的标题
 *  @param cancelBlock    左侧按钮回调block
 *  @param ensureBlock    右侧按钮回调block
 */
+ (void)showTwoActionAlert:(id)target
                     Title:(NSString *)title
                   Message:(NSString *)message
                 LeftTitle:(NSString *)left
                RightTitle:(NSString *)right
               EnsureBlock:(rex_EnsureBlock)ensureBlock
               CancelBlock:(rex_CancelBlock)cancelBlock;

/**
*  显示 带输入框（数字键盘）的 <确定/取消> AlertView界面
*  @param target     显示的控制器    @param title   提示框的标题
*  @param ensureBlock    右侧按钮回调block
*/
+ (void)showNumberAlert:(id)target
                   Text:(NSString *)text
            PlaceHolder:(NSString *)holder
                  Title:(NSString *)title
                Message:(NSString *)message
            EnsureBlock:(rex_TextEnsureBlock)ensureBlock;

/**
 *  显示 带输入框（通用键盘）的 <确定/取消> AlertView界面
 *  @param target     显示的控制器    @param title   提示框的标题
 *  @param ensureBlock    右侧按钮回调block
 */
+ (void)showTextAlert:(id)target
                 Text:(NSString *)text
          PlaceHolder:(NSString *)holder
                Title:(NSString *)title
              Message:(NSString *)message
          EnsureBlock:(rex_TextEnsureBlock)ensureBlock;

/**
*  显示 带输入框（通用键盘）的 <确定/取消> AlertView界面
*  @param target     显示的控制器    @param title   提示框的标题
*  @param tfBlock    输入框回调block
*  @param ensureBlock    右侧按钮回调block
*/
+ (void)showTextAlert:(id)target
                Title:(NSString *)title
              Message:(NSString *)message
              tfBlock:(rex_TextFieldBlock)tfBlock
                 Text:(NSString *)text
          PlaceHolder:(NSString *)holder
          EnsureBlock:(rex_TextEnsureBlock)ensureBlock;

/**
 *  显示任意Alert界面
 *  @param target    显示的控制器
 *  @param title     alert的标题
 *  @param titleArray 按钮标题数组
 *  @param actionBlock 回调的block
 */
+ (void)showAlert:(id)target
            title:(NSString *)title
     actionTitles:(NSArray *)titleArray
     actionBlocks:(rex_ActionBlock)actionBlock;

/**
 *  显示任意ActionSheet界面
 *  @param target    显示的控制器
 *  @param title     sheet的标题  @param message  sheet的消息
 *  @param titleArray 按钮标题数组
 *  @param actionSheetBlock 回调的block
 */
+ (void)showSheet:(id)target
            title:(NSString *)title
          message:(NSString *)message
     actionTitles:(NSArray *)titleArray
     actionBlocks:(rex_ActionBlock)actionSheetBlock;


@end
