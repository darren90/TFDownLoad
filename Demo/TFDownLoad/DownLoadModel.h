//
//  DownLoadModel.h
//  MovieBox
//
//  Created by Fengtf on 15/7/29.
//  Copyright (c) 2015年 rrmj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadModel : NSString

typedef enum {//下载类型
    UrlM3u8 = 1,     // m3u8下载链接
    UrlHttp = 2,     // http下载链接
} UrlType;

@property (nonatomic, copy) NSString * uniquenName;
@property (nonatomic, copy) NSString * title;
@property (nonatomic,assign) float size;
@property (nonatomic, strong) NSDate * addTime;
@property (nonatomic,copy)NSString * iconUrl;
/** m3u8 类型的下载地址 + http类型的下载地址 */
@property (nonatomic,copy)NSString * downUrl;

/** WebPlayUrl地址 */
@property (nonatomic,copy)NSString * webPlayUrl;

@property (nonatomic,assign)float progress;
/** 下载类型 存放DownLoadType */
@property (nonatomic,assign)int downType;
/** 下载的url类型，是http还是m3u8 */
@property (nonatomic,assign)int urlType;
/** 是否下载完毕 - 下载完毕要更新为YES */
@property (nonatomic,assign)BOOL isDowned;//
/** 地址是否是有效的 */
@property (nonatomic,assign)BOOL isInvalid;


/**
 *  视频质量,eg：height ; 
 */
@property (nonatomic,copy)NSString * quality;



@end
