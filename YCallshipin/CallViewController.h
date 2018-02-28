//
//  CallViewController.h
//  YCallshipin
//
//  Created by ZZCN77 on 2017/10/12.
//  Copyright © 2017年 ZZCN77. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "SMScreenRecording.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GPUImage.h"
#import "GPUImageBrightnessFilter.h"//亮度
#import "GPUImageGrayscaleFilter.h"                 //灰度
#import "GPUImageColorInvertFilter.h"               //反色
#define kFrames (10)
//跳转几秒的帧
@interface CallViewController : UIViewController
@property (nonatomic, copy) NSString *callID;
@property (nonatomic,strong)GPUImageFilterGroup *myFilterGroup;

@end
