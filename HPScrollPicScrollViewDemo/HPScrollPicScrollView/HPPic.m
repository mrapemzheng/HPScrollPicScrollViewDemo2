//
//  HPPic.m
//  CloudBuyer
//
//  Created by CHENG DE LUO on 15/5/15.
//  Copyright (c) 2015年 CHENG DE LUO. All rights reserved.
//

#import "HPPic.h"


@implementation HPPic

//获取图片 - 根据自身逻辑获取图片, 并在block中返回图片, 进度block中返回进度信息
- (void)getRealImageWithBlock:(void (^)(UIImage *image))block failueBlock:(void(^)(NSError *error))failueBlock
{
    if (self.isLocal) {
        block(self.image);
    } else {
        NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:self.picUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
        [NSURLConnection sendAsynchronousRequest:mutableURLRequest
       queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
           NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
           if (!error && responseCode == 200) {
               UIImage *_img = [[UIImage alloc] initWithData:data];
               self.image = _img;
               block(self.image);
           }else{
               failueBlock(error);
           }
       }];
    }
}

@end
