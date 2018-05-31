//
//  AudioRecorder.mm
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/30.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import "AudioRecorder.h"

@implementation AudioRecorder
@synthesize aqc;
//@synthesize audioDataLength;

static void AQInputCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer,
                            const AudioTimeStamp *inStartTime, unsigned int inNumPackets,
                            const AudioStreamPacketDescription* inPacketDesc) {
    AudioRecorder *engine = (__bridge AudioRecorder*)inUserData;
    if(inNumPackets > 0){
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }
    
    if(engine.aqc.mRun){
        AudioQueueEnqueueBuffer(engine.aqc.mQueue, inBuffer, 0, nil);
    }
}

- (id) init:(NSString*)pcmFileName{
    self = [super init];
    if(self){
        //pcm文件保存路径
        NSString *docDir = [ZSJPathUtilities documentsPath];
        NSString *pcmPath = [docDir stringByAppendingPathComponent:pcmFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:pcmPath error:nil];
        [fileManager createFileAtPath:pcmPath contents:nil attributes:nil];
        pcmfileHandle = [NSFileHandle fileHandleForWritingAtPath:pcmPath];
        
        aqc.mDataFormat.mSampleRate = kSamplingRate;
        aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormat.mFramesPerPacket = 1;
        aqc.mDataFormat.mChannelsPerFrame = kNumberChannels;
        aqc.mDataFormat.mBitsPerChannel = kBitsPerChannels;
        aqc.mDataFormat.mBytesPerPacket = kBytesPerFrame;
        aqc.mDataFormat.mBytesPerFrame = kBytesPerFrame;
        aqc.mFrameSize = kFrameSize;
        
        AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void*)(self), nil, nil, 0, &aqc.mQueue);
        
        for(int i=0; i<kNumberBuffers; i++){
            AudioQueueAllocateBuffer(aqc.mQueue, aqc.mFrameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.mQueue, aqc.mBuffers[i], 0, nil);
        }
        aqc.mRecPtr = 0;
        aqc.mRun = 1;
    }
    //audioDataIndex = 0;
    return self;
}

- (void) dealloc {
    AudioQueueStop(aqc.mQueue, true);
    aqc.mRun = 0;
    AudioQueueDispose(aqc.mQueue, true);
}

- (void) start {
    AudioQueueStart(aqc.mQueue, nil);
}

- (void) stop {
    AudioQueueStop(aqc.mQueue, true);
}

- (void) pause {
    AudioQueuePause(aqc.mQueue);
}

//- (Byte*) getBytes {
//    return audioByte;
//}

- (void) processAudioBuffer:(AudioQueueBufferRef)buffer withQueue:(AudioQueueRef)queue {
    NSLog(@"processAudioData: %d", buffer->mAudioDataByteSize);
    
    //memcpy(audioByte+audioDataIndex, buffer->mAudioData, buffer->mAudioDataByteSize);
    //audioDataIndex += buffer->mAudioDataByteSize;
    //audioDataLength = audioDataIndex;
    
    //写入pcm数据
    NSData *data = [NSData dataWithBytes:buffer->mAudioData length:buffer->mAudioDataByteSize];
    [pcmfileHandle writeData:data];
}

@end








