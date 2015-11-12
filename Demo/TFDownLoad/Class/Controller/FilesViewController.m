//
//  FilesViewController.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/11.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "FilesViewController.h"
#import "FilesCell.h"
#import "ContentModel.h"

@interface FilesViewController ()

@property (nonatomic,strong)NSMutableArray * dataArray;

@end

@implementation FilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
 
    NSArray *urlArray = @[@"http://down.sandai.net/thunder7/Thunder_dl_7.9.41.5020.exe",@"http://xmp.down.sandai.net/kankan/XMPSetup_5.1.27.4361-video.exe",@"http://v.jxvdy.com/sendfile/a8nl9blXNHGe74A6_v5b6fjHXzPBcryX_YzfWEXhPLv16UvV69RvBbzG_ESteoSH-BLpedoOBnH0mAw4O7ksjBwv-s-Rtg",@"http://v.jxvdy.com/sendfile/TfVH4U3Ww6M0Hk6i61MwxDr8nsSNnGoOqfvryTXzAMBEXaa9vgARdC9D3Y44bctp2EM38Kx-_Day_fkfO8urAved-xh7Tw",@"http://down.sandai.net/mac/thunder_dl2.6.7.1706_Beta.dmg"];
    NSArray *iconArray = @[@"xunlei",@"kankan",@"qingchu",@"yiren",@"macXunlei"];
    NSArray *titleArray = @[@"迅雷7",@"迅雷看看",@"童年的味道",@"亿人上",@"mac迅雷"];
    NSArray *uniquenArray = @[@"xunlei7.exe",@"kankan.exe",@"tongnian.mp4",@"yifen.mp4",@"macXunlei.mp4"];
    
    for (int i = 0 ;i<urlArray.count;i++) {
        ContentModel *model = [[ContentModel alloc]init];
        model.downUrl = urlArray[i];
        model.iconUrl = iconArray[i];
        model.title = titleArray[i];
        model.uniquenName = uniquenArray[i];
        [self.dataArray addObject:model];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    //1,创建cell
//    static NSString *ID = @"filesCell";
//    FilesCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if(cell == nil){
//        cell = [[FilesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID ];
//    }
    //2,设置cell的数据
    FilesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filesCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}


-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
