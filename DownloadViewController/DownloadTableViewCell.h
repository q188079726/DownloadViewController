//
//  DownloadTableViewCell.h
//  DownloadViewController
//
//  Created by 李硕 on 16/2/25.
//  Copyright © 2016年 李硕. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadTableViewCellDelegate <NSObject>

- (void)downloadCellStartDownload:(NSString *)URLString;
- (void)downloadCellStopDownload:(NSString *)URLString;
- (void)downloadCellRestartDownload:(NSString *)URLString;

@end


@interface DownloadTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *progress;
@property (nonatomic, copy) NSString *URLString;

@property (nonatomic, weak) id <DownloadTableViewCellDelegate> delegate;
- (IBAction)restart:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;


@end
