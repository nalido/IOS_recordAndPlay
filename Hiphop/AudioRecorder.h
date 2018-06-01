//
//  AudioRecorder.h
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/30.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "ZSJPathUtilities.h"
#import "AudioPlayer.h"

typedef struct AQCallbackStruct{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
    AudioFileID mOutputFile;
    
    unsigned int mFrameSize;
    long long mRecPtr;
    int mRun;
} AQCallbackStruct;

@interface AudioRecorder: NSObject {
    AQCallbackStruct aqc;
    AudioFileTypeID fileFormat;
    //long audioDataLength;
    //Byte audioByte[999999];
    //long audioDataIndex;
    NSFileHandle *pcmfileHandle;
}

/**
 初始化录音器
 
 @param pcmFileName 录音保存名称
 @param sample_rate 当前录音采用的采样率
 **/
- (id) init:(NSString*)pcmFileName sampleRate:(NSInteger)sample_rate;

- (void) start;
- (void) stop;
- (void) processAudioBuffer:(AudioQueueBufferRef)buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
//@property (nonatomic, assign) long audioDataLength;

@end
