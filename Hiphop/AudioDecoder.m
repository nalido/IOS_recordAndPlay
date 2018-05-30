//
//  AudioDecoder.m
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/29.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import "AudioDecoder.h"

@implementation AudioDecoder

+ (void)transcodeFrom:(NSString*)inputName toAAC:(NSString*)AACFileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *docDir = [ZSJPathUtilities documentsPath];
    NSString *bundle = [ZSJPathUtilities bundlePath];
    
    //NSString *AACFileName = @"北京欢迎你.aac";
    //NSString *inputName = @"北京欢迎你.mp3";   //月光の云海 - 久石譲.pcm
    //    NSString *inputName  =@"月光の云海 - 久石譲.pcm";
    NSString *fileName = [bundle stringByAppendingPathComponent:inputName];
    
    NSString *AACPath = [docDir stringByAppendingPathComponent:AACFileName];
    
    [fileManager removeItemAtPath:AACPath error:nil];
    [fileManager createFileAtPath:AACPath contents:nil attributes:nil];
    
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:AACPath];
    
    ZSJTranscode_AAC *tranc = [[ZSJTranscode_AAC alloc]initWithInputPath:fileName outputBlock:nil];
    
    __weak ZSJTranscode_AAC *weakTranc = tranc;
    tranc.outputBlock = ^(NSData* data, NSTimeInterval pts , NSInteger size) {
        
        if (data) {
            [fileHandle writeData:[weakTranc adtsHeader:data.length]];
            [fileHandle writeData:data];
        }
    };
    
    while (!tranc.isFinish) {
        [tranc readData];
    }
    
    NSLog(@"---------------------------<end---%@",NSHomeDirectory());
    
}

+ (void)convertMP3:(NSString*)mp3FileName toPCM:(NSString*)pcmFileName {
    
    // 获取文件夹路径
    NSString *docDir = [ZSJPathUtilities documentsPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString *pcmFileName = @"凉凉 (Cover张碧晨&杨宗纬)-黄仁烁;王若伊.pcm";
    
    NSString *pcmPath = [docDir stringByAppendingPathComponent:pcmFileName];
    
    [fileManager removeItemAtPath:pcmPath error:nil];
    
    [fileManager createFileAtPath:pcmPath contents:nil attributes:nil];
    
    NSFileHandle *pcmfileHandle = [NSFileHandle fileHandleForWritingAtPath:pcmPath];
    
    
    NSLog(@"stroe aac and pcm dic = %@",docDir);
    //  NSString *inputName = @"北京欢迎你.mp3";   /
    //        NSString *inputFileName = [bundle stringByAppendingPathComponent:@"北京欢迎你.mp3"];
    NSString *inputFileName = [docDir stringByAppendingPathComponent:mp3FileName];
    
    av_register_all();
    avcodec_register_all();
    
    AVFormatContext *inputFormatCtx = NULL;
    
    
    
    // 打开输入音频文件
    int ret = avformat_open_input(&inputFormatCtx, [inputFileName UTF8String], NULL, 0);
    
    if (ret != 0) {
        NSLog(@"打开文件失败 %@", inputFileName);
        return;
    }
    
    //获取音频中流的相关信息
    ret = avformat_find_stream_info(inputFormatCtx, 0);
    
    if (ret != 0) {
        NSLog(@"不能获取流信息");
        return;
    }
    
    
    // 获取数据中音频流的序列号，这是一个标识符
    int  index = 0,audioStream = -1;
    AVCodecContext *inputCodecCtx;
    
    for (index = 0; index <inputFormatCtx->nb_streams; index++) {
        AVStream *stream = inputFormatCtx->streams[index];
        AVCodecContext *code = stream->codec;
        if (code->codec_type == AVMEDIA_TYPE_AUDIO){
            audioStream = index;
            break;
        }
    }
    
    //从音频流中获取输入编解码相关的上下文
    inputCodecCtx = inputFormatCtx->streams[audioStream]->codec;
    //查找解码器
    AVCodec *pCodec = avcodec_find_decoder(inputCodecCtx->codec_id);
    // 打开解码器
    int result =  avcodec_open2(inputCodecCtx, pCodec, nil);
    if (result < 0) {
        NSLog(@"打开音频解码器失败");
        return;
    }
    
    //初始化先进先出缓存队列
    AVAudioFifo *fifo = av_audio_fifo_alloc(AV_SAMPLE_FMT_FLTP, 1, inputCodecCtx->frame_size);
    
    //获取编码每帧的最大取样数
    int output_frame_size = inputCodecCtx->frame_size;
    
    BOOL finished  = NO;
    while (1) {
        
        if (finished){
            break;
        }
        
        // 查看fifo队列中的大小是否超过可以编码的一帧的大小
        while (av_audio_fifo_size(fifo) < output_frame_size) {
            
            // 如果没超过，则继续进行解码
            
            if (finished)
            {
                break;
            }
            
            //
            AVFrame *audioFrame = av_frame_alloc();
            AVPacket packet;
            packet.data = NULL;
            packet.size = 0;
            int data_present;
            
            // 读取出一帧未解码数据
            finished =  (av_read_frame(inputFormatCtx, &packet) == AVERROR_EOF);
            
            // 判断该帧数据是否为音频数据
            if (packet.stream_index != audioStream) {
                continue;
            }
            
            // 开始进行解码
            if ( avcodec_decode_audio4(inputCodecCtx, audioFrame, &data_present, &packet) < 0) {
                NSLog(@"音频解码失败");
                return ;
            }
            
            
            if (data_present)
            {
                //将pcm数据写入文件
//                for(int i = 0 ; i <audioFrame->channels;i++)
//                {
//                    NSData *data = [NSData dataWithBytes:audioFrame->data[i] length:audioFrame->linesize[0]];
//                    [pcmfileHandle writeData:data];
//                    //NSLog(@"data length = %lu", data.length);
//                }
                //只写入单通道的数据
                NSData *data = [NSData dataWithBytes:audioFrame->data[0] length:audioFrame->linesize[0]];
                [pcmfileHandle writeData:data];
                //NSLog(@"data length = %lu", data.length);
            }
        }
        
    }
    
    NSLog(@"***************************************end");
}

//+ (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength {
//    int adtsLength = 7;
//    char *packet = malloc(sizeof(char) * adtsLength);
//    // Variables Recycled by addADTStoPacket
//    int profile = 2;  //AAC LC
//    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
//    int freqIdx = 4;  //44.1KHz
//    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
//    NSUInteger fullLength = adtsLength + packetLength;
//    // fill in ADTS data
//    packet[0] = (char)0xFF; // 11111111     = syncword
//    packet[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
//    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
//    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
//    packet[4] = (char)((fullLength&0x7FF) >> 3);
//    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
//    packet[6] = (char)0xFC;
//    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
//    return data;
//}


@end
