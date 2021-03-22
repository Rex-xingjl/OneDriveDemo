//
//  UserListCell.h
//  OneDriveDemo
//
//  Created by Rex on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *filesButton;

@property (nonatomic, copy) void (^signOutBtnBlock)(void);
@property (nonatomic, copy) void (^myFilesBtnBlock)(void);
@property (nonatomic, copy) void (^tapIconImageBlock)(void);

@end

NS_ASSUME_NONNULL_END
