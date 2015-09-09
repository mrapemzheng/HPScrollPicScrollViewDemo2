//
//  HPPic.h
//  CloudBuyer
//
//  Created by CHENG DE LUO on 15/5/15.
//  Copyright (c) 2015年 CHENG DE LUO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//HP图片类

@interface HPPic : NSObject

@property (nonatomic, strong) NSURL *picUrl;                    //图片统一资源定位符
@property (nonatomic, strong) UIImage *image;                   //图片对象
@property (nonatomic, strong) UIImage *placeholderImage;        //占位符图片
@property (nonatomic, assign) BOOL isLocal;                     //是否本地图片
@property (nonatomic, strong) NSString *title;                  //标题

//获取图片 - 根据自身逻辑获取图片
- (void)getRealImageWithBlock:(void (^)(UIImage *image))block failueBlock:(void(^)(NSError *error))failueBlock;

@end
