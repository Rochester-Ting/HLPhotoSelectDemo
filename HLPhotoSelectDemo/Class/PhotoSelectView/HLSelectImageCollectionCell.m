//
//  HLSelectImageCollectionCell.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLSelectImageCollectionCell.h"

@implementation HLSelectImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUpImageView];
        [self setUpDeleteBtn];
        [self setUpLayer];
    }
    return self;
}

- (void)setUpImageView
{
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imageView];
    self.clipsToBounds = YES;
}

- (void)setUpDeleteBtn
{
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setImage:[UIImage imageNamed:@"hdsq_btn_tiezi_close"] forState:UIControlStateNormal];
    _deleteBtn.imageView.contentMode = UIViewContentModeTopRight;
    
    _deleteBtn.frame = CGRectMake(self.bounds.size.width - 25, 0, 25, 25);
    [self addSubview:_deleteBtn];
}

- (void)setUpLayer
{
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor darkGrayColor].CGColor;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    border.frame = self.bounds;
    border.lineWidth = 1.f;
    border.lineCap = @"square";
    border.lineDashPattern = @[@4, @2];
    [self.layer addSublayer:border];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end
