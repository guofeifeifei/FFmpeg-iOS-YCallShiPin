//
//  SGFileManager.h
//  YCallshipin
//
//  Created by ZZCN77 on 2017/12/15.
//  Copyright © 2017年 ZZCN77. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGFileManager : NSObject
+ (instancetype)shareInstance;

- (NSData *)readFile:(NSString *)path;
- (void)readFileAsync:(NSString *)path complete:(void (^)(NSData *data))complete;

- (BOOL)writeFile:(NSString *)path data:(NSData *)data;
- (void)writeFileAsync:(NSString *)path data:(NSData *)data complete:(void (^)(BOOL result))complete;
@end
