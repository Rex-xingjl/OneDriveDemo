//
//  FolderSelectController.h
//  OneDriveDemo
//
//  Created by Rex on 2021/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FolderSelectController : UIViewController

@property (nonatomic, strong) NSString * token;

// 当前处于的driveItem
@property (nonatomic, strong) NSString * driveItemId;

// 来自哪个driveItem发起的选择
@property (nonatomic, strong) NSString * fromDriveItemId;

// 选择完成的回调
@property (nonatomic, copy) void (^selectFolderDone)(NSString * driveItemId);

@end

NS_ASSUME_NONNULL_END
