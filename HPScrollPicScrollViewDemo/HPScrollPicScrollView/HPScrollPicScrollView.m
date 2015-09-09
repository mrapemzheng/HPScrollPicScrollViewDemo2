//
//  HPScrollPicScrollView.m
//  CloudBuyer
//
//  Created by CHENG DE LUO on 15/5/15.
//  Copyright (c) 2015年 CHENG DE LUO. All rights reserved.
//

//注意: 这里setter方法可能会有互相对用的风险, 所以逻辑要清晰些

#import "HPScrollPicScrollView.h"
#import "HPPic.h"
#import "UIView+Utils.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBA(rgbValue, a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

/**
 实际长度4
             0  1  2 3 4 5
 *  执行顺序是 3 4  |1| 234
 
 */

@interface HPScrollPicScrollView ()

@property (nonatomic, strong) NSTimer *scheduleTimer;                 //定时器 

@end

@implementation HPScrollPicScrollView

- (void)awakeFromNib
{
    [self initConfig];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initConfig];
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initConfig];
        [self setup];
    }
    return self;
}

//初始化
- (void)setup
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-self.picMargin, 0, self.width + (2 * self.picMargin), self.height)];
    [self addSubview:self.scrollView];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    //标题标签;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.height - 30), self.width, 30)];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = UIColorFromRGBA(0x000000, 0.4);
    [self addSubview:self.titleLabel];
    
    //页控制
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, (self.titleLabel.top - 30), self.width/3, 30)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.pageIndicatorTintColor = UIColorFromRGBA(0x000000, 0.3);
    self.pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0xa10602);
    [self addSubview:self.pageControl];
    
    //页控制监听
    [self.pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //设置排列方式
    self.pageControlAlignment = _pageControlAlignment;
    
    //是否显示页控制
    if (!self.showPageControl) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }
}

//初始化参数
- (void)initConfig
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    _autoPlay = YES;
    _showPageControl = YES;
    _picMargin = 0;
    _pageControlAlignment = HPAlignmentCenter;
    _intervalTime = 3;
    _currentIndex = 0;
    _imageViewBackgroundColor = [UIColor clearColor];
}

- (void)setHpPicArray:(NSArray *)hpPicArray
{

    self.imageViewArray = [NSMutableArray array];
    _hpPicArray = hpPicArray;
    
    //筛选
    if (!_hpPicArray || _hpPicArray.count == 0) {
        return;
    }
    
    HPPic *hpPic;
    UIImageView *iv;
    CGFloat width = self.scrollView.frame.size.width - (2 * self.picMargin);
    CGFloat height = self.scrollView.frame.size.height;
    CGFloat scrollViewWidth = self.scrollView.width;
    
    //图片
    NSInteger i = 0;
    NSInteger count = _hpPicArray.count + 2;
    while (i < count) {
        if(i == 0) {
            //倒数第二个
            hpPic = [self.hpPicArray objectAtIndex:(self.hpPicArray.count-1 -1)];
        }else if(i == 1){
            hpPic = [self.hpPicArray lastObject];
        } else {
            hpPic = [self.hpPicArray objectAtIndex:(i - 2)];
        }
        
        //设置标题
        if(i == 0) {
            self.titleLabel.text = hpPic.title;
        }
        
        iv = [[UIImageView alloc] initWithFrame:CGRectMake((width * i) + (self.picMargin * ((i * 2) + 1)), 0, width, height)];
        iv.backgroundColor = self.imageViewBackgroundColor;
        iv.clipsToBounds = YES;
        [hpPic getRealImageWithBlock:^(UIImage *image) {
            iv.image = image;
        } failueBlock:^(NSError *error) {
            
        }];
        
        //单击手势
        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidTap:)];
        [iv addGestureRecognizer:tap];
        
        [self.scrollView addSubview:iv];
        [self.imageViewArray addObject:iv];
        
        i ++;
    }
    self.scrollView.contentSize = CGSizeMake(scrollViewWidth * (_hpPicArray.count + 2), height);
    [self.scrollView setContentOffset:CGPointMake(scrollViewWidth * 2, 0) animated:NO];
    //页控制
    if (_hpPicArray.count > 1) {
        self.pageControl.numberOfPages = _hpPicArray.count;
    } else {
        self.pageControl.numberOfPages = 0;
    }
    
    //设置当前下标
    self.currentIndex = 0;
    
    //设置是否自动播放
    self.autoPlay = _autoPlay;
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    if (!_showPageControl) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }
}

