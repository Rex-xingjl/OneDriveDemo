//
//  FilesRestoreCell.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/18.
//

#import "FilesRestoreCell.h"

@implementation FilesRestoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)restoreBtnAction:(id)sender {
    if (self.restoreAction) {
        self.restoreAction();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
