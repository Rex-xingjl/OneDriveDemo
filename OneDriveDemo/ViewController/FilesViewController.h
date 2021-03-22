//
//  FilesViewController.h
//  OneDriveDemo
//
//  Created by Rex on 2021/3/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilesViewController : UIViewController

@property (nonatomic, strong) NSString * token;

@property (nonatomic, strong) NSString * driveItemId;

@property (nonatomic, strong) NSString * rootId;

@end

NS_ASSUME_NONNULL_END
