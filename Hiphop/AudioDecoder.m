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

+ (NSString*)getTagFrom:(AVFormatContext*)inputFormatCtx byTagName:(const char*)tagName {
    AVDictionaryEntry *tag = NULL;
    NSString *value = @"";
    tag = av_dict_get(inputFormatCtx->metadata, tagName, NULL, AV_DICT_IGNORE_SUFFIX);
    if(tag) {
        //value是中文的话 直接转NSString会乱码。需要指定编码。
        value = [[NSString alloc] initWithCString:tag->value encoding:NSUTF8StringEncoding];
    }
    return value;
}

+ (Mp3Info*)showMp3Info:(NSString*)mp3FileName needImage:(BOOL)imageNeeded {
    NSString *docDir = [ZSJPathUtilities documentsPath];
    NSString *inputFileName = [docDir stringByAppendingPathComponent:mp3FileName];
    
    
    av_register_all();
    avcodec_register_all();
    
    // 打开输入音频文件
    AVFormatContext *inputFormatCtx = NULL;
    int ret = avformat_open_input(&inputFormatCtx, [inputFileName UTF8String], NULL, 0);
    
    Mp3Info *mp3Info = [[Mp3Info alloc] init];
    
    if (ret != 0) {
        NSLog(@"打开文件失败 %@", inputFileName);
        return nil;
    }
    
    //获取音频中流的相关信息
    ret = avformat_find_stream_info(inputFormatCtx, 0);
    
    if (ret != 0) {
        NSLog(@"不能获取流信息");
        return nil;
    }
    
    
    // 获取数据中音频流的序列号，这是一个标识符
    int  audioStream = -1;
    AVCodecContext *inputCodecCtx;
    
    for (int index = 0; index <inputFormatCtx->nb_streams; index++) {
        AVStream *stream = inputFormatCtx->streams[index];
        AVCodecContext *code = stream->codec;
        if (code->codec_type == AVMEDIA_TYPE_AUDIO){
            audioStream = index;
            break;
        }
    }
    
    //从音频流中获取输入编解码相关的上下文
    inputCodecCtx = inputFormatCtx->streams[audioStream]->codec;
    
    mp3Info->album = [self getTagFrom:inputFormatCtx byTagName:"album"];
    mp3Info->artist = [self getTagFrom:inputFormatCtx byTagName:"artist"];
    mp3Info->title = [self getTagFrom:inputFormatCtx byTagName:"title"];
    mp3Info->nb_channels = inputCodecCtx->channels;
    mp3Info->sample_rate = inputCodecCtx->sample_rate;
    int64_t duration = inputFormatCtx->duration + (inputFormatCtx->duration <= INT64_MAX - 5000 ? 5000 : 0);
    mp3Info->duration = duration / AV_TIME_BASE;
    mp3Info->bit_rate = inputFormatCtx->bit_rate;
    
    //获取专辑图片
    if(imageNeeded){
        for (int index = 0; index <inputFormatCtx->nb_streams; index++) {
            AVStream *stream = inputFormatCtx->streams[index];
            if(stream->disposition & AV_DISPOSITION_ATTACHED_PIC){
                AVPacket pkt = stream->attached_pic;
                mp3Info->pic = [NSData dataWithBytes:pkt.data length:pkt.size];
                break;
            }
        }
    }
    
    avformat_close_input(&inputFormatCtx);
    return mp3Info;
}

+ (void)convertMP3:(NSString*)mp3FileName toPCM:(NSString*)pcmFileName {
    
    // 获取文件夹路径
    NSString *docDir = [ZSJPathUtilities documentsPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *pcmPath = [docDir stringByAppendingPathComponent:pcmFileName];
    
    [fileManager removeItemAtPath:pcmPath error:nil];
    
    [fileManager createFileAtPath:pcmPath contents:nil attributes:nil];
    
    NSFileHandle *pcmfileHandle = [NSFileHandle fileHandleForWritingAtPath:pcmPath];
    
    
    NSLog(@"stroe aac and pcm dic = %@",docDir);
    
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
    
    BOOL finished  = NO;
    while(!finished){
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
        
        av_packet_unref(&packet); //av_read_frame会申请内存，导致内存泄漏
        
        if (data_present)
        {
            //只写入单通道的数据
            NSData *data = [NSData dataWithBytes:audioFrame->data[0] length:audioFrame->linesize[0]];
            [pcmfileHandle writeData:data];
            data = nil;
            //NSLog(@"data length = %lu", data.length);
        }
        
        av_frame_free(&audioFrame);
        av_frame_unref(audioFrame);
        av_free(audioFrame);
    }
    
    [pcmfileHandle closeFile];
    pcmfileHandle = nil;
    avcodec_close(inputCodecCtx);
    avformat_close_input(&inputFormatCtx);
    avformat_free_context(inputFormatCtx);
    NSLog(@"***************************************end");
}


@end
