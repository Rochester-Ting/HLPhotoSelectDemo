//
//  AlbumViewController.h
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SelectAssetsFinished)(NSArray *selectAssets);

@interface HLAlbumViewController : UIViewController

@property (nonatomic, copy) SelectAssetsFinished selectAssetsFinished;

//最大的选择数量
@property (nonatomic, assign) NSInteger maxSelectCount;

/**
 *  设置选中的相册,需要在跳转前传入
 *
 *  @param Assets 选中的assets
 */
- (void)setSelectAssets:(NSMutableArray *)selectAssets;

@end
