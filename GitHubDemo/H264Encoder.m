//
//  H264Encoder.m
//  GitHubDemo
//
//  Created by zrq on 2019/3/7.
//  Copyright © 2019年 zrq. All rights reserved.
//

#import "H264Encoder.h"
#define YUV_FRAME_SIZE 2000
#define FRAME_WIDTH 300
#define NUMBEROFRAMES 300
#define DURATION 12
@import VideoToolbox;
@import AVFoundation;
@implementation H264Encoder
{
    NSString *yuvFile;
    VTCompressionSessionRef EncodingSession;
    dispatch_queue_t aQueue;
    CMFormatDescriptionRef format;
    CMSampleTimingInfo *timingInfo;
    BOOL initialized;
    int frameCount;
    NSData *sps;
    NSData *pps;
}
@synthesize error;
- (void)initWithConfiguration{
    EncodingSession = nil;
    initialized = true;
    aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    frameCount = 0;
    sps = NULL;
    pps = NULL;
}
- (void)startVideoWidth:(int)width videoHeight:(int)height{
    int frameSize = (width * height * 1.5);
    if (!initialized) {
        error = @"H264: Not initialized";
        return;
    }
    dispatch_async(aQueue, ^{
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self), &EncodingSession);
        NSLog(@"H264:VTCompressionSessionCreated %d",(int)status);
        if (status != 0) {
            NSLog(@"H264: unable to create a H264 session");
            error = @"H264: Unable to create a H264 session";
            return ;
        }
        
        //Set the properties
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, 240);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel);
        
        //Tell the encoder to start encoding
        VTCompressionSessionPrepareToEncodeFrames(EncodingSession);
        //start reading from the file and copy it to the buffer
        //open the file using POSIX as this is anyway a test application
        int fd = open([yuvFile UTF8String], O_RDONLY);
        if (fd == -1) {
            NSLog(@"H264: Unable to open the file");
            error = @"H264: Unable to open the file";
            return;
        }
        NSMutableData *theData = [[NSMutableData alloc] initWithLength:frameSize];
        NSUInteger actualBytes = frameSize;
        while (actualBytes > 0) {
            void *buffer = [theData mutableBytes];
            NSUInteger bufferSize = [theData length];
            actualBytes = read(fd, buffer, bufferSize);
            if (actualBytes < frameSize)
                [theData setLength:actualBytes];
                frameCount++;
                //Create a CM Block buffer out of this data
                CMBlockBufferRef BlockBuffer = NULL;
                OSStatus status = CMBlockBufferCreateWithMemoryBlock(NULL, buffer, actualBytes, kCFAllocatorNull, NULL, 0, actualBytes, kCMBlockBufferAlwaysCopyDataFlag, &BlockBuffer);
                //check for error
                if (status != noErr) {
                    NSLog(@"H264: CMBlockBufferCreateWithMemoryBlock failed with %d", (int)status);
                    error = @"H264: CMBlockBufferCreateWithMemoryBlock failed ";
                    
                    return ;
                }
                ///create a CM Sample Buffer
                CMSampleBufferRef sampleBuffer = NULL;
                CMFormatDescriptionRef formatDescription;
                CMFormatDescriptionCreate(kCFAllocatorDefault, kCMMediaType_Video, 'I420', NULL, &formatDescription);
                CMSampleTimingInfo sampleTimingInfo = {CMTimeMake(1, 300)};
                OSStatus statusCode = CMSampleBufferCreate(kCFAllocatorDefault, BlockBuffer, YES, NULL, NULL, formatDescription, 1, 1, &sampleTimingInfo, 0, NULL, &sampleBuffer);
                //check for error
                if (statusCode != noErr) {
                    NSLog(@"H264: CMSampleBufferCreate failed with %d", (int)statusCode);
                    error = @"H264: CMSampleBufferCreate failed ";
                    
                    return;
                }
                CFRelease(BlockBuffer);
                BlockBuffer = NULL;
                // Get the CV Image buffer
                CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
                //create properties
                CMTime presentationTimeStamp = CMTimeMake(frameCount, 300);
                
                VTEncodeInfoFlags flags;
                //pass it to the encoder
                statusCode = VTCompressionSessionEncodeFrame(EncodingSession, imageBuffer, presentationTimeStamp, kCMTimeInvalid, NULL, NULL, &flags);
                //check for error
                if (statusCode != noErr) {
                    NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode);
                    error = @"H264: VTCompressionSessionEncodeFrame failed ";
                    
                    // End the session
                    VTCompressionSessionInvalidate(EncodingSession);
                    //free(EncodingSession);原因是对象生成 的新对象无法完成释放
                    CFRelease(EncodingSession);
                    EncodingSession = NULL;
                    error = NULL;
                    return;
                }
                NSLog(@"H264: VTCompressionSessionEncoderFrame Success");
        }
        //mark the completion
        VTCompressionSessionCompleteFrames(EncodingSession, kCMTimeInvalid);
        // End the session
        VTCompressionSessionInvalidate(EncodingSession);
        CFRelease(EncodingSession);
        EncodingSession = NULL;
        error = NULL;
        close(fd);
    });
}
- (void)initEncode:(int)width height:(int)height{
    dispatch_async(aQueue, ^{
        //create the compression session
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self), &EncodingSession);
        if (status != 0)
        {
            NSLog(@"H264: Unable to create a H264 session");
            error = @"H264: Unable to create a H264 session";
            
            return ;
            
        }
        // set the properties
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
        //tell the encoder to start encoding
        VTCompressionSessionPrepareToEncodeFrames(EncodingSession);
    });
}
- (void)encode:(CMSampleBufferRef)sampleBuffer{
    dispatch_sync(aQueue, ^{
        
        frameCount++;
        // Get the CV Image buffer
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // Create properties
        CMTime presentationTimeStamp = CMTimeMake(frameCount, 1000);
        //CMTime duration = CMTimeMake(1, DURATION);
        VTEncodeInfoFlags flags;
        
        // Pass it to the encoder
        OSStatus statusCode = VTCompressionSessionEncodeFrame(EncodingSession,
                                                              imageBuffer,
                                                              presentationTimeStamp,
                                                              kCMTimeInvalid,
                                                              NULL, NULL, &flags);
        // Check for error
        if (statusCode != noErr) {
            NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode);
            error = @"H264: VTCompressionSessionEncodeFrame failed ";
            
            // End the session
            VTCompressionSessionInvalidate(EncodingSession);
            CFRelease(EncodingSession);
            EncodingSession = NULL;
            error = NULL;
            return;
        }
        NSLog(@"H264: VTCompressionSessionEncodeFrame Success");
    });
    
    
}
- (void)end{
    //mark the completion
    VTCompressionSessionCompleteFrames(EncodingSession, kCMTimeInvalid);
    //end the session
    VTCompressionSessionInvalidate(EncodingSession);
    CFRelease(EncodingSession);
    EncodingSession = NULL;
    error = NULL;
}
void didCompressH264(void *outputCallbackRefCon,void *sourceFrameRefCon,OSStatus status,VTEncodeInfoFlags infoFlags,CMSampleBufferRef sampleBuffer){
    NSLog(@"didCompressH264 call with Status %d intoFlags %d",(int)status,(int)infoFlags);
    if (status != 0) return;
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not ready");
        return;
    }
    H264Encoder *encoder = (__bridge H264Encoder *)(outputCallbackRefCon);
    ///check if we have got a key frame first
    bool keyframe = !CFDictionaryContainsKey((CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    if (keyframe) {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSize,sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSize, &sparameterSetCount, 0);
        if (statusCode == noErr) {
            ///Found sps and check for pps
            size_t pparameterSetSize,pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus stautusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
            if (statusCode == noErr) {
                encoder->sps = [NSData dataWithBytes:sparameterSet length:sparameterSize];
                encoder->pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                if (encoder->_delegate) {
                    [encoder->_delegate gotSpsPps:encoder->sps pps:encoder->pps];
                }
            }
            
        }
        
    }
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length,totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            ///Read the NAL unit length
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            //convert the length value from big-endian to little-endian
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            NSData *data = [[NSData alloc] initWithBytes:(dataPointer+bufferOffset+AVCCHeaderLength) length:NALUnitLength];
            [encoder->_delegate gotEncodedData:data isKeyFrame:keyframe];
            ///move to the next NAL UNIT in the block buffer
            bufferOffset += AVCCHeaderLength +NALUnitLength;
        }
    }
}
@end
