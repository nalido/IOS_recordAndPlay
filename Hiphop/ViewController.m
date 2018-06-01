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
    BOOL isSingMode; //是否演唱模式，用于录音和背景音乐同步, 若为真，则在播放开始事件中启动录音。
}

@property (weak, nonatomic) IBOutlet UILabel *MessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *BtnPlayBGM;
@property (weak, nonatomic) IBOutlet UIButton *BtnPlayRecord;
@property (weak, nonatomic) IBOutlet UILabel *Mp3InfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *Mp3Img;
@property (weak, nonatomic) IBOutlet UILabel *DelayLabel;
@property (weak, nonatomic) IBOutlet UILabel *DecayLabel;
@property (weak, nonatomic) IBOutlet UIButton *BtnPlaySing;
@property (weak, nonatomic) IBOutlet UIButton *BtnSing;


@end

@implementation ViewController

- (IBAction)onSliderDelayChanged:(UISlider *)sender {
    _DelayLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    [_DelayLabel sizeToFit];
    
    player->mDelay = (int)sender.value;
}

- (IBAction)onSliderDecayChanged:(UISlider *)sender {
    _DecayLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
    [_DecayLabel sizeToFit];
    
    player->mDecay = sender.value;
}

- (IBAction)onClickSing:(UIButton *)sender {
    NSString *action = sender.titleLabel.text;
    if([action isEqualToString:@"停止"]){
        [sender setTitle:@"演唱" forState:UIControlStateNormal];
        [player stop];
        [recorder stop];
        isSingMode = false;
    }
    else{
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        isSingMode = true;
        [recorder stop];
        [player readPcmAndPlay:@"陈一发儿 - 弦上有春秋.pcm"];
    }
}

- (IBAction)onClickPlaybackSing:(UIButton *)sender {
    NSString *action = sender.titleLabel.text;
    if([action isEqualToString:@"停止"]){
        [sender setTitle:@"演唱回放" forState:UIControlStateNormal];
        [player stop];
    }
    else{
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        //[player readPcmAndPlay:@"record.pcm"];
        player->mDelay = [_DelayLabel.text intValue];
        player->mDecay = [_DecayLabel.text floatValue];
        [player playPcmFileWithEffect:@"record.pcm" withBGM:@"陈一发儿 - 弦上有春秋.pcm"];
    }
}

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
        //[player readPcmAndPlay:@"record.pcm"];
        player->mDelay = [_DelayLabel.text intValue];
        player->mDecay = [_DecayLabel.text floatValue];
        [player playPcmFileWithEffect:@"record.pcm"];
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

- (IBAction)onClickShowInfo:(UIButton *)sender {
    Mp3Info *mp3Info = [AudioDecoder showMp3Info:@"陈一发儿 - 弦上有春秋.mp3" needImage:true];
    _Mp3InfoLabel.text = [mp3Info getAllInfoString];
    _Mp3InfoLabel.numberOfLines = 0;
    _Mp3InfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_Mp3InfoLabel sizeToFit];
    
    UIImage *pic = [UIImage imageWithData:mp3Info->pic];
    _Mp3Img.image = pic;
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
    [_BtnPlaySing setTitle:@"演唱回放" forState:UIControlStateNormal];
    
    if(isSingMode){
        [recorder stop];
        [_BtnSing setTitle:@"演唱" forState:UIControlStateNormal];
    }
}

- (void)playStarted {
    if(isSingMode){
        _MessageLabel.text = @"演唱ing...";
        [_MessageLabel sizeToFit];
        recorder = [recorder init: @"record.pcm"];
        [recorder start];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"hello world.");
    
    //初始化
    player = [[AudioPlayer alloc] init];
    recorder = [[AudioRecorder alloc] init];
    isSingMode = false;
    
    //创建异步子线程测试录音功能
    //发现录音功能在软件开始时直接点击‘演唱’会有无法录音的问题，只有先点‘录音’后就好了。这个原因还未知，先建个子线程录一秒钟。
    dispatch_queue_t queue = dispatch_queue_create("com.hiphop.testQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        AudioRecorder *tmpRecorder = [[AudioRecorder alloc] init:@"testrecord.pcm"];
        [tmpRecorder start];
        sleep(1);
        [tmpRecorder stop];
    });
    
    //注册通知观察者
    //播放结束事件
    [[NSNotificationCenter defaultCenter] addObserverForName:@"playFinished" object:player queue:nil usingBlock:^(NSNotification* note){
        [self playFinished];
    }];
    //播放开始事件
    [[NSNotificationCenter defaultCenter] addObserverForName:@"playstarted" object:player queue:nil usingBlock:^(NSNotification* note){
        [self playStarted];
    }];
    
    NSLog(@"stop");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
