//
//  FilesCell.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/11.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "FilesCell.h"

@interface FilesCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *DownBtn;


@end
@implementation FilesCell

- (void)awakeFromNib {
    // Initialization code
}

/**
 *  下载按钮被点击
 *
 *  @param sender 按钮
 */
- (IBAction)DownBtnClick:(UIButton *)sender {
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