- (void)setPageControlAlignment:(HPAlignment)pageControlAlignment
{
    _pageControlAlignment = pageControlAlignment;
    switch (_pageControlAlignment) {
        case HPAlignmentLeft:
            self.pageControl.left = 0;
            break;
        case HPAlignmentRight:
            self.pageControl.left = self.width - self.pageControl.width;
            break;
        case HPAlignmentCenter:
            self.pageControl.left = (self.width - self.pageControl.width)/2;
            break;
        default:
            self.pageControl.left = 0;
            break;
    }
}

- (void)setShowTitle:(BOOL)showTitle
{
    _showTitle = showTitle;
    if (_showTitle) {
        self.titleLabel.hidden = NO;
        self.pageControl.top = (self.titleLabel.top - self.pageControl.height);
    } else {
        self.titleLabel.hidden = YES;
        self.pageControl.top = (self.height - self.pageControl.height);
    }
}

- (void)setTitleLabelAlignment:(HPAlignment)titleLabelAlignment
{
    _titleLabelAlignment = titleLabelAlignment;
    switch (_titleLabelAlignment) {
        case HPAlignmentLeft:
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            break;
        case HPAlignmentRight:
            self.titleLabel.textAlignment = NSTextAlignmentRight;
            break;
        case HPAlignmentCenter:
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            break;
        default:
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            break;
    }
}

- (void)setAutoPlay:(BOOL)autoPlay
{
    _autoPlay = autoPlay;
    if(_autoPlay) {
        if (self.hpPicArray.count > 3) {
            self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:self.intervalTime target:self selector:@selector(scheduleTimeScrollToNextIndex) userInfo:nil repeats:YES];
        }
    } else {
        [self releaseScheduleTimer];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    //滚动到指定下标
    [self scrollToIndex:_currentIndex animated:YES];
}

- (void)setIntervalTime:(CGFloat)intervalTime
{
    _intervalTime = intervalTime;
    [self releaseScheduleTimer];
    if (self.autoPlay) {
        self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalTime target:self selector:@selector(scheduleTimeScrollToNextIndex) userInfo:nil repeats:YES];
    }
    
    
}

- (void)setPicMargin:(CGFloat)picMargin
{
    _picMargin = picMargin;
    self.scrollView.frame = CGRectMake(-_picMargin, 0, self.width + (2 * _picMargin), self.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * self.hpPicArray.count, self.scrollView.height);
    UIImageView *iv;
    CGFloat width = self.scrollView.frame.size.width - (2 * self.picMargin);
    CGFloat height = self.scrollView.frame.size.height;
    for (NSInteger i = 0;i < self.imageViewArray.count; i ++) {
        iv = [self.imageViewArray objectAtIndex:i];
        iv.frame = CGRectMake((width * i) + (self.picMargin * ((i * 2) + 1)), 0, width, height);
    }
}

- (void)setImageContentMode:(UIViewContentMode )imageContentMode
{
    _imageContentMode = imageContentMode;
    for (UIImageView *iv in self.imageViewArray) {
        iv.contentMode = _imageContentMode;
    }
}

// - 根 - 滚动到指定下标 (不能调用其他getter方法, 避免循环调用)
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
{
    //设置当前下标, 但不调用设置方法
    _currentIndex = index;
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * (index + 2), 0) animated:YES];
    
}


#pragma mark - UIScrollViewDelegate

