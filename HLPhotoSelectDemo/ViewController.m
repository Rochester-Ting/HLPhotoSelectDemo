//
//  ViewController.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/14.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "ViewController.h"
#import "HLSelectImageView.h"

@interface ViewController ()

@property (nonatomic, strong) HLSelectImageView *selectImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    
    _selectImageView = [[HLSelectImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 200) MaxCount:5];
    
    //已选图片回调
    _selectImageView.selectPhotoFinishedAssets = ^(NSArray *photoAssets){
        NSLog(@"photoAssets----%@", photoAssets);
    };
    _selectImageView.selectPhotoFinishedImages = ^(NSArray *images){
        NSLog(@"images----%@", images);
    };
    
    //点击item回调
    _selectImageView.touchItemClickAssets = ^(NSArray *assets, NSInteger currentIndex){
        NSLog(@"assets----%@\n currentIndex----%ld", assets, currentIndex);
    };
    _selectImageView.touchItemClickImages = ^(NSArray *selectImages, NSInteger currentIndex){
        NSLog(@"selectImages----%@\n currentIndex----%ld", selectImages, currentIndex);
    };
    
    [self.view addSubview:_selectImageView];
    
    
    /**
     *  必须实现以下两行代码,否则可能会出现异常
     */
    self.automaticallyAdjustsScrollViewInsets = NO;
    _selectImageView.nav = self.navigationController;
}

@end
