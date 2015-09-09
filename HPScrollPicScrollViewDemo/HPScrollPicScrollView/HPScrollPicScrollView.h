//
//  HPScrollPicScrollView.h
//  CloudBuyer
//
//  Created by CHENG DE LUO on 15/5/15.
//  Copyright (c) 2015年 CHENG DE LUO. All rights reserved.
//

//程序需求:
//1. 手势翻页, 并且更新pagecontrol当前下标
//2. 点击pagecontrol 滚动到对应下标的图片
//3. 支持网络图片和本地图片
//4. 自动播放
//
//6. 可控制参数:
//
//6.1.是否自动播放
//6.2.是否显示标题
//6.3.标题对齐方式
//6.3. 图片外边距
//6.5. pagecontrol 对齐方式
//6.6. 是否显示pagecontrol

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//对齐方式
typedef enum {
    HPAlignmentLeft = 0,
    HPAlignmentCenter = 1,
    HPAlignmentRight = 2
}HPAlignment;

@class HPScrollPicScrollView;
@protocol HPScrollPicScrollViewDelegate <NSObject>

//下标发生改变
@optional
- (void)hpScrollPicScrollView:(HPScrollPicScrollView *)hpScrollPicScrollView indexDidChange:(NSInteger)index;
//图片被点中
@optional
- (void)hpScrollPicScrollView:(HPScrollPicScrollView *)hpScrollPicScrollView picDidTapAtIndex:(NSInteger)index;

@end

//循环图片滚动视图



@interface HPScrollPicScrollView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;           //页控制
@property (nonatomic, strong) UIScrollView *scrollView;             //滚动视图
@property (nonatomic, strong) UILabel *titleLabel;                  //标题标签
@property (nonatomic, strong) NSMutableArray *imageViewArray;       //图片视图数组

@property (nonatomic, strong) NSArray *hpPicArray;                  //HP图片数组
@property (nonatomic, assign) id<HPScrollPicScrollViewDelegate> hpScrollPicScrollViewDelegate;

@property (nonatomic, assign) BOOL autoPlay;                        //是否自动播放
@property (nonatomic, assign) BOOL showPageControl;                 //是否是否显示pagecontrol
@property (nonatomic, assign) CGFloat picMargin;                    //图片外边距
@property (nonatomic, assign) HPAlignment pageControlAlignment;     //pagecontrol 对齐方式
@property (nonatomic, assign) CGFloat intervalTime;                 //轮播间隔时间
@property (nonatomic, assign) BOOL showTitle;                       //显示标题
@property (nonatomic, assign) HPAlignment titleLabelAlignment;      //标题标签对齐方式
@property (nonatomic, assign) UIViewContentMode imageContentMode;  //图片的填充方式
@property (nonatomic, strong) UIColor *imageViewBackgroundColor;        //图片视图背景颜色
@property (nonatomic, assign) NSInteger currentIndex;               //当前显示的下标

//初始化
- (void)setup;

//初始化参数
- (void)initConfig;

// - 根 - 滚动到指定下标 (不能调用其他getter方法, 避免循环调用)
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

@end
