//
//  FilesCell.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/11.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "FilesCell.h"
#import "ContentModel.h"
#import "FilesDownManage.h"

@interface FilesCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *DownBtn;


@end
@implementation FilesCell

- (void)awakeFromNib {
    // Initialization code
}



-(void)setModel:(ContentModel *)model
{
    _model = model;
    
    self.iconView.image = [UIImage imageNamed:model.iconUrl];
    self.titleLabel.text = model.title;
}


/**
 *  下载按钮被点击
 *
 *  @param sender 按钮
 */
- (IBAction)DownBtnClick:(UIButton *)sender {
    NSLog(@"---downUrl:%@",self.model.downUrl);
    self.DownBtn.hidden = YES;
    NSLog(@"-加入下载列表成功r-----");
     [[FilesDownManage sharedFilesDownManage]downFileUrl:self.model];
}



@end
