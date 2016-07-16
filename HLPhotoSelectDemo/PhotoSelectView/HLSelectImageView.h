//
//  HLSelectImageView.h
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectPhotoFinishedImages)(NSArray *photoImages);
typedef void(^SelectPhotoFinishedAssets)(NSArray *photoAssets);
typedef void(^TouchItemClickImages)(NSArray *selectImages, NSInteger currentIndex);
typedef void(^TouchItemClickAssets)(NSArray *assets, NSInteger currentIndex);

@interface HLSelectImageView : UIView

/**
 *  已经选择的图片
 */
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) UICollectionView *collectionView;


//选择完成会回调此block
/**
 *  返回asset集合
 */
@property (nonatomic, copy) SelectPhotoFinishedAssets selectPhotoFinishedAssets;
/**
 *  返回image集合
 */
@property (nonatomic, copy) SelectPhotoFinishedImages selectPhotoFinishedImages;


//点击collectView的item会回调此block
/**
 *  点击返回当前选中image集合和选中index
 */
@property (nonatomic, copy) TouchItemClickImages touchItemClickImages;
/**
 *  点击返回当前已选asset集合和选中index
 */
@property (nonatomic, copy) TouchItemClickAssets touchItemClickAssets;

//设置最大选中数量,默认为10
@property (nonatomic, assign) NSInteger photoMaxCount;

//必须传入当前控制器的UINavigationController,否则无法跳转
@property (nonatomic, weak) UINavigationController *nav;

//初始化
- (instancetype)initWithFrame:(CGRect)frame MaxCount:(NSInteger)photoMaxCount;

@end
