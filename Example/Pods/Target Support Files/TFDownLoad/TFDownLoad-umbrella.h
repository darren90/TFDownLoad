#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TFDownloadManager.h"
#import "TFDownloadManager.m"
#import "TFDownloadModel.h"
#import "TFDownloadModel.m"

FOUNDATION_EXPORT double TFDownLoadVersionNumber;
FOUNDATION_EXPORT const unsigned char TFDownLoadVersionString[];