/**
 *  人为,不包括setContent:animated或者scrollToRect:animated
 *
 *  @param scrollView scrollView
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self releaseScheduleTimer];
}

/**
 *  人为,不包括setContent:animated或者scrollToRect:animated
 *
 *  @param scrollView scrollView
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.hpPicArray.count > 3) {
        if (self.autoPlay) {
            self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:self.intervalTime target:self selector:@selector(scheduleTimeScrollToNextIndex) userInfo:nil repeats:YES];
        }
    }
}

/**
 *  人为,不包括setContent:animated或者scrollToRect:animated
 *
 *  @param scrollView scrollView
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //设置当前下标下的图片的标题
    HPPic *hpPic = [self.hpPicArray objectAtIndex:_currentIndex];
    self.titleLabel.text = hpPic.title;
    
    //发出委托
    if (self.hpScrollPicScrollViewDelegate && [self.hpScrollPicScrollViewDelegate respondsToSelector:@selector(hpScrollPicScrollView:indexDidChange:)]) {
        [self.hpScrollPicScrollViewDelegate hpScrollPicScrollView:self indexDidChange:_currentIndex];
    }
    
    //如果到最后一个,那么恢复到第2个
    if(self.scrollView.contentOffset.x == ((self.hpPicArray.count+1) * self.scrollView.width)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * 1, 0) animated:NO];
    //如果到第一个, 那么恢复到倒数第二个
    } else if(self.scrollView.contentOffset.x == 0) {
        [self.scrollView setContentOffset:CGPointMake(self.hpPicArray.count * self.scrollView.width , 0) animated:NO];
    }
    
}

/**
 *  所有位移都会触发
 *
 *  @return scrollView
 */
//基础滚动之后就会重新设置 当前下标
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    NSInteger positionIndex = contentOffsetX / scrollView.width;
    
    //设置当前下标, 但不调用设置方法
    //如果是第二个或者最后一个 - _currentIndex = 最后一个
    if(positionIndex == 1 || positionIndex == self.hpPicArray.count+1) {
        _currentIndex = (self.hpPicArray.count -1);
    //如果当前是第一个或者倒数第二个 _currentIndex = 倒数第二个
    } else if(positionIndex == 0 || positionIndex == self.hpPicArray.count){
        _currentIndex = self.hpPicArray.count-1 -1;
        
    //其他
    } else {
        _currentIndex = positionIndex - 2;
    }
    
    self.pageControl.currentPage = _currentIndex;
}

/**
 *  动画setContentOffset:之后就会触发
 *
 *  @return scrollView
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //设置当前下标下的图片的标题
    HPPic *hpPic = [self.hpPicArray objectAtIndex:_currentIndex];
    self.titleLabel.text = hpPic.title;
    
    //发出委托
    if (self.hpScrollPicScrollViewDelegate && [self.hpScrollPicScrollViewDelegate respondsToSelector:@selector(hpScrollPicScrollView:indexDidChange:)]) {
        [self.hpScrollPicScrollViewDelegate hpScrollPicScrollView:self indexDidChange:_currentIndex];
    }
    
    //如果到最后一个,那么恢复到第2个
    if(self.scrollView.contentOffset.x == ((self.hpPicArray.count+1) * self.scrollView.width)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * 1, 0) animated:NO];
        //如果到第一个, 那么恢复到倒数第二个
    } else if(self.scrollView.contentOffset.x == 0) {
        [self.scrollView setContentOffset:CGPointMake(self.hpPicArray.count * self.scrollView.width , 0) animated:NO];
    }
}

#pragma mark - private methods

//滚动定时器监听 - 滚动到下一个
- (void)scheduleTimeScrollToNextIndex
{
    if ((self.currentIndex + 1) >= self.hpPicArray.count) {
        self.currentIndex = 0;
    } else {
        _currentIndex ++;
        self.currentIndex = _currentIndex;
    }
}

//页控制值变化 (下标被改变)
- (void)pageControlValueChanged:(id)sender
{
    //重新设置定时器
    [self releaseScheduleTimer];
    if (self.autoPlay) {
        self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:self.intervalTime target:self selector:@selector(scheduleTimeScrollToNextIndex) userInfo:nil repeats:YES];
    }
    
    UIPageControl *pageControl = (UIPageControl *)sender;
    NSInteger currentPage = pageControl.currentPage;
    NSLog(@"currentPage=%ld", (long)currentPage);
    self.currentIndex = currentPage;
}

//图片被轻触
- (void)imageViewDidTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.hpScrollPicScrollViewDelegate && [self.hpScrollPicScrollViewDelegate respondsToSelector:@selector(hpScrollPicScrollView:picDidTapAtIndex:)]) {
        [self.hpScrollPicScrollViewDelegate hpScrollPicScrollView:self picDidTapAtIndex:_currentIndex];
    }
}

//释放滚动定时器
- (void)releaseScheduleTimer
{
    if (self.scheduleTimer) {
        [self.scheduleTimer invalidate];
        self.scheduleTimer = nil;
    }
}

@end
