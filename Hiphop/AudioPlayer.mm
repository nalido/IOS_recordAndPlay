//
//  AudioPlayer.mm
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/30.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import "AudioPlayer.h"

@interface AudioPlayer()
{
    Byte *audioByte;
    long audioDataIndex;
    long audioDataLength;
}
@end

@implementation AudioPlayer

//回调函数
static void bufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer) {
    NSLog(@"processAudioData: %u", (unsigned int)buffer->mAudioDataByteSize);
    
    AudioPlayer* player = (__bridge AudioPlayer*)inUserData;
    [player fillBuffer:inAQ queueBuffer:buffer];
}

//读取缓存数据
- (void)fillBuffer:(AudioQueueRef)queue queueBuffer:(AudioQueueBufferRef)buffer {
    if(audioDataIndex + EVERY_READ_LENGTH < audioDataLength){
        memcpy(buffer->mAudioData, audioByte + audioDataIndex, EVERY_READ_LENGTH);
        audioDataIndex += EVERY_READ_LENGTH;
        buffer->mAudioDataByteSize = EVERY_READ_LENGTH;
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }
    else if(audioDataIndex < audioDataLength){ //剩余数据量不足最小限制时
        long len = audioDataLength - audioDataIndex;
        memcpy(buffer->mAudioData, audioByte + audioDataIndex, len);
        audioDataIndex += len;
        buffer->mAudioDataByteSize = (UInt32)len;
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }
}

- (void)setAudioFormat {
    //设置音频参数
    audioDescription.mSampleRate = kSamplingRate;
    audioDescription.mFormatID = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    audioDescription.mChannelsPerFrame = kNumberChannels;
    audioDescription.mFramesPerPacket = 1; //每一个packet一帧数据
    audioDescription.mBitsPerChannel = kBitsPerChannels; //采样深度
    audioDescription.mBytesPerFrame = kBytesPerFrame;
    audioDescription.mBytesPerPacket = kBytesPerFrame;
    
    [self createAudioQueue];
}

- (void)createAudioQueue {
    [self cleanUp];
    
    //使用AudioPlayer内部线程播放
    AudioQueueNewOutput(&audioDescription, bufferCallback, (__bridge void*)(self), nil, nil, 0, &audioQueue);
    if(audioQueue){
        //添加buffer区
        for(int i=0; i<QUEUE_BUFFER_SIZE; i++){
            int result = AudioQueueAllocateBuffer(audioQueue, EVERY_READ_LENGTH, &audioQueueBuffers[i]);
            NSLog(@"AudioQueueAllocateBuffer i = %d, result = %d", i, result);
        }
    }
}

- (void)cleanUp {
    if(audioQueue) {
        NSLog(@"Release AudioQueueNewOutput");
        
        [self stop];
        for(int i=0; i<QUEUE_BUFFER_SIZE; i++){
            AudioQueueFreeBuffer(audioQueue, audioQueueBuffers[i]);
            audioQueueBuffers[i] = nil;
        }
        audioQueue = nil;
    }
}

- (void)stop {
    NSLog(@"Audio Player Stop");
    
    AudioQueueFlush(audioQueue);
    AudioQueueReset(audioQueue);
    AudioQueueStop(audioQueue, TRUE);
}

- (void)play:(Byte*)byte Length:(long)len {
    [self stop];
    audioByte = byte;
    audioDataLength = len;
    
    NSLog(@"Audio Play Start >>>>>>");
    
    AudioQueueReset(audioQueue);
    [self setAudioFormat];
    
    audioDataIndex = 0;
    for(int i=0; i<QUEUE_BUFFER_SIZE; i++){
        [self fillBuffer:audioQueue queueBuffer:audioQueueBuffers[i]];
    }
    AudioQueueStart(audioQueue, NULL);
}

- (void)readPcmAndPlay:(NSString*)pcmFileName {
    NSString *docDir = [ZSJPathUtilities documentsPath];
    NSString *pcmPath = [docDir stringByAppendingPathComponent:pcmFileName];
    NSFileHandle *pcmFileHandle = [NSFileHandle fileHandleForReadingAtPath:pcmPath];
    NSData *data = [pcmFileHandle readDataToEndOfFile];
    NSUInteger len = [data length];
    Byte *byte = (Byte*)malloc(len);
    memcpy(byte, [data bytes], len);
    [self play:byte Length:len];
}

@end
