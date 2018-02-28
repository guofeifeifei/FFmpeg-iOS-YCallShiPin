//
//  SMScreenRecording.m
//  SMScreenRecording
//
//  Created by 朱思明 on 2017/5/13.
//  Copyright © 2017年 朱思明. All rights reserved.
//

#import "SMScreenRecording.h"


@implementation SMScreenRecording

- (void)dealloc
{
    CGColorSpaceRelease(_rgbColorSpace);
    if (_outputBufferPool != NULL) {
        CVPixelBufferPoolRelease(_outputBufferPool);
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.countTime = 0;
        self.startTimeCount = 0;
        // 01 创建获取截图队列
        _concurrent_getImage_queue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
        
        // 02 创建写入视频队列
        _serial_writeVideo_queue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
        
        _rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        
    }
    return self;
}

/*
 *  单例方法
 */
+ (SMScreenRecording *)shareManager
{
    static SMScreenRecording *screenRecording = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        screenRecording = [[SMScreenRecording alloc] init];
    });
    return screenRecording;
}

/*
 *  开始录制屏幕
 *
 *  params: 指定视图的填充位置，可以录制指定区域
 */
- (void)startScreenRecordingWithScreenView:(UIView *)screenView failureBlock:(FailureBlock)failureBlock
{
    // 保存需要录制的视图
    _screenView = screenView;
    
    NSDictionary *bufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                       (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                                       (id)kCVPixelBufferWidthKey : @(_screenView.frame.size.width * kScreenScale),
                                       (id)kCVPixelBufferHeightKey : @(_screenView.frame.size.height * kScreenScale),
                                       (id)kCVPixelBufferBytesPerRowAlignmentKey : @(_screenView.frame.size.width * kScreenScale * 4)
                                       };
    if (_outputBufferPool != NULL) {
        CVPixelBufferPoolRelease(_outputBufferPool);
    }
    _outputBufferPool = NULL;
    CVPixelBufferPoolCreate(NULL, NULL, (__bridge CFDictionaryRef)(bufferAttributes), &_outputBufferPool);
    // 01 初始化时间
    _startTime = CFAbsoluteTimeGetCurrent();

    // 03 移除路径里面的数据
    [[NSFileManager defaultManager] removeItemAtPath:kMoviePath error:NULL];
    // 04 视频转换设置
    NSError *error = nil;
    _videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:kMoviePath]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    NSParameterAssert(_videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithFloat:screenView.frame.size.width * kScreenScale],
                                    AVVideoHeightKey: [NSNumber numberWithFloat:screenView.frame.size.height * kScreenScale]};
    
    _writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    // 05 保存block
    self.failureBlock = failureBlock;
    
    NSParameterAssert(_writerInput);
    NSParameterAssert([_videoWriter canAddInput:_writerInput]);
    [_videoWriter addInput:_writerInput];
    //Start a session:
    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    // 06
    // 创建定时器
//    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kFrames) target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    NSDate *nowDate = [NSDate date];

    _timer = [[NSTimer alloc] initWithFireDate:nowDate interval:1.0 / kFrames target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

/*
 *  停止录制屏幕
 *
 *  FinishBlock: 错误信息，视频地址
 */
- (void)endScreenRecordingWithFinishBlock:(FinishBlock) finishBlock;
{
    self.finishBlock = finishBlock;
    // 01 通知多线程停止操作
//    [self performSelector:@selector(threadend) onThread:_timer_thread withObject:nil waitUntilDone:YES];
    [_timer invalidate];
    _timer = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), _serial_writeVideo_queue, ^{
        [_writerInput markAsFinished];
        [_videoWriter finishWritingWithCompletionHandler:^{
            NSLog(@"Successfully closed video writer");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_videoWriter.status == AVAssetWriterStatusCompleted) {
                    NSLog(@"成功");
                    if (self.finishBlock != nil) {
                        self.finishBlock(nil, kMoviePath,self.startTimeCount, self.countTime);
                    }
                } else {
                    NSLog(@"失败");
                    if (self.finishBlock != nil) {
                        NSError *error = [NSError errorWithDomain:@"录制失败" code:-1 userInfo:nil];
                           self.finishBlock(error, nil, 1,1);
                    }
                }
                _writerInput = nil;
                _videoWriter = nil;
                _adaptor = nil;
            });
        }];
    });

}

// 定时器事件
- (void)timerAction:(NSTimer *)timer
{
    dispatch_sync(_concurrent_getImage_queue, ^{
        CVPixelBufferRef pixelBuffer = NULL;
        CGContextRef bitmapContext = [self createPixelBufferAndBitmapContext:&pixelBuffer];
//        dispatch_sync(dispatch_get_main_queue(), ^{
            UIGraphicsPushContext(bitmapContext); {
//                for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
                @synchronized (self) {
                    [_screenView drawViewHierarchyInRect:_screenView.bounds afterScreenUpdates:NO];
                }
//                }
            }; UIGraphicsPopContext();
        CGContextRelease(bitmapContext);
//        });
        dispatch_sync(_serial_writeVideo_queue, ^{
            [self wirteVideoWithBuffer:pixelBuffer];
        });
    });
    
}

- (CGContextRef)createPixelBufferAndBitmapContext:(CVPixelBufferRef *)pixelBuffer
{
    CVPixelBufferPoolCreatePixelBuffer(NULL, _outputBufferPool, pixelBuffer);
    CVPixelBufferLockBaseAddress(*pixelBuffer, 0);
    
    CGContextRef bitmapContext = NULL;
    bitmapContext = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(*pixelBuffer),
                                          CVPixelBufferGetWidth(*pixelBuffer),
                                          CVPixelBufferGetHeight(*pixelBuffer),
                                          8, CVPixelBufferGetBytesPerRow(*pixelBuffer), _rgbColorSpace,
                                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
                                          );
    CGContextScaleCTM(bitmapContext, kScreenScale, kScreenScale);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, _screenView.bounds.size.height);
    CGContextConcatCTM(bitmapContext, flipVertical);
    
    return bitmapContext;
}


// 图片写入视频流
- (void)wirteVideoWithBuffer:(CVPixelBufferRef)buffer {
    if (buffer) {
        int nowTime = (CFAbsoluteTimeGetCurrent() - _startTime) * kFrames;
        if (self.countTime == 0) {
            self.startTimeCount = nowTime;
        }
        self.countTime = nowTime;
        NSLog(@"🐶🐶🐶🐶🐶🐶🐶🐶buffer:frame %d",nowTime);
        @try {
            if(![_adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(nowTime, kFrames)]) {
                CVPixelBufferRelease(buffer);
            } else {
                CVPixelBufferRelease(buffer);
            }
            
           
        } @catch (NSException *exception) {
            NSLog(@"try异常处理%@",exception);
        } @finally {
        }
    }
}



@end
