//
//  HLSelectImageView.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLSelectImageView.h"
#import "HLSelectImageCollectionCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HLAlbumViewController.h"

static NSString *selectImageId = @"HLSelectImageCollectionCell";
@interface HLSelectImageView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CGFloat itemW;
@property (nonatomic, assign) CGFloat itemH;
@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIView *selectImageView;
@property (nonatomic, strong) UILabel *numLabel;

@end

@implementation HLSelectImageView

- (instancetype)initWithFrame:(CGRect)frame MaxCount:(NSInteger)photoMaxCount
{
    if (self = [super initWithFrame:frame]) {
        _photoMaxCount = photoMaxCount;
        _selectedPhotos = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        [self setUpCollectionViewWithFrame:frame];
    }
    return self;
}

- (void)setUpCollectionViewWithFrame:(CGRect)rect {
    
    _margin = 10;
    _itemW = 92;
    _itemH = rect.size.height - 30 - 30;
    
    _selectedPhotos = [NSMutableArray array];
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.itemSize = CGSizeMake(_itemW, _itemH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    [_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height - 30) collectionViewLayout:_layout];
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 20, 10);
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_collectionView];
    [_collectionView registerClass:[HLSelectImageCollectionCell class] forCellWithReuseIdentifier:selectImageId];
    
    _numLabel = [[UILabel alloc] init];
    _numLabel.frame = CGRectMake(0, rect.size.height - 20, 50, 14);
    CGPoint center = _numLabel.center;
    center.x = self.center.x;
    _numLabel.center = center;
    
    _numLabel.text = [NSString stringWithFormat:@"%zd/%ld", _selectedPhotos.count, (long)_photoMaxCount];
    _numLabel.font = [UIFont systemFontOfSize:14];
    _numLabel.textAlignment = NSTextAlignmentCenter;
    _numLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [self addSubview:_numLabel];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HLSelectImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectImageId forIndexPath:indexPath];
    if (indexPath.row == _selectedPhotos.count) {
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.image = [UIImage imageNamed:@"hdsq_icon_tiezi_jiahao"];
        cell.deleteBtn.hidden = YES;
    }else{
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        //获取缩略图
        ALAsset *asset = _selectedPhotos[indexPath.row];
        CGImageRef thumImage = [asset thumbnail];
        UIImage *image = [UIImage imageWithCGImage:thumImage];
        cell.imageView.image = image;
        cell.deleteBtn.hidden = NO;
    }
     cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    _numLabel.text = [NSString stringWithFormat:@"%zd/%ld", _selectedPhotos.count, (long)_photoMaxCount];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedPhotos.count) {
        [self addPhotoClick];
    }else{
        NSMutableArray *fullImagesArray = [NSMutableArray array];
        for (ALAsset *asset in _selectedPhotos) {
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            CGImageRef fullImage = [representation fullResolutionImage];
            UIImage *image = [UIImage imageWithCGImage:fullImage];
            [fullImagesArray addObject:image];
        }
        if (_touchItemClickImages) {
            _touchItemClickImages(fullImagesArray, indexPath.row);
        }
        if (_touchItemClickAssets) {
            _touchItemClickAssets(_selectedPhotos, indexPath.row);
        }
    }
}

//点击删除按钮
- (void)deleteBtnClik:(UIButton *)deleteBtn
{
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:deleteBtn.tag inSection:0];
        [_selectedPhotos removeObjectAtIndex:deleteBtn.tag];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}

//点击添加按钮
- (void)addPhotoClick
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        //无权限
        UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的相册\n设置>隐私>照片" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alart show];
        return ;
    } else {
        //有权限
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            HLAlbumViewController *albumVc = [[HLAlbumViewController alloc] init];
            albumVc.maxSelectCount = (_photoMaxCount == 0) ? 10 : _photoMaxCount;
            [albumVc setSelectAssets:_selectedPhotos];
            
            albumVc.selectAssetsFinished = ^(NSArray *selectAssets){
                _selectedPhotos = [NSMutableArray arrayWithArray:selectAssets];

                _collectionView.contentSize = CGSizeMake((_selectedPhotos.count + 1 ) * (_margin + _itemW), 0);
                [_collectionView reloadData];
                if (_selectPhotoFinishedAssets) {
                    _selectPhotoFinishedAssets(selectAssets);
                }
                
                if (_selectPhotoFinishedImages) {
                    NSMutableArray *selectImages = [NSMutableArray array];
                    for (ALAsset *asset in selectAssets) {
                        ALAssetRepresentation* representation = [asset defaultRepresentation];
                        CGImageRef fullImage = [representation fullResolutionImage];
                        UIImage *image = [UIImage imageWithCGImage:fullImage];
                        [selectImages addObject:image];
                    }
                    _selectPhotoFinishedImages(selectImages);
                }
            };
            
            [_nav pushViewController:albumVc animated:YES];
        }
    }
}


@end
