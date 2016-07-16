//
//  AlbumLookViewController.h
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/15.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLAlbumLookViewController : UIViewController

@property (nonatomic, strong) UICollectionView *bottomCollectionView;
//当前所查看图片的相册
@property (nonatomic, copy) NSArray *currentAssets;
//被选中的图片
@property (nonatomic, strong) NSMutableArray *selectedAssets;
//当前查看图片的index
@property (nonatomic, assign) NSUInteger currentIndex;
@end
