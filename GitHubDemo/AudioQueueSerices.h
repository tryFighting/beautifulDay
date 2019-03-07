//
//  AudioQueueSerices.h
//  GitHubDemo
//
//  Created by zrq on 2019/2/27.
//  Copyright © 2019年 zrq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 Incoming audio-------->Audio Queue(Buffer Queue)----->Callback---->Outgoing audio
 一个音频服务队列 Audio Queue 有三部分组成
 三个缓冲器Buffers:每个缓冲器都有一个存储音频数据的临时仓库
 一个缓冲队列Buffer Queue：一个包含音频缓冲器的有序队列
 一个回调callback：一个自定义的队列回调函数
 
 流程:
 声音通过输入设备进入缓冲队列中，首先填充第一个缓冲器；当第一个缓冲器填充满后自动填充下一个缓冲器，同时会调用回调函数；在回调函数中需要将缓冲器中的音频数据写入磁盘，同时将缓冲器放回缓冲队列以便重用
 
 1.Audio queue fills buffer with data
 2.audio queue hands-off full buffer to callback and fills another buffer
 3.callback writes data to disk
 4.callback returns buffer to audio queue for reuse
 5.audio queue hands-off full buffer to callback and fills another buffer
 6.callback writes data to disk
 
 音频播放缓冲队列中，回调函数调用机制不同于音频录制缓冲队列
 将音频读取到缓冲器中，一旦一个缓冲器填满之后就放到缓冲队列中，然后继续填充其他缓冲器；当开始播放时,则从第一个缓冲器中读取音频进行播放；一旦播放完之后就会触发回调函数，开始播放下一个缓冲器中的音频，同时填充第一个缓冲器放，填充满之后就会再次放到缓冲队列。
 */

@interface AudioQueueSerices : NSObject

@end

NS_ASSUME_NONNULL_END
