//
//  CaptureViewController.m
//  GitHubDemo
//
//  Created by zrq on 2019/1/21.
//  Copyright © 2019年 zrq. All rights reserved.
//
#import "CaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface CaptureViewController ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@end

@implementation CaptureViewController

/**
 媒体捕捉 核心类是AVCaptureSession,用于连接输入输出的资源。
 捕捉会话有一个会话预设值，用于控制捕捉数据的格式和质量，默认是高质量
 针对物理设备定义了大量控制方法，包括对焦，白平衡，曝光
 */

///创建捕捉会话
- (void)captureSession{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    if ([session canAddInput:cameraInput]) {
        [session addInput:cameraInput];
    }
    AVCapturePhotoOutput *imageOutput = [[AVCapturePhotoOutput alloc] init];
    if ([session canAddOutput:imageOutput]) {
        [session addOutput:imageOutput];
    }
    ///开始捕捉
    [session startRunning];
    ///停止捕捉
    //[session stopRunning];
   AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer new];
    ///获取屏幕坐标中的值，返回转换得到的设备坐标系的值
   CGPoint point = [previewLayer captureDevicePointOfInterestForPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    NSLog(@"%f---%f",point.x,point.y);
    ///获取输入设备的值，转换屏幕坐标的值
    [previewLayer pointForCaptureDevicePointOfInterest:CGPointMake(0.5, 0.5)];
}
///切换相机按钮
- (void)changeCameraAtPosition:(AVCaptureDevicePosition)position forSession:(AVCaptureSession *)captureSession{
    NSArray *carmeras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in carmeras) {
        if (camera.position == position) {
            [captureSession beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:camera error:nil];
            if ([captureSession canAddInput:input]) {
                for (AVCaptureInput *input in captureSession.inputs) {
                    if ([[input.ports firstObject] isEqual:AVMediaTypeVideo]) {
                        [captureSession removeInput:input];
                    }
                    [captureSession addInput:input];
                }
                [captureSession commitConfiguration];
            }
        }
    }
}
///调整对焦
- (void)focusForDevice:(AVCaptureDevice *)device atPoint:(CGPoint)point{
    NSError *error;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
    }
}
///调整曝光
- (void)exposureForDevice:(AVCaptureDevice *)device atPoint:(CGPoint)point{
    if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        if ([device lockForConfiguration:nil]) {
            device.exposureMode = AVCaptureExposureModeAutoExpose;
            device.exposurePointOfInterest = point;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposureModeLocked" options:NSKeyValueObservingOptionNew context:(__bridge void *)device];
            }
            [device unlockForConfiguration];
        }
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"adjustingExposure"]) {
        AVCaptureDevice *device = (__bridge AVCaptureDevice *)context;
        if (!device.isAdjustingFocus && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([device lockForConfiguration:nil]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                }
            });
        }
        ///移除监听器
        [device removeObserver:self forKeyPath:@"adjustingExposure"];
    }
}
///调整闪光灯和手电筒模式
- (void)setTorchMode:(AVCaptureTorchMode)torchMode flashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device{
    if ([device hasTorch] && [device hasFlash] &&[device isFlashModeSupported:flashMode] && [device isTorchModeSupported:torchMode]) {
        if ([device lockForConfiguration:nil]) {
            device.flashMode = flashMode;
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
    }
}
///拍摄静态图片
- (void)captureStillingImageFromOutput:(AVCaptureStillImageOutput *)output{
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait:
                connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
                
            default:
                break;
        }
    }
}
///视频的录制
- (void)captureMovieFromOutput:(AVCaptureMovieFileOutput *)output{
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoStabilizationSupported]) {
        connection.enablesVideoStabilizationWhenAvailable = YES;
    }
    if (output.isRecording == NO) {
        [output startRecordingToOutputFileURL:[NSURL new] recordingDelegate:self];
    }
}
///视频缩放
- (BOOL)cameraSupportZoom:(AVCaptureDevice *)captureDevice{
    return captureDevice.activeFormat.videoMaxZoomFactor > 1.0f;
}
- (void)setZoomValue:(CGFloat)zommValue forDevice:(AVCaptureDevice *)captureDevice{
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        CGFloat zoomFactor;
        if ([captureDevice lockForConfiguration:&error]) {
            [captureDevice rampToVideoZoomFactor:zoomFactor withRate:1.0f];
            [captureDevice unlockForConfiguration];
        }
    }
}
///人脸检测
/**
 使用iOS系统相机，当视图中有人脸进入时会自动建立相应的焦点，一个黄色的矩形框会显示在检测到人脸位置,并自动对焦，AVFoundation也提供了类似的功能，支持10个人脸实时检测
 CoreImage框架中的CIDetector和CIFaceFeature两个对象
 AVFoundation框架中，则由AVCaptureMetaOutput提供，它输出元数据，当使用人脸检测时，输入的具体对象是AVMetadataFaceObject
 AVMetadataFaceObject对象定义了多个用于检测人脸的属性，其中最重要的一个属性是人脸的边界，他是一个设备坐标，另外还有用于检测人脸倾斜角度和偏转角度的属性
 */
- (void)faceRecongnize:(AVCaptureSession *)session{
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    if ([session canAddOutput:output]) {
        NSArray *metadataObjectTypes = @[AVMetadataObjectTypeFace];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [session addOutput:output];
    }
}
#pragma mark ---delegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    for (AVMetadataFaceObject *faceObj in metadataObjects) {
        NSLog(@"Face detected with ID:%ld",(long)faceObj.faceID);
        NSLog(@"Face bounda:%@",NSStringFromCGRect(faceObj.bounds));
    }
}
///视频处理
/*
 AVCaptureMovieFileOutput,可以将摄像头的捕捉写入文件，但无法同视频数据进行交互（交互使用AVCaptureVideoDataOutput）,它可以直接访问摄像头传感器捕捉到视频帧，我们可以完全控制视频数据的格式，时间和元数据。
 */
///每当一个新的视频帧写入时，该方法就会被调用
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}
///每一个迟到z的帧被丢弃时，该方法就会n被调用
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}
///CMSampleBuffer是一个由CoreMedia框架提供的对象，用于在媒体管道中传输数字样本，CMSampleBuffer的角色是将基础的样本数据进行格式和时间信息，还会加上所有在转换和处理数据用到的元数据
///样本数据灰度处理
- (void)grayWithData:(CMSampleBufferRef)sampleBuffer{
    const int BYTES_PER_PIXEL = 4;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t bufWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t bufHeight = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    unsigned char grayPixel;
    for (int row = 0; row < bufHeight; ++row) {
        for (int col = 0; col < bufWidth; ++col) {
            grayPixel = (pixel[0]+pixel[1]+pixel[2])/3;
            pixel[0] = pixel[1] = pixel[2] = grayPixel;
            pixel += BYTES_PER_PIXEL;
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
}
- (void)dealloc{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
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
