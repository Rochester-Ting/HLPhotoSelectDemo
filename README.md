## HLPhotoSelectDemo
一个选择图片的Demo.

###功能:
*  支持设定最大选中图片数量
*  支持选择相册
*  可同时返回选中Asset和Images
*  支持点击选中图片返回选中Asset和Images,可自定义查看大图

###示例图:
![image](https://raw.githubusercontent.com/huanglei1926/HLPhotoSelectDemo/master/HLPhotoSelectDemo/Picture/Snip20160716_1.png)
![image](https://raw.githubusercontent.com/huanglei1926/HLPhotoSelectDemo/master/HLPhotoSelectDemo/Picture/Snip20160716_2.png)
![image](https://raw.githubusercontent.com/huanglei1926/HLPhotoSelectDemo/master/HLPhotoSelectDemo/Picture/Snip20160716_3.png)
![image](https://raw.githubusercontent.com/huanglei1926/HLPhotoSelectDemo/master/HLPhotoSelectDemo/Picture/Snip20160716_4.png)


###示例代码
```objective-c
    _selectImageView = [[HLSelectImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 200) MaxCount:3];
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

```
