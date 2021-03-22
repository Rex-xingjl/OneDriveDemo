//
//  RXAuthorization.m
//   
//
//  Created by Rex on 2018/7/17.
//  Copyright © 2018 com.yunxiang. All rights reserved.
//

#import "RXAuthorization.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>
#import <CoreLocation/CLLocationManager.h>
#import <AddressBook/AddressBook.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#import <UserNotifications/UNNotificationSettings.h>
#import <CoreTelephony/CTCellularData.h>
#import <Contacts/CNContactStore.h>
#import <Intents/Intents.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <EventKit/EventKit.h>
#import <Speech/Speech.h>

#import "UIAlertController+Category.h"

@implementation RXAuthorization

+ (void)authWithType:(RXAuthorizationType)type permission:(void(^)(BOOL allow)) block {
    [self AuthWithType:type permission:^(RXAuthorizationStatus status, BOOL allow) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(allow);
            if (status == RXAuthorizationStatusDenied) {
                NSString * typeName = [self settingNameWithType:type];
                NSString * title = [NSString stringWithFormat:@"需要开启%@权限", typeName];
                NSString * detail = [NSString stringWithFormat:@"请前往手机的“设置”选项中，允许%@访问您的APP", typeName];
                [RXAuthorizationView showWithTitle:title Detail:detail];
            }
        });
    }];
}

+ (NSString *)settingNameWithType:(RXAuthorizationType)type {
    switch (type) {
        case RXAuthorizationType_Photo: return @"相册"; break;
        case RXAuthorizationType_Camera: return @"相机"; break;
        case RXAuthorizationType_Audio: return @"麦克风"; break;
        case RXAuthorizationType_Location: return @"定位"; break;
        case RXAuthorizationType_Notification: return @"通知"; break;
        case RXAuthorizationType_Network: return @"数据"; break;
        case RXAuthorizationType_AddressBook: return @"通讯录"; break;
        case RXAuthorizationType_Bluetooth: return @"蓝牙"; break;
        case RXAuthorizationType_Calendar: return @"日历"; break;
        case RXAuthorizationType_Reminder: return @"备忘录"; break;
        case RXAuthorizationType_SiriAndSearch: return @"Siri和搜索"; break;
        case RXAuthorizationType_SpeechRecognizer: return @"语音识别"; break;
        default: break;
    }
    return @"未知功能";
}

