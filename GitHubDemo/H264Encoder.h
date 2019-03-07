//
//  H264Encoder.h
//  GitHubDemo
//
//  Created by zrq on 2019/3/7.
//  Copyright © 2019年 zrq. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@protocol H264EncoderImpDelegate <NSObject>
/**
 获取H264上的sps和pps信息流

 @param sps 序列参数集：将属于图像组GOP层，Slice层公用部分语法元素游离出来
 作用：包含一个CVS中所有编码图像的共享编码参数
 内容:（1）图像格式信息 编码参数信息 与参数图像相关的信息 档次层和级相关信息 时域分级信息 可视化可用信息VUI
 sps提供了公共参数 pps作用于编码图像
 @param pps 图像参数集
 */
- (void)gotSpsPps:(NSData *)sps pps:(NSData *)pps;
/**
 
获取编码数据
 @param data 编码数据
 @param  isKeyFrame 是不是关键帧
 */
- (void)gotEncodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame;
@end
@interface H264Encoder : NSObject
- (void)initWithConfiguration;
- (void)startVideoWidth:(int)width videoHeight:(int)height;
- (void)initEncode:(int)width height:(int)height;
- (void)changeResolution:(int)width height:(int)height;
- (void)encode:(CMSampleBufferRef)sampleBuffer;
- (void)end;
@property(weak,nonatomic)NSString *error;
@property(weak,nonatomic)id<H264EncoderImpDelegate>delegate;
@end

