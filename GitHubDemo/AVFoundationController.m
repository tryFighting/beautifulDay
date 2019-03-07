//
//  AVFoundationController.m
//  GitHubDemo
//
//  Created by zrq on 2019/1/18.
//  Copyright © 2019年 zrq. All rights reserved.
//

#import "AVFoundationController.h"
#import <AVFoundation/AVFoundation.h>
@interface AVFoundationController ()

@end

@implementation AVFoundationController
- (NSString *)titleForAsset:(AVAsset *)asset{
    NSArray *items = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
    return [[items firstObject] stringValue];
}
/**
 字幕显示
 */
- (void)mediaCharacteristics{
    AVAsset *asset = [AVAsset assetWithURL:[NSURL new]];
    NSString *characteristics = AVMediaCharacteristicLegible;
    AVMediaSelectionGroup *group = [asset mediaSelectionGroupForMediaCharacteristic:characteristics];
    NSLocale *enLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    
    NSArray *options = [AVMediaSelectionGroup mediaSelectionOptionsFromArray:group.options withLocale:enLocale];
    AVMediaSelectionOption *option = [options firstObject];
    AVPlayerItem *playerItem;
    [playerItem selectMediaOption:option inMediaSelectionGroup:group];
    return;
}
/**
 生成缩图
 */
- (void)imageGenerator{
    AVAsset *asset = [AVAsset assetWithURL:[NSURL new]];
    ///生成类需要为其传递一个强引用的AVAsset对象，否则将无法调用回调
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    ///缩放 提高性能
    generator.maximumSize = CGSizeMake(200.0f, 0.0f);
    
    CMTime duration = asset.duration;
    
    NSMutableArray *times = [NSMutableArray array];
    CMTimeValue increment = duration.value/20;
    CMTimeValue currentValue = kCMTimeZero.value;
    while (currentValue <= duration.value) {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }
    __block NSUInteger imageCount = times.count;
    __block NSMutableArray *images = [NSMutableArray array];
    ///一张图片
    CMTime one,two;
    NSError *error;
    [generator copyCGImageAtTime:one actualTime:&two error:&error];
    ///一组图片
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumb = [UIImage imageWithCGImage:image];
            [images addObject:thumb];
        }
        if (--imageCount == 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                return ;
            });
        }
    }];
    return;
}
/**
 AVFoundation
 AVPlayer:用来播放基于时间的视听媒体的控制器对象，支持本地，分布下载或者HTTP Live Streaming协议得到的流媒体。是不可视组件。AVPlayer只管理一个单独资源的播放，若要管理一个资源队列，可使用AVQueuePlayer子类
 AVPlayerLayer是一个可视化组件，创建实例需要一个指向AVPlayer实例的指针。
 AVPlayerItem:视频播放的最终是使用AVPlayer来播放AVAsset指向的资源，但AVAsset只包含媒体资源的静态信息，
 当我们需要对一个资源及相关曲目进行播放时，首先需要通过AVPlayerItem和AVPlayerItemTrack类构建相应的动态内容
 
 */
- (void)player{
    NSURL *assetURL = [NSURL fileURLWithPath:@""];
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view.layer insertSublayer:playerLayer atIndex:0];
    
    ///AVPlayer时间监听
    CMTime time = CMTimeMake(1, 1); //指定周期间隔的CMTime值
    dispatch_queue_t aQueue = dispatch_get_main_queue();///顺序调度队列
    [player addPeriodicTimeObserverForInterval:time queue:aQueue usingBlock:^(CMTime time) {
        
    }];
    ///边界时间监听
    NSArray *boundArr = @[@(360)];
    [player addBoundaryTimeObserverForTimes:boundArr queue:aQueue usingBlock:^{
        ///边界监听
    }];
    ///取消监听
    [player removeTimeObserver:self];
    ///播放结束监听
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
