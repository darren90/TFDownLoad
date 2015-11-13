//
//  FileModel.h
//  MovieDownloadManager
//
//  Created by Fengtf on 15/11/4.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
 

typedef enum {//url类型
    FileUrlM3u8 = 1,     // m3u8下载链接
    FileUrlHttp = 2,     // http下载链接
} FileUrlType;

@interface FileModel : NSObject

/** 唯一 */
//@property (nonatomic, copy) NSString * uniquenName;//唯一;下载文件存储的的名字//XXX.mp4
@property (nonatomic, copy) NSString * title;
@property (nonatomic,copy)NSString * iconUrl;//剧照
@property (nonatomic,assign)BOOL isHadDown;//是否已经下载完毕 - 下载完毕要更新为YES
@property (nonatomic,assign)int urlType;//存储FileUrlType
 
@property(nonatomic,copy)NSString *fileName;//下载文件存储的的名字//XXX.mp4
@property(nonatomic,copy)NSString *fileSize;//总大小
@property(nonatomic,copy)NSString *fileReceivedSize;
@property(nonatomic,assign)BOOL isFirstReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
@property(nonatomic,copy)NSString *fileURL;
@property(nonatomic,assign)BOOL isDownloading;//是否正在下载
@property(nonatomic,assign)BOOL willDownloading;
@property(nonatomic,assign)BOOL error;

//@property(nonatomic,copy)NSString *time;
//@property(nonatomic,copy)NSString *targetPath;
//@property(nonatomic,copy)NSString *tempPath;

@end
