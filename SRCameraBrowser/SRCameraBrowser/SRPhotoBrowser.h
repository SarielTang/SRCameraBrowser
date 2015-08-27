//
//  SRPhotoBrowser.h
//  SRCameraBrowser
//
//  Created by SarielTang on 15/8/26.
//  Copyright (c) 2015年 Sariel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRPhotoBrowser;
@protocol SRPhotoBrowserDelegate <NSObject>
- (void)didSelectSomePhotos:(SRPhotoBrowser *)vc photos:(NSArray *)photos thumbs:(NSArray *)thumbs;

@end

@interface SRPhotoBrowser : UIViewController

@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, weak) id<SRPhotoBrowserDelegate> delegate;

@end