+ (void)AuthWithType:(RXAuthorizationType)type permission:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
    if (block) {
        switch (type) {
            case RXAuthorizationType_Photo: {
                [self canOpenPhotoLibraryPermission:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status ,allow);
                }];
            } break;
            case RXAuthorizationType_Camera: {
                [self canOpenCameraPermission:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_Audio: {
                [self canRecordAudio:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_Network: {
                [self canUseNetwork:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_Location: {
                [self canUseLocation:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_Calendar: {
                [self canUseEKEvent:EKEntityTypeEvent permission:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_Reminder: {
                [self canUseEKEvent:EKEntityTypeReminder permission:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_Bluetooth: {
                [self canUseBluetooth:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_AddressBook: {
                [self canOpenAddressBook:^(RXAuthorizationStatus status, BOOL allow) {
                   block(status, allow);
                }];
            } break;
            case RXAuthorizationType_Notification: {
                [self canReceiveNotification:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_SiriAndSearch: {
                [self canUseSiriAndSearch:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            case RXAuthorizationType_SpeechRecognizer: {
                [self canUserSpeechRecognizer:^(RXAuthorizationStatus status, BOOL allow) {
                    block(status, allow);
                }];
            } break;
            default: break;
        }
    }
}

+ (void)canOpenPhotoLibraryPermission:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (block) {
        switch (status) {
            case PHAuthorizationStatusNotDetermined: {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    block(RXAuthorizationStatusNotDetermined, status == PHAuthorizationStatusAuthorized);
                }];
            } break;
            case PHAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
            case PHAuthorizationStatusRestricted: block(RXAuthorizationStatusRestricted, NO); break;
            case PHAuthorizationStatusAuthorized: block(RXAuthorizationStatusAuthorized, YES); break;
            default: break;
        }
    }
}

+ (void)canOpenCameraPermission:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
#if TARGET_IPHONE_SIMULATOR
    NSAssert(0, @"not supported");
#elif TARGET_OS_IPHONE
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (block) {
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    block(RXAuthorizationStatusNotDetermined, granted);
                }];
            } break;
            case AVAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
            case AVAuthorizationStatusRestricted: block(RXAuthorizationStatusRestricted, NO); break;
            case AVAuthorizationStatusAuthorized: block(RXAuthorizationStatusAuthorized, YES); break;
            default: break;
        }
    }
#endif
}

+ (void)canRecordAudio:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    AVAudioSessionRecordPermission status = [[AVAudioSession sharedInstance] recordPermission];
    if (block) {
        switch (status) {
            case AVAudioSessionRecordPermissionUndetermined: {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    block(RXAuthorizationStatusNotDetermined, granted);
                }];
            } break;
            case AVAudioSessionRecordPermissionDenied: block(RXAuthorizationStatusDenied, NO); break;
            case AVAudioSessionRecordPermissionGranted: block(RXAuthorizationStatusAuthorized, YES); break;
            default: break;
        }
    }
#endif
}

+ (void)canUseLocation:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (block) {
        if ([CLLocationManager locationServicesEnabled]) {
            switch (status) {
                case kCLAuthorizationStatusNotDetermined: {
                    block(RXAuthorizationStatusNotDetermined, NO);
                    static CLLocationManager *manager;
                    if (!manager) manager = [CLLocationManager new];
                    [manager requestAlwaysAuthorization];
                    manager.allowsBackgroundLocationUpdates = YES;
                } break;
                case kCLAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
                case kCLAuthorizationStatusRestricted: block(RXAuthorizationStatusRestricted, NO); break;
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                case kCLAuthorizationStatusAuthorizedAlways: block(RXAuthorizationStatusAuthorized, YES); break;
                default: break;
            }
        } else {
            block(RXAuthorizationStatusDenied, NO);
        }
    }
}

+ (void)canOpenAddressBook:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (block) {
        switch (status) {
            case CNAuthorizationStatusNotDetermined: {
                CNContactStore *store = [[CNContactStore alloc] init];
                [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
                    block(RXAuthorizationStatusNotDetermined, granted);
                }];
            } break;
            case CNAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
            case CNAuthorizationStatusRestricted: block(RXAuthorizationStatusRestricted, NO); break;
            case CNAuthorizationStatusAuthorized: block(RXAuthorizationStatusAuthorized, YES); break;
            default: break;
        }
    }
#endif
}

+ (void)canReceiveNotification:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (block) {
                switch (settings.authorizationStatus) {
                    case UNAuthorizationStatusNotDetermined: block(RXAuthorizationStatusNotDetermined, NO); break;
                    case UNAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
                    case UNAuthorizationStatusAuthorized: block(RXAuthorizationStatusAuthorized, YES); break;
                    default: break;
                }
            }
        }];
    } else {
        BOOL isRegister = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        if (block) {
            if (isRegister) {
                block(RXAuthorizationStatusAuthorized, YES);
            } else {
                block(RXAuthorizationStatusDenied, NO);
            }
        }
    }
}

+ (void)canUseNetwork:(void(^)(RXAuthorizationStatus status, BOOL allow)) block  {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    CTCellularDataRestrictedState state = cellularData.restrictedState;
    if (block) {
        switch (state) {
            case kCTCellularDataRestrictedStateUnknown: block(RXAuthorizationStatusNotDetermined, NO); break;
            case kCTCellularDataRestricted: block(RXAuthorizationStatusDenied, NO); break;
            case kCTCellularDataNotRestricted: block(RXAuthorizationStatusAuthorized, YES); break;
            default: break;
        }
    }
#endif
}

