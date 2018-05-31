//
//  Mp3Info.h
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/31.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mp3Info: NSObject {
    @public
    NSString *album; //专辑名称
    NSString *title; //歌曲名称
    NSString *artist; //演唱者
    int sample_rate; //采样率
    int nb_channels; //声道数
    long duration; //时长, 以秒为单位
    long bit_rate; //比特率
    
    NSData *pic; //专辑图片
}

/**
 将所有信息转为字符串输出，一个信息一行
 **/
- (NSString*)getAllInfoString;

//- (NSString*)album; //专辑名称
//- (NSString*)title; //歌曲名称
//- (NSString*)artist; //演唱者
//- (int)sample_rate; //采样率
//- (int)nb_channels; //声道数
//- (NSData*)pic; //专辑图片

@end
