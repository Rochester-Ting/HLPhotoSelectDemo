//
//  AssetsGroupSelectView.h
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/15.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SelectAssetsGroupBlock)(ALAssetsGroup *group);

@interface HLAssetsGroupSelectView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *allAssetsGroups;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) SelectAssetsGroupBlock selectAssetsGroupBlock;

@end
