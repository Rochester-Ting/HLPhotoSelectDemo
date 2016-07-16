//
//  AlbumViewController.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLAlbumViewController.h"
#import "HLAlbumCollectionViewCell.h"
#import "HLCameraCollectionViewCell.h"
#import "HLSelectedCollectionViewCell.h"
#import "HLAssetsGroupSelectView.h"
#import <AVFoundation/AVFoundation.h>
#import "HLAlbumLookViewController.h"

#define bottomHeight 49
#define middleItemSize ((CGRectGetWidth(self.view.frame) - 4 * 5) / 3)
#define bottomItemSize 40
#define SelectViewHeight (CGRectGetHeight(self.view.frame) - 64 - 49)

@interface HLAlbumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *middleCollectionView;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UICollectionView *bottomCollectionView;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) HLAssetsGroupSelectView *assetGroupSelectView;

//选中assets
@property (nonatomic, strong) NSMutableArray *selectAssets;
//所有的相册组
@property (nonatomic, strong) NSMutableArray *allAssetsGroups;
//当前所选相册组的所有assets
@property (nonatomic, strong) NSMutableArray *currentAssets;

//设备中的所有资源
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, strong) ALAssetsGroup *currentGroup;

@end


static NSString *albumCollectionViewCellID = @"HLAlbumCollectionViewCell";
static NSString *cameraCollectionViewCellID = @"HLCameraCollectionViewCell";
static NSString *selectedCollectionViewCellID = @"HLSelectedCollectionViewCell";

@implementation HLAlbumViewController

- (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_currentAssets.count && ![_currentAssets[0] isKindOfClass:[NSString class]]) {
        [_currentAssets insertObject:@"CameraString" atIndex:0];
    }
    
    [self reloadAllData];
}

- (void)initialize
{
    _selectAssets = [NSMutableArray array];
    _allAssetsGroups = [NSMutableArray array];
    _currentAssets = [NSMutableArray array];
}

- (void)initSubViews
{
    [self setUpNav];
    [self setUpCollectionView];
    [self setUpAssetGroupSelectView];
    [self setUpALAssetsLibrary];
}

- (void)setUpNav
{
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleButton.frame = CGRectMake(0, 0, 200, 40);

    [_titleButton setTitle:@"相册" forState:UIControlStateNormal];
    _titleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_titleButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [_titleButton setImage:[UIImage imageNamed:@"arrow_on"] forState:UIControlStateSelected];
    _titleButton.adjustsImageWhenHighlighted = NO;
    [_titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, 180, 0, 0)];
    [_titleButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(titleButtonClick:) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.titleView = _titleButton;
}

- (void)titleButtonClick:(UIButton *)titleButton
{
    titleButton.selected = !titleButton.isSelected;
    if (_assetGroupSelectView.frame.origin.y == 64) {
        [UIView animateWithDuration:0.5 animations:^{
            _assetGroupSelectView.frame = CGRectMake(0, -SelectViewHeight, _assetGroupSelectView.frame.size.width, SelectViewHeight);
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            _assetGroupSelectView.frame = CGRectMake(0, 64, _assetGroupSelectView.frame.size.width, SelectViewHeight);
        }];
    }
}

- (void)setUpCollectionView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - bottomHeight, self.view.frame.size.width, bottomHeight)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = CGRectMake(_bottomView.frame.size.width - 60 - 5, 0, 60, 30);
    CGPoint center = _finishButton.center;
    center.y = _bottomView.frame.size.height * 0.5;
    _finishButton.center = center;
    [_finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
    _finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_finishButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1]];
    [_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_finishButton];
    
    _bottomCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 70, _bottomView.frame.size.height)collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _bottomCollectionView.backgroundColor = [UIColor whiteColor];
    [_bottomView addSubview:_bottomCollectionView];
    
    _middleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - bottomHeight) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _middleCollectionView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    
    [_middleCollectionView registerClass:[HLAlbumCollectionViewCell class] forCellWithReuseIdentifier:albumCollectionViewCellID];
    [_middleCollectionView registerClass:[HLCameraCollectionViewCell class] forCellWithReuseIdentifier:cameraCollectionViewCellID];
    [_bottomCollectionView registerClass:[HLSelectedCollectionViewCell class] forCellWithReuseIdentifier:selectedCollectionViewCellID];
    
    _middleCollectionView.delegate = self;
    _middleCollectionView.dataSource = self;
    _bottomCollectionView.delegate = self;
    _bottomCollectionView.dataSource = self;
    [self.view addSubview:_bottomView];
    [self.view addSubview:_middleCollectionView];
}

- (void)setUpAssetGroupSelectView
{
    _assetGroupSelectView = [[HLAssetsGroupSelectView alloc] initWithFrame:CGRectMake(0, -SelectViewHeight, self.view.frame.size.width, SelectViewHeight)];
    _assetGroupSelectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_assetGroupSelectView];
    
    __weak typeof(self) weakSelf = self;
    __block typeof(_assetGroupSelectView) weakSelectView = _assetGroupSelectView;
    _assetGroupSelectView.selectAssetsGroupBlock = ^(ALAssetsGroup *assetsGroup){
        [weakSelf upDateCollectionData:assetsGroup];
        [UIView animateWithDuration:0.5 animations:^{
            weakSelectView.frame = CGRectMake(0, -weakSelectView.frame.size.height, weakSelectView.frame.size.width, weakSelectView.frame.size.height);
        }];
    };
}

