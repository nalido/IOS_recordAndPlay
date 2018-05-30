//
//  AudioPlayer.h
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/30.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "ZSJPathUtilities.h"

#define QUEUE_BUFFER_SIZE 4 //缓冲队列个数
#define EVERY_READ_LENGTH 1024 //每次读取长度
#define MIN_SIZE_PER_FRAME 3000 //每帧数据最小长度
// Audio Settings
#define kNumberBuffers      3
#define t_sample             SInt16
#define kSamplingRate       44100
#define kNumberChannels     1
#define kBitsPerChannels    (sizeof(t_sample) * 8)
#define kBytesPerFrame      (kNumberChannels * sizeof(t_sample))
//#define kFrameSize          (kSamplingRate * sizeof(t_sample))
#define kFrameSize          1000

@interface AudioPlayer : NSObject
{
    //音频参数
    AudioStreamBasicDescription audioDescription;
    //音频播放队列
    AudioQueueRef audioQueue;
    //音频缓存
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];
}

//直接播放数组
- (void)play:(Byte*)audioByte Length:(long)len;

//读取一个pcm文件并播放
- (void)readPcmAndPlay:(NSString*)pcmFileName;

- (void)stop;

@end
