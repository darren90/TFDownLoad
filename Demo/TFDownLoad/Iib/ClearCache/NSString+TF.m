//
//  NSString+TF.m
//  test
//
//  Created by Tengfei on 15/5/8.
//  Copyright (c) 2015年 tengfei. All rights reserved.
//

#import "NSString+TF.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *token = @"fashfkdashfjkldashfjkdashfjkdahsfjdasjkvcxnm%^&%^$&^uireqwyi1237281643";

@implementation NSString (TF)
- (NSString *)stableName
{
    NSString *str = [NSString stringWithFormat:@"%@%@", self, token];
    
    return [str MD5];
}

- (NSString *)MD5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}
#pragma  - mark  如何获取设备的总容量和可用容量
/**
 *  获取设备总容量
 */
+ (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}
/**
 *  获取设备可用容量
 */
+ (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

+(NSString *)getFileDownPath:(NSString *)fileName
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDir = [NSString stringWithFormat:@"%@/Downloads/%@", docPath,[fileName stableName]];
    return videoDir;
}

+(NSString *)getHttpDownedSize:(NSString *)fileName
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDir = [NSString stringWithFormat:@"%@/Downloads/complete/%@", docPath,fileName];
    return videoDir;
}

+(NSString *)getHttpDowningSize:(NSString *)fileName
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDir = [NSString stringWithFormat:@"%@/Downloads/Temp/%@", docPath,fileName];
    return videoDir;
}

/**
 *  获取下载速度
 *
 *  @return 速度值，大于M的话用KB，不大于用MB
 */
-(NSString *)getDownSpeed
{
    long long bytes = [self longLongValue] / 5;
    
    if(bytes < 1000)     // B
    {
        return [NSString stringWithFormat:@"%lldB/S", bytes];
    }
    else if(bytes >= 1000 && bytes < 1024 * 1024) // KB
    {
        return [NSString stringWithFormat:@"%.0fK/S", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)   // MB
    {
        return [NSString stringWithFormat:@"%.1fM/S", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.1fG/S", (double)bytes / (1024 * 1024 * 1024)];
    }
}
+(double)getFileSizeString:(float)size
{
    //    if(size>=1024*1024)//大于1M，则转化成M单位的字符串
    //    {
    //        return [NSString stringWithFormat:@"%1.1fM",size/1024/1024];
    //    }
    //    else if(size>=1024&&size<1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    //    {
    //        return [NSString stringWithFormat:@"%1.1fK",size/1024];
    //    }
    //    else if(size>0 && size<1024)//剩下的都是小于1K的，则转化成B单位
    //    {
    //        return [NSString stringWithFormat:@"%1.1fB",size];
    //    }else{
    //        return @"0B";
    //    }
    return size/1024/1024;
}


+(NSDictionary *)getHttpDownFilePath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* strVideo=[path stringByAppendingPathComponent:@"Downloads/complete"];;
    NSString* strVideoTmp=[path stringByAppendingPathComponent:@"Downloads/tmpVide"];
    NSFileManager *fm=[NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:strVideo]){
        [[NSFileManager defaultManager] createDirectoryAtPath:strVideo withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:strVideoTmp withIntermediateDirectories:YES attributes:nil error:nil];
    }
    fileName = [fileName stringByAppendingString:@".mp4"];
    strVideo = [strVideo stringByAppendingPathComponent:fileName];
    strVideoTmp = [strVideoTmp stringByAppendingPathComponent:fileName];
    
    return @{@"truePath" : strVideo,@"tempPath" : strVideoTmp};
}


#pragma mark - 根会format返回时间类型的字符串
/**
 *   根会format返回时间类型的字符串
 *
 *  @param date   时间
 *  @param format 格式化类型，比如：yyyy-MM-dd
 *
 *  @return 时间的字符串格式
 */
+(NSString *)timeStrWithDate:(NSDate *)date format:(NSString *)format
{
    if (format == nil || format.length == 0) {
        format = @"yyyy-MM-dd";
    }
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setDateFormat:format];
    [df setTimeZone:timeZone];
    return [df stringFromDate:date];
}
 
@end
