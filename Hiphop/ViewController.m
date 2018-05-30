//
//  ViewController.m
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/29.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import "ViewController.h"
#import "AudioDecoder.h"
#import "AudioPlayer.h"
#import "AudioRecorder.h"

@interface ViewController (){
    AudioPlayer* player;
    AudioRecorder* recorder;
}

@property (weak, nonatomic) IBOutlet UILabel *MessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *BtnPlayBGM;
@property (weak, nonatomic) IBOutlet UIButton *BtnPlayRecord;


@end

@implementation ViewController

- (IBAction)onClickRecord:(UIButton *)sender {
    NSString *action = sender.titleLabel.text;
    if([action isEqualToString:@"停止"]){
        [sender setTitle:@"录音" forState:UIControlStateNormal];
        [recorder stop];
    }
    else{
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        recorder = [recorder init: @"record.pcm"];
        [recorder start];
    }
}

- (IBAction)onClickRecordReplay:(UIButton *)sender {
    NSString *action = sender.titleLabel.text;
    if([action isEqualToString:@"停止"]){
        [sender setTitle:@"录音回放" forState:UIControlStateNormal];
        [player stop];
    }
    else{
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        [player readPcmAndPlay:@"record.pcm"];
    }
}


- (IBAction)onClickTestBlock:(id)sender {
    static int count = 0;
    count ++;
    _MessageLabel.text = [NSString stringWithFormat:@"clicked: %d", count];
    [_MessageLabel sizeToFit]; //auto resize.
}

- (IBAction)onClickPlayBGM:(UIButton *)sender {
    NSString *action = sender.titleLabel.text;
    if([action isEqualToString:@"停止"]){
        [sender setTitle:@"播放背景音乐(已解码)" forState:UIControlStateNormal];
        [player stop];
    }
    else{
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        [player readPcmAndPlay:@"陈一发儿 - 弦上有春秋.pcm"];
    }
}

- (IBAction)onClickDecode:(id)sender {
    //[AudioDecoder convertMP3:@"北京欢迎你.mp3" toPCM:@"北京欢迎你.pcm"];
    //[AudioDecoder convertMP3:@"凉凉 (Cover张碧晨&杨宗纬)-黄仁烁;王若伊.mp3" toPCM:@"凉凉 (Cover张碧晨&杨宗纬)-黄仁烁;王若伊.pcm"];
    [AudioDecoder convertMP3:@"陈一发儿 - 弦上有春秋.mp3" toPCM:@"陈一发儿 - 弦上有春秋.pcm"];
    //[self convertMP3ToAAC];
}

- (void)playFinished {
    _MessageLabel.text = @"finished";
    [_MessageLabel sizeToFit];
    
    //复原按钮状态
    [_BtnPlayBGM setTitle:@"播放背景音乐(已解码)" forState:UIControlStateNormal];
    [_BtnPlayRecord setTitle:@"录音回放" forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"hello world.");
    
    //初始化
    player = [[AudioPlayer alloc] init];
    recorder = [[AudioRecorder alloc] init];
    
    //注册通知观察者
    [[NSNotificationCenter defaultCenter] addObserverForName:@"playFinished" object:player queue:nil usingBlock:^(NSNotification* note){
        [self playFinished];
    }];
    
    NSLog(@"stop");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
