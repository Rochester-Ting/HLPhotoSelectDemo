//
//  CameraCollectionViewCell.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLCameraCollectionViewCell.h"

@implementation HLCameraCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    _bottomLabel = [[UILabel alloc] init];
    _bottomLabel.text = @"拍摄照片";
    _bottomLabel.textAlignment = NSTextAlignmentCenter;
    _bottomLabel.font = [UIFont systemFontOfSize:15];
    _bottomLabel.textColor = [UIColor whiteColor];
    [self addSubview:_bottomLabel];
    
    _topImageView = [[UIImageView alloc] init];
    _topImageView.contentMode = UIViewContentModeCenter;
    _topImageView.image = [UIImage imageNamed:@"icon_camera"];
    [self addSubview:_topImageView];
    self.backgroundColor = [UIColor lightGrayColor];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    _bottomLabel.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30);
    _topImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 30);
}

@end
