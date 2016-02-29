//
//  MD5.m
//  DownloadManager
//
//  Created by 李硕 on 16/2/22.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import "MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)
//md5 32位 加密
- (NSString *)MD5String {
    const char *cstring = self.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);
    
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", bytes[i]];
    }
    return md5String;
}

@end
