//
//  AudioQueueSerices.m
//  GitHubDemo
//
//  Created by zrq on 2019/2/27.
//  Copyright © 2019年 zrq. All rights reserved.
//

#import "AudioQueueSerices.h"
#import <UIKit/UIKit.h>
@implementation AudioQueueSerices
///音频服务
+ (void)audioService{
    ///开启远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    ///解除远程控制
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    ///全屏禁触开启
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    //全屏禁触关闭
     [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    ///AVAudioSessionRouteChangeNotification 拨出耳机系统通知
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
@end
