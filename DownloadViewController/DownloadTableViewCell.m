//
//  DownloadTableViewCell.m
//  DownloadViewController
//
//  Created by 李硕 on 16/2/25.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import "DownloadTableViewCell.h"

@implementation DownloadTableViewCell

- (IBAction)restart:(id)sender {
    if ([self.delegate respondsToSelector:@selector(downloadCellRestartDownload:)]) {
        [self.delegate downloadCellRestartDownload:self.URLString];
    }
}

- (IBAction)start:(id)sender {
    if ([self.delegate respondsToSelector:@selector(downloadCellStartDownload:)]) {
        [self.delegate downloadCellStartDownload:self.URLString];
    }
}

- (IBAction)stop:(id)sender {
    if ([self.delegate respondsToSelector:@selector(downloadCellStopDownload:) ]) {
        [self.delegate downloadCellStopDownload:self.URLString];
    }
}    

@end
