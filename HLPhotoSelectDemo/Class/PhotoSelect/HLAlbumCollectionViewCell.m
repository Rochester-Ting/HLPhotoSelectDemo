//
//  AlbumCollectionViewCell.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLAlbumCollectionViewCell.h"

@implementation HLAlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    _albumImageView = [[UIImageView alloc] init];
    [self addSubview:_albumImageView];
    
    _selectStatuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectStatuButton setImage:[UIImage imageNamed:@"unSelected"] forState:UIControlStateNormal];
    [_selectStatuButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [self addSubview:_selectStatuButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _albumImageView.frame = self.bounds;
    _selectStatuButton.frame = CGRectMake(self.frame.size.width - 30, 0, 30, 30);
}

@end
