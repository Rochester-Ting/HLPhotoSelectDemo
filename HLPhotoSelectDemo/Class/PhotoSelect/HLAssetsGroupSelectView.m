//
//  AssetsGroupSelectView.m
//  HLPhotoSelectDemo
//
//  Created by lei.huang on 16/7/15.
//  Copyright © 2016年 len.wang. All rights reserved.
//

#import "HLAssetsGroupSelectView.h"

static NSString *cellID = @"UITableViewCell";
@implementation HLAssetsGroupSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 44;
    _tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allAssetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    ALAssetsGroup *assetsGroup = _allAssetsGroups[indexPath.row];
    cell.textLabel.text = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectAssetsGroupBlock) {
        _selectAssetsGroupBlock(_allAssetsGroups[indexPath.row]);
    }
}

@end
