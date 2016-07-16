//
//  SelectedCollectionViewCell.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/15.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLSelectedCollectionViewCell.h"

@implementation HLSelectedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    _selectImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_selectImageView];
}

@end
