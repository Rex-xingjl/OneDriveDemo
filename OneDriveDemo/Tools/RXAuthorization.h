//
//  RXAuthorization.h
//   
//
//  Created by Rex on 2018/7/17.
//  Copyright © 2018 com.yunxiang. All rights reserved.
//
//  系统工具的权限判断 没有权限时弹框选择是否跳转到应用设置

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    RXAuthorizationType_Photo,
    RXAuthorizationType_Camera,
    RXAuthorizationType_Audio,
    RXAuthorizationType_Location,
    RXAuthorizationType_AddressBook,
    RXAuthorizationType_Notification,
    RXAuthorizationType_Network,
    RXAuthorizationType_SiriAndSearch,
    RXAuthorizationType_Bluetooth,
    RXAuthorizationType_Calendar,
    RXAuthorizationType_Reminder,
    RXAuthorizationType_SpeechRecognizer,
    RXAuthorizationType_Unknown,
} RXAuthorizationType;

typedef enum : NSUInteger {
    RXAuthorizationStatusNotDetermined = 0,
    RXAuthorizationStatusRestricted,
    RXAuthorizationStatusDenied,
    RXAuthorizationStatusAuthorized,
} RXAuthorizationStatus;

@interface RXAuthorization : NSObject

/** 系统功能权限获取 */
+ (void)authWithType:(RXAuthorizationType)type permission:(void(^)(BOOL allow)) block;

@end

@interface RXAuthorizationView : UIView

+ (void)showWithTitle:(NSString *)title Detail:(NSString *)detail;

@end
