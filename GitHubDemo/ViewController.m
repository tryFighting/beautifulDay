//
//  ViewController.m
//  GitHubDemo
//
//  Created by zrq on 2018/3/28.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import "ViewController.h"
//一种重定向的实现思路是自定义一个通知队列,让这个队列去维护那些我们需要重定向的notification，我们一样去注册一个通知的观察者，当Notification到达时，先看看post这个notification的线程是不是我们期望的线程,如果不是，就将这个notification放到我们的队列中，然后发送一个信号(signal)到期望的线程中,来告诉这个线程需要处理一个Notification,指定的线程收到这个signal后，将notification从队列中移除，并进行后续处理
@interface ViewController ()<NSMachPortDelegate>
@property(nonatomic)NSMutableArray *notifications;//通知队列
@property(nonatomic)NSThread *notificationThread;//想要处理通知的线程(目标线程)
@property(nonatomic)NSLock *notificationLock;//用于对通知队列加锁的锁对象，避免线程冲突
@property(nonatomic)NSMachPort *notificationPort;//用于向目标线程发送信号的通信端口
@end

@implementation ViewController
- (void)processNotification:(NSNotification *)notification {
    //判断是不是目标线程，不是则转发到目标线程
    if ([NSThread currentThread] != _notificationThread) {
        //将notification转发到目标线程
        [self.notificationLock lock];
        [self.notifications addObject:notification];
        [self.notificationLock unlock];
        [self.notificationPort sendBeforeDate:[NSDate date] components:nil from:nil reserved:0];
    }else{
        //在此处处理通知
        NSLog(@"Receive notification，Current thread = %@", [NSThread currentThread]);
        NSLog(@"Process notification");
    }
}
/*
 端口的代理方法
 */
- (void)handleMachMessage:(void *)msg{
    [self.notificationLock lock];
    while ([self.notifications count]) {
        NSNotification *notification = [self.notifications objectAtIndex:0];
        [self.notifications removeObjectAtIndex:0];
        [self.notificationLock unlock];
        [self processNotification:notification];
        [self.notificationLock lock];
    }
    [self.notificationLock unlock];
}
/*在注册任何通知之前，需要先初始化属性。下面方法初始化了队列和锁对象，保留对当前线程对象的引用，并创建一个Mach通信端口，将其添加到当前线程的引用,将其添加到当前线程的运行循环中
 此方法运行后，发送到notificationPort的任何消息都会在首次运行此方法的线程的runloop中接收。如果接收线程的run loop在mach消息到达时没有运行，则内核保持该消息，直到下一次runloop,接收线程的runloop将传入消息发送到端口delegate的handleMachMessage的方法
 */
- (void)setUpThreadingSupport{
    if (self.notifications) {
        return;
    }
    self.notifications = [[NSMutableArray alloc] init];
    self.notificationLock = [[NSLock alloc] init];
    self.notificationThread = [NSThread currentThread];
    self.notificationPort = [[NSMachPort alloc] init];
    [self.notificationPort setDelegate:self];
    [[NSRunLoop currentRunLoop] addPort:self.notificationPort forMode:(__bridge NSString *)kCFRunLoopCommonModes];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *NOTIFICATION_NAME = @"NOTIFICATION_NAME";
    NSLog(@"Current thread = %@", [NSThread currentThread]);
    [self setUpThreadingSupport];
    //注册观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:NOTIFICATION_NAME object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //发送Notification
        NSLog(@"Post notification，Current thread = %@", [NSThread currentThread]);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME object:nil userInfo:nil];
        
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
