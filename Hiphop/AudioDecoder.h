//
//  AudioDecoder.h
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/29.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSJTranscode_AAC.h"
#import "ZSJPathUtilities.h"

@interface AudioDecoder : NSObject

/**
 将音乐文件转换为aac文件
 
 @param inputName 需要转化编码的文件名
 @param AACFileName 输出文件名(*.aac)
 **/
+ (void)transcodeFrom:(NSString*)inputName toAAC:(NSString*)AACFileName;

/**
 解码mp3文件获取pcm数据并以指定文件名保存
 
 @param mp3FileName mp3文件名
 @param pcmFileName pcm文件名
 **/
+ (void)convertMP3:(NSString*)mp3FileName toPCM:(NSString*)pcmFileName;

/**
 为每个AAC ES流生成ADTS头部数据， 添加头部后aac文件才可以播放
 可以理解为aac帧头
 
 @param packetLength 当前ES流的长度， 即帧长度
 **/
//+ (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength;

@end
