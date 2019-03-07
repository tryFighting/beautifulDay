//
//  H264ViewController.m
//  GitHubDemo
//
//  Created by zrq on 2019/3/7.
//  Copyright © 2019年 zrq. All rights reserved.
//

#import "H264ViewController.h"
#import "H264Encoder.h"
@interface H264ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,H264EncoderImpDelegate>{
    H264Encoder *h264Encoder;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    NSString *h264File;
    int fd;
    NSFileHandle *fileHandle;
    AVCaptureConnection *connection;
}

@end

@implementation H264ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    h264Encoder = [H264Encoder alloc];
    [h264Encoder initWithConfiguration];
}
- (IBAction)start:(id)sender {
    [self startCamera];
}
- (IBAction)end:(id)sender {
    [self stopCamera];
}

- (void)startCamera{
    ///make input file
    NSError *deviceError;
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&deviceError];
    //make output device
    AVCaptureVideoDataOutput *outputDevice = [[AVCaptureVideoDataOutput alloc] init];
    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *val = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    NSDictionary *videoSetting = [NSDictionary dictionaryWithObject:val forKey:key];
    outputDevice.videoSettings = videoSetting;
    [outputDevice setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    //initialize capture session
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession addInput:inputDevice];
    [captureSession addOutput:outputDevice];
    
    //begin configuration for the AVCaptureSession
    [captureSession beginConfiguration];
    
    //picture resolution
    [captureSession setSessionPreset:[NSString stringWithString:AVCaptureSessionPreset352x288]];
    ///设备捕捉链接
    connection = [outputDevice connectionWithMediaType:AVMediaTypeVideo];
    
    [self setRelativeVideoOrientation];
    
    NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(statusBarOrientationDidChange:) name:@"statusBarOrientationDidChange:" object:nil];
    [captureSession commitConfiguration];
    
    //make preview layer and add so that camera's view is displayed on screen
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:previewLayer];
    [captureSession startRunning];
    
    ///文件处理 H264
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    h264File = [documentDirectory stringByAppendingPathComponent:@"test.h264"];
    [fileManager removeItemAtPath:h264File error:nil];
    [fileManager createFileAtPath:h264File contents:nil attributes:nil];
    
    //open the file using POSIX as this is anyway a test application
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:h264File];
    [h264Encoder initEncode:480 height:640];
    h264Encoder.delegate = self;
}
- (void)setRelativeVideoOrientation {
    switch ([[UIDevice currentDevice] orientation]) {
        case UIInterfaceOrientationPortrait:
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        case UIInterfaceOrientationUnknown:
#endif
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            connection.videoOrientation =
            AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
}
- (void)statusBarOrientationDidChange:(NSNotification*)notification {
    [self setRelativeVideoOrientation];
}
- (void)stopCamera{
    [captureSession stopRunning];
    [previewLayer removeFromSuperlayer];
    [fileHandle closeFile];
    fileHandle = NULL;
}
#pragma mark ----capture delegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    [h264Encoder encode:sampleBuffer];
}
#pragma mark ---delegate
- (void)gotSpsPps:(NSData *)sps pps:(NSData *)pps{
    NSLog(@"sps==%d,pps=%d",(int)[sps length],(int)[pps length]);
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof(bytes)) - 1;
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    [fileHandle writeData:ByteHeader];
    [fileHandle writeData:sps];
    [fileHandle writeData:ByteHeader];
    [fileHandle writeData:pps];
}
- (void)gotEncodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame{
    NSLog(@"gotEncodeData %d",(int)[data length]);
    static int frameCount = 1;
    if (fileHandle != NULL) {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof(bytes)) - 1;
        NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
        [fileHandle writeData:ByteHeader];
        [fileHandle writeData:data];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