- (void)upDateCollectionData:(ALAssetsGroup *)assetsGroup
{
    if (!_allAssetsGroups.count) return;
    if (_currentGroup == assetsGroup || !assetsGroup.numberOfAssets) return;
    NSString *groupName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    [_titleButton setTitle:groupName forState:UIControlStateNormal];
    [_currentAssets removeAllObjects];
    _currentGroup = assetsGroup;
    [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (!result) {
            *stop = YES;
            if (![_currentAssets[0] isKindOfClass:[NSString class]]) {
                [_currentAssets insertObject:@"CameraString" atIndex:0];
            }
            [self reloadAllData];
        }else{
            [_currentAssets addObject:result];
        }
    }];
    
}

- (void)setUpALAssetsLibrary
{
    _assetsLibrary = [self defaultAssetsLibrary];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (!group) {
            *stop = YES;
            [self upDateAllAssetsGroupsData];
        }else{
            [_allAssetsGroups addObject:group];
            NSString *gropuName = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([gropuName isEqualToString:@"Camera Roll"] || [gropuName isEqualToString:@"相机胶卷"]) {
                [self upDateCollectionData:group];
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)upDateAllAssetsGroupsData
{
    _assetGroupSelectView.allAssetsGroups = _allAssetsGroups;
    [_assetGroupSelectView.tableView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _middleCollectionView) {
        return _currentAssets.count;
    }else{
        return _selectAssets.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _middleCollectionView) {
        if (indexPath.row == 0) {
            HLCameraCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cameraCollectionViewCellID forIndexPath:indexPath];
            return cell;
        }else{
            HLAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:albumCollectionViewCellID forIndexPath:indexPath];
           NSInteger index = [self indexAtSelectAssetsFromCurrentAssetsIndex:indexPath.row];
            if (index == NSNotFound) {
                [cell.selectStatuButton setSelected:NO];
            }else{
                [cell.selectStatuButton setSelected:YES];
            }
            
            ALAsset *asset = _currentAssets[indexPath.row];
            cell.albumImageView.image = [UIImage imageWithCGImage:asset.thumbnail];
            cell.selectStatuButton.tag = indexPath.row;
            [cell.selectStatuButton addTarget:self action:@selector(selectStatuButtonClick:) forControlEvents:UIControlEventTouchDown];
            return cell;
        }
    }else{
        HLSelectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectedCollectionViewCellID forIndexPath:indexPath];
        ALAsset *asset = _selectAssets[indexPath.row];
        cell.selectImageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _middleCollectionView) {
        if (indexPath.row == 0) {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
                    UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的相机\n设置>隐私>相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alart show];
                    return ;
                }else{
                    UIImagePickerController *pickerVc = [[UIImagePickerController alloc] init];
                    pickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
                    pickerVc.delegate = self;
                    [self presentViewController:pickerVc animated:YES completion:nil];
                }
            }else
            {
                UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"摄像功能不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alart show];
                return ;
            }
            
        }else{
            HLAlbumLookViewController *vc = [[HLAlbumLookViewController alloc] init];
            [_currentAssets removeObjectAtIndex:0];
            vc.currentAssets = _currentAssets;
            vc.selectedAssets = _selectAssets;
            vc.currentIndex = indexPath.row - 1;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
    
        
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _middleCollectionView) {
        return CGSizeMake(middleItemSize, middleItemSize);
    }else{
        return CGSizeMake(bottomItemSize, bottomItemSize);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self upDateCollectionData:_currentGroup];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


- (void)selectStatuButtonClick:(UIButton *)selectStatuButton
{
    selectStatuButton.selected = !selectStatuButton.isSelected;
    if (selectStatuButton.isSelected) {
        if (_selectAssets.count == _maxSelectCount) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多选择%lu张图片", _maxSelectCount] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil] show];
            selectStatuButton.selected = NO;
        }else{
            [_selectAssets addObject:_currentAssets[selectStatuButton.tag]];
            
            [_bottomCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectAssets.count - 1 inSection:0]]];
        }
    }else{
        NSInteger i = [self indexAtSelectAssetsFromCurrentAssetsIndex:selectStatuButton.tag];
        if (i != NSNotFound) {
            [_selectAssets removeObjectAtIndex:i];
            [_bottomCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
        }
    }
    if (_selectAssets.count > 0){
        [_bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectAssets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }

    [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", _selectAssets.count] forState:UIControlStateNormal];
}

//根据currentassets的index来获取selectAssets中的index
- (NSInteger)indexAtSelectAssetsFromCurrentAssetsIndex:(NSInteger)index
{
     NSString *currentUrl = [[_currentAssets[index] valueForProperty:ALAssetPropertyAssetURL] absoluteString];
    for (NSInteger i = 0; i < _selectAssets.count; i++) {
        NSString *selectUrl = [[_selectAssets[i] valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        if ([selectUrl isEqualToString:currentUrl]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)reloadAllData
{
    [_middleCollectionView reloadData];
    [_bottomCollectionView reloadData];
    [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", _selectAssets.count] forState:UIControlStateNormal];
}

- (void)finishButtonClick
{
    if (_selectAssetsFinished) {
        _selectAssetsFinished(_selectAssets);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)setSelectAssets:(NSMutableArray *)selectAssets
{
    _selectAssets = [NSMutableArray arrayWithArray:selectAssets];
}

@end
