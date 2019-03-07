//
//  AVLearnViewController.m
//  GitHubDemo
//
//  Created by zrq on 2019/1/18.
//  Copyright © 2019年 zrq. All rights reserved.
//

#import "AVLearnViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface AVLearnViewController ()

@end

@implementation AVLearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ///文本转语音
    [self textTransformVoice];
}
/**
 异步载入 AVAsset抽象类
 */
- (void)asyncLoading{
    NSURL *assetURL = [NSURL fileURLWithPath:@""];
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    NSArray *keys = @[@"tracks"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error ;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        switch (status) {
            case AVKeyValueStatusLoaded:
                
                break;
            case AVKeyValueStatusFailed:
                break;
            case AVKeyValueStatusLoading:
                break;
            case AVKeyValueStatusUnknown:
                break;
            case AVKeyValueStatusCancelled:
                break;
            default:
                break;
        }
    }];
    return;
}
/**
 音频测量

 @param recorder <#recorder description#>
 @return <#return value description#>
 */
- (NSArray *)meterForRecoeder:(AVAudioRecorder *)recorder{
    [recorder updateMeters];
    ///音频平均分贝值
    CGFloat average = [recorder averagePowerForChannel:0];
    ///音频分贝峰值
    CGFloat peak = [recorder peakPowerForChannel:0];
    return @[@(average),@(peak)];
}
/**
 录音
 */
- (void)recorder{
    NSURL *fileURL = [NSURL URLWithString:@""];
    NSDictionary *setting = @{
                              AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                              AVSampleRateKey:@22050.0f,
                              AVNumberOfChannelsKey:@1
                              };
    NSError *error;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:setting error:&error];
    if (!error) {
        ////无错误执行
    }else{
        NSLog(@"error == %@",error);
    }
    //在准备录音前优先调用
    [recorder prepareToRecord];
}
/**
 线路通知
 */
- (void)routeChange{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}
- (void)routeChange:(NSNotification *)notification{
    AVAudioSessionRouteChangeReason reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *previousRoute = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        NSString *portType = previousOutput.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            ///处理耳机断开事件
        }
    }
}
/**
 音频中断的处理
 */
- (void)interruptionNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}
- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary *interrDic = notification.userInfo;
    
    NSString  *tip = interrDic[AVAudioSessionInterruptionTypeKey];
    
    NSLog(@"dic == %@,interDic == %@",interrDic,tip);
}
/**
 播放和录制音频
 AVAudioSession提供了与应用程序音频会话交互的接口，开发者需要取得指向该单例的指针
 */
- (void)playAndRecord{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    if (![session setCategory:AVAudioSessionCategoryPlayback error:&error]) {
        NSLog(@"Category Error:%@",error.localizedDescription);
    }
    if (![session setActive:YES error:&error]) {
        NSLog(@"Activation Error:%@",error.localizedDescription);
    }
    ///播放的两种方式 使用要播放音频的内存版本的NSData和本地音频文件的NSURL
    AVAudioPlayer *audio = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"" withExtension:@""] error:&error];
    ///播放音量
    audio.volume = 0.5f;
    ///是否立体声
    audio.pan = 0.0;
    ///播放的速率
    audio.rate = 1.0;
    ///实现音频的无缝循环 -1无限循环
    audio.numberOfLoops = 1;
    ///声道数(只读属性)
    [audio prepareToPlay];
    if ([audio isPlaying]) {
        [audio stop];
        //[audio pause]
    }else{
        [audio play];
    }
    
}
/**
 文本转语音
 */
- (void)textTransformVoice{
    //Utterance---说话方式
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Hello world"];
    NSArray *arr = [NSLocale preferredLanguages];
    //[[NSLocale preferredLanguages] objectAtIndex:0]
    ///朗读使用的声音 zh 中文 en 英文
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en"];
    ///朗读时的语速
    utterance.rate = 0.1f;
    ///朗读时的音调（0.5---2.0）
    utterance.pitchMultiplier = 2.0f;
    ///语音合成器的间隔
    utterance.postUtteranceDelay = 2.0f;
    ///指定在朗读时的音量（0.0---1.0）
    utterance.volume = 1.0f;
    
    utterance.pitchMultiplier = 1;
    
    ///Synthesizer合成器
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    [synthesizer speakUtterance:utterance];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
