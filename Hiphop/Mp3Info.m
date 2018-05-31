//
//  Mp3Info.m
//  Hiphop
//
//  Created by 黄 剑冰 on 2018/5/31.
//  Copyright © 2018年 黄 剑冰. All rights reserved.
//

#import "Mp3Info.h"

@implementation Mp3Info

- (NSString*)getAllInfoString {
    NSString *info = [NSString stringWithFormat:@"专辑名: %@\n歌曲名: %@\n歌手: %@\n采样率: %d\n声道数: %d\n比特率: %ld\n 时长: %ld s",
                      album, title, artist, sample_rate, nb_channels, bit_rate, duration];
    return info;
}

@end
