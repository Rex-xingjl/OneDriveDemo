//
//  UIAlertController+Category.m
//  COMEngine
//
//  Created by Rex on 2019/4/9.
//  Copyright © 2019 yunxiang. All rights reserved.
//

#import "UIAlertController+Category.h"

#define kPresentAlertC [target presentViewController:alertC animated:YES completion:nil];

@implementation UIAlertController (Category)

+ (void)showOneActionAlert:(id)target
                     Title:(NSString *)title
                   Message:(NSString *)message
               ActionTitle:(NSString *)actionTitle
               EnsureBlock:(rex_EnsureBlock)ensureBlock {
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title ? : @"" message:message  ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertC addAction:[UIAlertAction actionWithTitle:actionTitle ? : @"确定"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 if (ensureBlock) {
                                                     ensureBlock();
                                                 }
                                             }]];
    kPresentAlertC
}

+ (void)showTwoActionAlert:(id)target
                     Title:(NSString *)title
                   Message:(NSString *)message
                 LeftTitle:(NSString *)left
                RightTitle:(NSString *)right
               EnsureBlock:(rex_EnsureBlock)ensureBlock {
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title ? : @""  message:message ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:left ? : @"取消"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 
                                             }]];
    [alertC addAction:[UIAlertAction actionWithTitle:right ? : @"确定"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 if (ensureBlock) {
                                                     ensureBlock();
                                                 }
                                             }]];
    kPresentAlertC
}

+ (void)showTwoActionAlert:(id)target
                     Title:(NSString *)title
                   Message:(NSString *)message
                 LeftTitle:(NSString *)left
                RightTitle:(NSString *)right
               EnsureBlock:(rex_EnsureBlock)ensureBlock
               CancelBlock:(rex_CancelBlock)cancelBlock {
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title ? : @"" message:message ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:left ? : @"取消"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 if (cancelBlock) {
                                                     cancelBlock();
                                                 }
                                             }]];
    [alertC addAction:[UIAlertAction actionWithTitle:right ? : @"确定"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 if (ensureBlock) {
                                                     ensureBlock();
                                                 }
                                             }]];
    kPresentAlertC
}

+ (void)showNumberAlert:(id)target
                   Text:(NSString *)text
            PlaceHolder:(NSString *)holder
                  Title:(NSString *)title
                Message:(NSString *)message
            EnsureBlock:(rex_TextEnsureBlock)ensureBlock {
    
    __block UITextField * tf;
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title  ? : @""  message:message  ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = holder;
        textField.text = text;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        tf = textField;
    }];
    [alertC addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 if (ensureBlock) {
                                                     ensureBlock(tf.text);
                                                 }
                                             }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"取消"
                                               style:UIAlertActionStyleCancel
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 
                                                 
                                             }]];
    kPresentAlertC
}

+ (void)showTextAlert:(id)target
                 Text:(NSString *)text
          PlaceHolder:(NSString *)holder
                Title:(NSString *)title
              Message:(NSString *)message
          EnsureBlock:(rex_TextEnsureBlock)ensureBlock {
    [self showTextAlert:target
                  Title:title
                Message:message
                tfBlock:nil
                   Text:text
            PlaceHolder:holder
            EnsureBlock:ensureBlock];
}

+ (void)showTextAlert:(id)target
                Title:(NSString *)title
              Message:(NSString *)message
              tfBlock:(rex_TextFieldBlock)tfBlock
                 Text:(NSString *)text
          PlaceHolder:(NSString *)holder
          EnsureBlock:(rex_TextEnsureBlock)ensureBlock {
    
    __block UITextField * tf;
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title  ? : @""  message:message  ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = holder;
        textField.text = text;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf = textField;
        if (tfBlock) {
            tfBlock(textField);
        }
    }];
    [alertC addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 if (ensureBlock) {
                                                     ensureBlock(tf.text);
                                                 }
                                             }]];
    [alertC addAction:[UIAlertAction actionWithTitle:@"取消"
                                               style:UIAlertActionStyleCancel
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 
                                                 
                                             }]];
    kPresentAlertC
}

+ (void)showAlert:(id)target title:(NSString *)title actionTitles:(NSArray *)titleArray
     actionBlocks:(rex_ActionBlock)actionBlock {
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
    
    for (int i = 0; i < titleArray.count; i ++) {
        [alertC addAction:[UIAlertAction actionWithTitle:titleArray[i]
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     if (actionBlock) {
                                                         actionBlock(i, action);
                                                     }
                                                 }]];
    }
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    kPresentAlertC
}

+ (void)showSheet:(id)target title:(NSString *)title message:(NSString *)message
     actionTitles:(NSArray *)titleArray
     actionBlocks:(rex_ActionBlock)actionBlock {
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < titleArray.count; i ++) {
        [alertC addAction:[UIAlertAction actionWithTitle:titleArray[i]
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     if (actionBlock) {
                                                         actionBlock(i, action);
                                                     }
                                                 }]];
    }
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    kPresentAlertC
}

@end
