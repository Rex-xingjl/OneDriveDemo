//
//  FilesRestoreCell.h
//  OneDriveDemo
//
//  Created by Rex on 2021/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilesRestoreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@property (nonatomic, copy) void (^restoreAction)(void);

@end

NS_ASSUME_NONNULL_END
