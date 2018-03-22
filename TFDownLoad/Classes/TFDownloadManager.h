//
//  TFDownloadManager.h
//  FBSnapshotTestCase
//
//  Created by Fengtf on 2018/3/22.
//

#import <Foundation/Foundation.h>
#import "TFDownloadModel.h"

// 下载代理
@protocol TFDownloadDelegate <NSObject>

// 更新下载进度
- (void)downloadModel:(TFDownloadModel *)downloadModel didUpdateProgress:(TFDownloadProgress *)progress error:(NSError *)error;

// 下载完毕
- (void)downloadDidCompleted:(TFDownloadModel *)downloadModel;

@end


@interface TFDownloadManager : NSObject


// 下载中 + 等待中的模型 只读
@property (nonatomic, strong,readonly) NSMutableArray<TFDownloadModel *> *downloadAllModels;

// 下载代理
@property (nonatomic,weak) id<TFDownloadDelegate> delegate;

// 单例
+ (TFDownloadManager *)manager;

// 开始下载
- (void)startDownload:(TFDownloadModel *)downloadModel;

// 恢复下载（除非确定对这个model进行了suspend，否则使用start）
- (void)resumeDownload:(TFDownloadModel *)downloadModel;

// 恢复全部的下载任务
- (void)resumeAllTasks;

// 暂停下载
- (void)suspendload:(TFDownloadModel *)downloadModel;

// 暂停所有的下载
-(void)suspendAllTasks;

// 等待下载
//- (void)waitDownload:(TFDownloadModel *)downloadModel;

// 删除下载
- (void)deleteDownload:(TFDownloadModel *)downloadModel;

// 批量删除
- (void)deleteDownloads:(NSArray *)array;

// 删除所有的下载
-(void)deleteAllTasks;

//开启下载引擎
-(void)startEngine;

@end
