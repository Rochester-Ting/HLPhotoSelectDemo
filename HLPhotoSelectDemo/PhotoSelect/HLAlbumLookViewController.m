//
//  AlbumLookViewController.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/15.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLAlbumLookViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HLSelectedCollectionViewCell.h"

#define bottomHeight 49
@interface HLAlbumLookViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) UIScrollView *scrollView;
@end

static NSString *selectedCollectionViewCellID = @"HLSelectedCollectionViewCell";
@implementation HLAlbumLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setUpNav];
    [self initSubViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutScrollView];
}

- (void)setUpNav
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -5)];
    [btn setImage:[UIImage imageNamed:@"navUnSelected"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"navSelected"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(rightNavItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)initSubViews
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
    
    _bottomCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 70, _bottomView.frame.size.height)collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    _bottomCollectionView.backgroundColor = [UIColor whiteColor];
    _bottomCollectionView.delegate = self;
    _bottomCollectionView.dataSource = self;
    [_bottomCollectionView registerClass:[HLSelectedCollectionViewCell class] forCellWithReuseIdentifier:selectedCollectionViewCellID];
    [_bottomView addSubview:_bottomCollectionView];
    [_bottomView addSubview:_finishButton];
    [self.view addSubview:_bottomView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - bottomHeight)];
    _scrollView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    for (int i = 0; i < _currentAssets.count; i++) {
        UIImageView *imgV = [UIImageView new];
        ALAsset *asset = _currentAssets[i];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        imgV.image = [UIImage imageWithCGImage:representation.fullScreenImage];
        [_scrollView addSubview:imgV];
    }
    [self.view addSubview:_scrollView];
    
    NSInteger index = [self indexAtSelectAssetsFromCurrentAssetsIndex:_currentIndex];
    if (index == NSNotFound) {
        [self changeRightNavItem:NO];
    }else{
        [self changeRightNavItem:YES];
    }
    
    [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", (unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
}

- (void)layoutScrollView
{
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width * _currentAssets.count, _scrollView.frame.size.height);
    for (int i = 0; i < _currentAssets.count; i++) {
        UIView *subView = _scrollView.subviews[i];
        if ([subView isKindOfClass:[UIImageView class]]) {
            subView.frame = CGRectMake(i * self.view.frame.size.width, 0, self.view.frame.size.width, _scrollView.frame.size.height);
        }
    }
    CGFloat offsetX = self.view.frame.size.width * _currentIndex;
    [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
}


- (NSInteger)indexAtSelectAssetsFromCurrentAssetsIndex:(NSInteger)index
{
    NSString *currentUrl = [[_currentAssets[index] valueForProperty:ALAssetPropertyAssetURL] absoluteString];
    for (NSInteger i = 0; i < _selectedAssets.count; i++) {
        NSString *selectUrl = [[_selectedAssets[i] valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        if ([selectUrl isEqualToString:currentUrl]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)changeRightNavItem:(BOOL)isSelected
{
    UIButton *btn = self.navigationItem.rightBarButtonItem.customView;
    
    [btn setSelected:isSelected];
}

- (void)rightNavItemAction:(UIButton *)rightBtn
{
    rightBtn.selected = !rightBtn.isSelected;
    if (rightBtn.isSelected) {
        [_selectedAssets addObject:self.currentAssets[_currentIndex]];
        [_bottomCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0]]];
    }else{
        NSInteger index = [self indexAtSelectAssetsFromCurrentAssetsIndex:_currentIndex];
        [_selectedAssets removeObjectAtIndex:index];
        [_bottomCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    }
    
    if (_selectedAssets.count) {
        [_bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
    [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", (unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_bottomCollectionView == scrollView) return;
    _currentIndex = (scrollView.contentOffset.x / CGRectGetWidth(self.view.frame));
    
    NSInteger index = [self indexAtSelectAssetsFromCurrentAssetsIndex:_currentIndex];
    if (index == NSNotFound) {
        [self changeRightNavItem:NO];
    }else{
        [self changeRightNavItem:YES];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HLSelectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectedCollectionViewCellID forIndexPath:indexPath];
    
    // 取缩略图
    ALAsset *asset = _selectedAssets[indexPath.row];
    cell.selectImageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(40, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (void)finishButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
