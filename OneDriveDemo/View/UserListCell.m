//
//  UserListCell.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/4.
//

#import "UserListCell.h"

@implementation UserListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
    [self.iconImageView addGestureRecognizer:tap];
    self.iconImageView.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tapImageAction:(id)sender {
    if (self.tapIconImageBlock) {
        self.tapIconImageBlock();
    }
}

- (IBAction)signOutButtonAction:(id)sender {
    if (self.signOutBtnBlock) {
        self.signOutBtnBlock();
    }
}

- (IBAction)myFilesButtonAction:(id)sender {
    if (self.myFilesBtnBlock) {
        self.myFilesBtnBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
