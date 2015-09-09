//
//  ViewController.m
//  DragThumbnailBannerDemo
//
//  Created by CHENG DE LUO on 15/9/9.
//  Copyright (c) 2015年 CHENG DE LUO. All rights reserved.
//

#import "ViewController.h"
#import "HPScrollPicScrollView.h"
#import "HPPic.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = [UIScreen mainScreen].bounds;
    //测试
    HPScrollPicScrollView *pScrollView = [[ HPScrollPicScrollView alloc] initWithFrame:CGRectMake(0, 100, rect.size.width, rect.size.width *0.7)];
    pScrollView.backgroundColor = [UIColor purpleColor];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i ++) {
        HPPic *p1 = [[HPPic alloc] init];
        p1.isLocal = NO;
        if (i == 0) {
            p1.title = @"哈哈哈1";
            p1.image = [UIImage imageNamed:@"icon-balance.png"];
            p1.picUrl = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/zhidao/pic/item/562c11dfa9ec8a13e028c4c0f603918fa0ecc0e4.jpg"];
            
        } else if(i == 1) {
            p1.image = [UIImage imageNamed:@"icon-shoppingcart.png"];
            p1.picUrl = [NSURL URLWithString:@"http://img.xiaba.cvimage.cn/4cbc56c1a57e26873c140000.jpg"];
            p1.title = @"哈哈哈2";
        } else if(i == 2) {
            p1.image = [UIImage imageNamed:@"search.png"];
            p1.picUrl = [NSURL URLWithString:@"http://pic1.ooopic.com/uploadfilepic/sheji/2009-08-09/OOOPIC_SHIJUNHONG_20090809ad6104071d324dda.jpg"];
        } else if(i == 3) {
            p1.title = @"哈哈哈3";
            p1.image = [UIImage imageNamed:@"timeline_image_loading.png"];
            p1.picUrl = [NSURL URLWithString:@"http://img3.3lian.com/2006/013/02/062.jpg"];
        }
        [arr addObject:p1];
    }
    pScrollView.hpPicArray = arr;
    [self.view addSubview:pScrollView];
    pScrollView.showTitle = NO;
    pScrollView.showTitle = YES;
    //    pScrollView.imageContentMode = UIViewContentModeScaleAspectFit;
    pScrollView.titleLabelAlignment = HPAlignmentCenter;
    pScrollView.intervalTime = 5;
    //    pScrollView.picMargin = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
