//
//  FilesDownManage.h
//  MovieDownloadManager
//
//  Created by Fengtf on 15/11/4.
//  Copyright © 2015年 ftf. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CommonHelper.h"
#import "DownloadDelegate.h"
#import "FileModel.h"
//#import "DownLoadModel.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "ContentModel.h"

@interface FilesDownManage : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>
@property(nonatomic,weak)id<DownloadDelegate> VCdelegate;//获得下载事件的vc，用在比如多选图片后批量下载的情况，这时需配合 allowNextRequest 协议方法使用
@property(nonatomic,weak)id<DownloadDelegate> downloadDelegate;//下载列表delegate

@property(nonatomic,strong)NSMutableArray *finishedlist;//已下载完成的文件列表（文件对象:FileModel）
@property(nonatomic,strong)NSMutableArray *downinglist;//正在下载的文件列表(ASIHttpRequest对象)
@property(nonatomic,strong)NSMutableArray *filelist;
@property(nonatomic,strong)FileModel *fileInfo;

-(void)clearAllRquests;
-(void)clearAllFinished;
-(void)resumeRequest:(ASIHTTPRequest *)request;
-(void)deleteRequest:(ASIHTTPRequest *)request;
-(void)stopRequest:(ASIHTTPRequest *)request;
-(void)saveFinishedFile;
-(void)deleteFinishFile:(FileModel *)selectFile;

-(void)loadTempfiles;//将本地的未下载完成的临时文件加载到正在下载列表里,但是不接着开始下载
-(void)loadFinishedfiles;//将本地已经下载完成的文件加载到已下载列表里

+(FilesDownManage *) sharedFilesDownManage;
//＊＊＊第一次＊＊＊初始化是使用，设置缓存文件夹和已下载文件夹，构建下载列表和已下载文件列表时使用
+(FilesDownManage *) sharedFilesDownManageWithBasepath:(NSString *)basepath TargetPathArr:(NSArray *)targetpaths;



/**
 *  加入下载列表--进行下载
 *
 *  @param downLoadModel 传入模型进行下载
 */
-(void)downFileUrl:(ContentModel *)downLoadModel;

/**
 *  加入下载列表--进行下载
 *
 *  @param downUrl     下载的链接
 *  @param uniquenName 唯一的名字（保存文件用）
 *  @param title     列表展示用的名字（展示下载及已完成列表用）
 *  @param iconUrl     图片名字
 */
-(void)downFileUrl:(NSString *)downUrl fileName:(NSString *)fileName title:(NSString *)title iconUrl:(NSString *)iconUrl;



@end
 