//
//  UIImageFiler.h
//  YCallshipin
//
//  Created by ZZCN77 on 2018/1/19.
//  Copyright © 2018年 ZZCN77. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageFiler : NSObject
// 美白算法：
// 1、最小二乘法曲线拟合
// 2、公式推导
// 3、工具分析：Matlab
// 4、深度学习
// 5、映射表（实现如下：）
+ (unsigned char *)imageLightWithData:(unsigned char * )imageData width:(CGFloat)width height:(CGFloat)height;
// 彩色底版图像算法(颜色反转：newValue = 255 - oldValue)
+ (unsigned char *)imageReverseColorWithData:(unsigned char * )imageData width:(CGFloat)width height:(CGFloat)height;

// 灰度算法：Gray = 0.299 * red + 0.587 * green + 0.114 * blue
// int gray = red * 77 / 255 + green * 151 / 255 + blue * 88 / 255;
+ (unsigned char *)imageGrayWithData:(unsigned char * )imageData width:(CGFloat)width height:(CGFloat)height;
// unsigned char * CoreGraphics
// 1 UIImage -> CGImage
// 2 CGColorSpace
// 3 分配bit级空间
// 4 CGBitmap
// 5 渲染
+(unsigned char *)convertUIImage2data:(UIImage *)image;

+ (UIImage *)convertData2UIImage:(unsigned char *)data image:(UIImage *)imageSource;
@end
