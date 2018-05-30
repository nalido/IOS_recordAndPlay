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
    long audioDataLength;
    Byte audioByte[999999];
    long audioDataIndex;
    NSFileHandle *pcmfileHandle;
}

- (id) init:(NSString*)pcmFileName;
- (void) start;
- (void) stop;
- (Byte*) getBytes;
- (void) processAudioBuffer:(AudioQueueBufferRef)buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (nonatomic, assign) long audioDataLength;

@end