+ (void)canUseSiriAndSearch:(void(^)(RXAuthorizationStatus status, BOOL allow)) block  {
    if (@available(iOS 10.0, *)) {
        INSiriAuthorizationStatus status = [INPreferences siriAuthorizationStatus];
        if (block) {
            switch (status) {
                case INSiriAuthorizationStatusNotDetermined: {
                    [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
                        if (status == INSiriAuthorizationStatusAuthorized) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(RXAuthorizationStatusNotDetermined ,YES);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(RXAuthorizationStatusDenied, NO);
                            });
                        }
                    }];
                } break;
                case INSiriAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
                case INSiriAuthorizationStatusRestricted: block(RXAuthorizationStatusRestricted, NO); break;
                case INSiriAuthorizationStatusAuthorized: block(RXAuthorizationStatusAuthorized, YES); break;
                default:
                    break;
            }
        }
    }
}

+ (void)canUseBluetooth:(void(^)(RXAuthorizationStatus status, BOOL allow)) block  {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        CBPeripheralManagerAuthorizationStatus status = [CBPeripheralManager authorizationStatus];
    if (block) {
        switch (status) {
            case CBPeripheralManagerAuthorizationStatusNotDetermined: block(RXAuthorizationStatusNotDetermined, NO); break;
            case CBPeripheralManagerAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
            case CBPeripheralManagerAuthorizationStatusRestricted: block(RXAuthorizationStatusRestricted, NO); break;
            case CBPeripheralManagerAuthorizationStatusAuthorized: block(RXAuthorizationStatusAuthorized, YES); break;
            default: break;
        }
    }
#endif
}

+ (void)canUseEKEvent:(EKEntityType)type permission:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
    EKAuthorizationStatus ekAuthStatus = [EKEventStore authorizationStatusForEntityType:type];
    if (block) {
        if (ekAuthStatus == EKAuthorizationStatusNotDetermined) {
            EKEventStore *store = [[EKEventStore alloc] init];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                block(RXAuthorizationStatusNotDetermined, granted);
            }];
        } else if (ekAuthStatus == EKAuthorizationStatusRestricted) {
            block(RXAuthorizationStatusRestricted, NO);
        } else if (ekAuthStatus == EKAuthorizationStatusDenied) {
            block(RXAuthorizationStatusDenied, NO);
        } else {
            block(RXAuthorizationStatusAuthorized, YES);
        }
    }
}

+ (void)canUserSpeechRecognizer:(void(^)(RXAuthorizationStatus status, BOOL allow)) block {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    if (block) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusNotDetermined: {
                [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                    block(RXAuthorizationStatusNotDetermined, status == SFSpeechRecognizerAuthorizationStatusAuthorized);
                }];
            } break;
            case SFSpeechRecognizerAuthorizationStatusAuthorized: block(RXAuthorizationStatusAuthorized, YES); break;
            case SFSpeechRecognizerAuthorizationStatusRestricted: block(RXAuthorizationStatusRestricted, NO); break;
            case SFSpeechRecognizerAuthorizationStatusDenied: block(RXAuthorizationStatusDenied, NO); break;
            default: break;
        }
    }
#endif
}


+ (UIViewController*)currentAuthorizationController {
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else {
            break;
        }
    }
    return vc;
}

@end

@interface RXAuthorizationView ()

@property (weak, nonatomic) IBOutlet UILabel *authTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authDetailLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation RXAuthorizationView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bgView.layer.cornerRadius = 8.f;
    self.bgView.layer.masksToBounds = YES;
}

+ (void)showWithTitle:(NSString *)title Detail:(NSString *)detail {
    RXAuthorizationView * view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(RXAuthorization.class) owner:nil options:nil].firstObject;
    CGSize mainScreenSize = [UIScreen mainScreen].bounds.size;
    view.frame = CGRectMake(0, 0, mainScreenSize.width, mainScreenSize.height);
    view.authTitleLabel.text = title;
    view.authDetailLabel.text = detail;
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    [window.rootViewController.view addSubview:view];
}

- (IBAction)gotoSettingAction:(UIButton *)sender {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
#pragma clang diagnostic pop
    [self removeFromSuperview];
}

- (IBAction)ignoreBtnAction:(UIButton *)sender {
    [self removeFromSuperview];
}

@end
