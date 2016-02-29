//
//  DownloadQueueController.h
//  DownloadViewController
//
//  Created by 李硕 on 16/2/24.
//  Copyright © 2016年 李硕. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DownloadOperation.h"

extern NSString *const DownloadQueueDidSuccessDownloadNotification;
extern NSString *const DownloadQueueDidFailureDownloadNotification;
extern NSString *const DownloadQueueWillRefreshProgressNotification;
extern NSString *const DownloadQueueUserInfoDownloadURLStringKey;
extern NSString *const DownloadQueueUserInfoDownloadDataKey;
extern NSString *const DownloadQueueUserInfoDownloadErrorKey;
extern NSString *const DownloadQueueUserInfoDownloadProgressKey;

@interface DownloadQueueController : NSObject
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *downloadOperationQueue;

+ (instancetype)sharedQueueController;

- (void)startDownload:(NSString *)URLString;
- (void)stopDownload:(NSString *)URLString;
- (void)redownload:(NSString *)URLString;
- (void)deleteDownload:(NSString *)URLString;

//管理器使用下面的方法
- (void)startAllDownloads;
- (void)stopAllDownloads;
- (void)deleteAllDownloads;


@end
