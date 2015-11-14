//
//  NSString+TF.h
//  test
//
//  Created by Tengfei on 15/5/8.
//  Copyright (c) 2015年 tengfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TF)
/**
 *  @return MD5加密的字符串
 */
- (NSString *)stableName;

/**
 *  @return 32位MD5加密结果
 */
- (NSString *)MD5;



/**
 *  获取设备总容量
 */
+ (NSNumber *)totalDiskSpace;
/**
 *  获取设备可用容量
 */
+ (NSNumber *)freeDiskSpace;


+(NSString *)getFileDownPath:(NSString *)fileName;

+(NSString *)getHttpDowningSize:(NSString *)fileName;
+(NSString *)getHttpDownedSize:(NSString *)fileName;

/**
 *  获取下载速度
 *
 *  @return 速度值，大于M的话用KB，不大于用MB
 */
-(NSString *)getDownSpeed;


/**
 *  得出已经下载的文件大小
 *
 *  @param size 传入的值
 *
 *  @return 返回带有M/K等的字段
 */
+(double)getFileSizeString:(float)size;


+(NSDictionary *)getHttpDownFilePath:(NSString *)fileName;



#pragma mark - 取出html的标签
/**
 *  替换html标签
 *
 *  @param commentContent 要替换的内容
 *
 *  @return 替换后没有html标签的内容
 */
+(NSString *)replaceHtmlTag:(NSString *)commentContent;



#pragma mark - 根会format返回时间类型的字符串
/**
 *   根会format返回时间类型的字符串
 *
 *  @param date   时间
 *  @param format 格式化类型，比如：yyyy-MM-dd
 *
 *  @return 时间的字符串格式
 */
+(NSString *)timeStrWithDate:(NSDate *)date format:(NSString *)format;

/**
 *  除掉字符串里面的换行符
 */
- (NSString *)replaceEnterString:(NSString *)str;

/**
 *  根据mp4地址得到m3u8地址
 *
 *  @param url mp4的地址
 *
 *  @return m3u8的地址
 */
+(NSString *)getM3u8Url:(NSString *)url;

@end












