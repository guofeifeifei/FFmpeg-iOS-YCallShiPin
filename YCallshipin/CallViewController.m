//
//  CallViewController.m
//  YCallshipin
//
//  Created by ZZCN77 on 2017/10/12.
//  Copyright © 2017年 ZZCN77. All rights reserved.
//

#import "CallViewController.h"
#import <WilddogVideoCall/WilddogVideoCall.h>
#import <WilddogAuth/WilddogAuth.h>
#import <WilddogCore/WilddogCore.h>
#import <AVFoundation/AVFoundation.h>
#import "AVViewController.h"
#import "AppDelegate.h"
#import "JKScreenRecorder.h"
#import "AVViewController.h"
#import "IGCMenu.h"
#import "XYQMovieObject.h"
#import "UIImageFiler.h"
#import "GSwitch.h"
#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)
@interface CallViewController ()<UIScrollViewDelegate,WDGVideoCallDelegate, WDGConversationDelegate, WDGLocalStreamDelegate,IGCMenuDelegate>{
        long int _count;
    long int _startCount;
    NSString * _opPath;
    int timeCount;
    NSTimer *_myTimer;
      NSTimer *_myTimer1;
     NSTimer *_myTimer2;
      BOOL _isRecing;//正在录制中
}
@property (nonatomic, strong) WDGLocalStream *localStream;
@property (nonatomic, strong) WDGConversation *conversation;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) WDGVideoView *remote;
@property (nonatomic, strong) UILabel *idLable;
@property (nonatomic, strong) WDGRemoteStream *remoteStream;
@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic, strong) IGCMenu *igcMenu;
@property (nonatomic, strong) XYQMovieObject *video;
@property (nonatomic, assign) long int frameTime;
@property (nonatomic, assign) double nextFrameTime;
@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *lastBtn;
@property (nonatomic, strong) GSwitch *recordingBtn;
@property (nonatomic, assign) BOOL theColor;//反色
@property (nonatomic, assign) BOOL theLiang;//亮度
@property (nonatomic, assign) float liangDu;//亮度

@end

@implementation CallViewController
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0 * widthScale, 0 * widthScale, self.view.frame.size.width - 0 * widthScale, self.view.frame.size.height - 0 * widthScale)];
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 3.0;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
    }
    return _scrollView;
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.remote;
}
//使缩小放大的图片位置中间
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?(scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.remote.center = CGPointMake((scrollView.contentSize.width - 20 * widthScale)* 0.5 + offsetX,
                                        
                                        (scrollView.contentSize.height - 30 * widthScale) * 0.5 + offsetY);
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            
            interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.userInteractionEnabled = YES;
    [self.view addSubview: self.currentImageView ];
    //速率
    _isRecing = NO;
    _count = 0;
    _startCount = 0;
    _liangDu = 0;
    _theColor = NO;
    NSString *appUrlID = @"wd2594166845uulehn";
    WDGOptions *options = [[WDGOptions alloc] initWithSyncURL:[NSString stringWithFormat:@"https://%@.wilddogio.com", appUrlID]];
    [WDGApp configureWithOptions:options];

    WDGLocalStreamOptions *localStreamOptions = [[WDGLocalStreamOptions alloc] init];
    localStreamOptions.shouldCaptureAudio = NO;
    localStreamOptions.dimension = WDGVideoDimensions360p;
    self.localStream = [WDGLocalStream localStreamWithOptions:localStreamOptions];
    self.localStream.audioEnabled = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.remote =[[WDGVideoView alloc] initWithFrame:self.view.frame];
//    self.remote.frame = CGRectMake(KMainScreenWidth - 100 * kwidthScale, KMainScreenHeight - 150* kwidthScale, 100* kwidthScale, 150* kwidthScale);
    self.remote.backgroundColor = [UIColor blackColor];
    self.remote.contentMode  = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.remote];
    // 双击的 Recognizer
    UITapGestureRecognizer * doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeRemoteFrame:)];
    doubleRecognizer.numberOfTapsRequired = 1; // 双击
    //关键语句，给self.view添加一个手势监测；
    [self.remote addGestureRecognizer:doubleRecognizer];

//    // 关键在这一行，双击手势确定监测失败才会触发单击手势的相应操作
//    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];

    [self login: [userDefaults objectForKey:@"username"]];

    self.idLable = [[UILabel alloc] initWithFrame:CGRectMake(KMainScreenWidth - 170 * widthScale, 160 * widthScale, 300 * widthScale, 20 * widthScale)];
    self.idLable.font = [UIFont systemFontOfSize:16 * widthScale];
    self.idLable.textColor = [UIColor colorWithRed:222/255.0 green:120.0/255.0 blue:137.0/255.0 alpha:1.0];
    self.idLable.backgroundColor = [UIColor clearColor];
    self.idLable.transform = CGAffineTransformRotate(self.idLable.transform, M_PI/2);
    self.idLable.text = @"等待连接...";
    self.idLable.textAlignment = 0;
     [self.view addSubview:self.idLable];

    self.bgImage = [[UIImageView alloc] initWithFrame:self.remote.frame];
    self.bgImage.hidden = YES;
    [self.view addSubview:self.bgImage];
    
    
//    [self creatVideo];
    [self.view addSubview:self.nextBtn];
    [self.view addSubview:self.recordingBtn];
    [self.view addSubview:self.lastBtn];
    [self.view addSubview:self.buttonView];
    [self.buttonView addSubview:self.selectBtn];

    
    [self showSetupMenu];
//    [self recordingAction];
}

- (void)creatVideo{
   self.video = [[XYQMovieObject alloc] initWithVideo:@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"];
    int tns, thh, tmm, tss;
    tns = self.video.duration;
    thh = tns / 3600;
    tmm = (tns % 3600) / 60;
    tss = tns % 60;
    NSLog(@"fps --> %.2f", self.video.fps);
    //        [ImageView setTransform:CGAffineTransformMakeRotation(M_PI)];
    NSLog(@"%02d:%02d:%02d",thh,tmm,tss);
    // seek to 0.0 seconds
    [self.video seekTime:0.0];
    [self.video stepFrame];
     self.currentImageView.image = self.video.currentImage;
    
    _myTimer2 = [NSTimer scheduledTimerWithTimeInterval: 1 / 25
                                     target:self
                                   selector:@selector(nextAction11)
                                   userInfo:nil
                                    repeats:YES];
    

}
- (void)nextAction11{
    [self.video stepFrame];
    self.currentImageView.image = self.video.currentImage;

}
#pragma mark 登录

- (void)login:(NSString *)appID{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [[WDGAuth auth] signInWithEmail:appID
                           password:appID
                         completion:^(WDGUser *user, NSError *error) {
                             NSLog(@"%@", user);
                             if (!error) {
                                 NSLog(@"登陆成功");
                                 [userDefaults setValue:appID forKey:@"username"];
                                 
                               
                                     [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"登录成功"];

                                     //初始化视频
                                     [self signInAnonymously];
                                     
                                     
                             }else{
                          
                                    [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"重试登录请稍后"];
                                 NSLog(@"登录失败%@",error.description);
                                     [self login:appID];
                             }
                             
                             
                         }];
}
- (void)signInAnonymously{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"开始连接"];

    });
   // [[WDGAuth auth] signOut:nil];

    [[WDGAuth auth] signInAnonymouslyWithCompletion:^(WDGUser *user, NSError *error) {
        if (!error) {
            // 获取 token
            [user getTokenWithCompletion:^(NSString * _Nullable idToken, NSError * _Nullable error) {
                // 配置 Video Initializer
                [[WDGVideoInitializer sharedInstance] configureWithVideoAppId:@"wd2594166845uulehn" token:idToken];
       
                //邀请视频
                NSLog(@"%@", self.callID);
                self.conversation = [[WDGVideoCall sharedInstance] callWithUid:self.callID localStream:self.localStream data:@"给你发送视频邀请"];
                 self.conversation.delegate = self;
                //代理
                [WDGVideoCall sharedInstance].delegate  = self;

            }];
        }
    }];
}
#pragma mark  WDGConversation 通过调用该方法通知代理当前视频通话发生错误而未能建立连接。
- (void)conversation:(WDGConversation *)conversation didReceiveResponse:(WDGCallStatus)callStatus{
    switch (callStatus) {
      
        case WDGCallStatusAccepted:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"接收视频邀请"];

                });
                NSLog(@"WDGCallStatusAccepted");
               
                
            }
            break;
        case WDGCallStatusRejected:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"拒绝视频邀请"];

                //初始化视频
                [self signInAnonymously];
            });
            NSLog(@"WDGCallStatusRejected");

        }
            break;
        case WDGCallStatusBusy:
        {
            NSLog(@"WDGCallStatusBusy");
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"对方忙碌"];

                //初始化视频
                [self signInAnonymously];
            });
        }
            break;
        case WDGCallStatusTimeout:
        {
            NSLog(@"WDGCallStatusTimeout");
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"请求超时"];

                //初始化视频
                [self signInAnonymously];
            });
          
            
        }
            break;
        default:
            break;
    }

}

//播放媒体流
- (void)conversation:(WDGConversation *)conversation didReceiveStream:(WDGRemoteStream *)remoteStream {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.remoteStream = remoteStream;
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"开始接收视频"];
        self.remoteStream.audioEnabled = NO;
        self.idLable.text = [NSString stringWithFormat:@"ID:%@", conversation.remoteUid];
        [self.remoteStream attach: self.remote];
        self.conversation = conversation;

    });
}
////失败
//- (void)conversation:(WDGConversation *)conversation didFailedWithError:(NSError *)error{
//    NSLog(@"%@", error.description);
//    NSLog(@"通过调用该方法通知代理当前视频通话已被关闭。");
//}
////WDGConversation 通过调用该方法通知代理当前视频通话已被关闭。
//- (void)conversationDidClosed:(WDGConversation *)conversation{
//    NSLog(@"通过调用该方法通知代理当前视频通话已被关闭。");
//
//}


- (UIButton *)selectBtn{
    if (_selectBtn == nil) {
        self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selectBtn.frame = CGRectMake(20* widthScale, 0  * widthScale, 40 * widthScale,40 * widthScale );
        [self.selectBtn addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.selectBtn setImage:[UIImage imageNamed:@"setting"] forState:0];
        self.selectBtn.selected = NO;
    }
    return _selectBtn;
}
- (GSwitch *)recordingBtn{
    if (_recordingBtn == nil) {
        self.recordingBtn = [[GSwitch alloc] initWithFrame:CGRectMake(20 * kwidthScale, KMainScreenHeight - 100 * widthScale, 60 * kwidthScale, 30 * kwidthScale)];
        self.recordingBtn.tintColor = [UIColor grayColor];
        [self.recordingBtn addTarget:self action:@selector(recordingAction2) forControlEvents:UIControlEventValueChanged];
        self.recordingBtn.on = NO;
    }
    return _recordingBtn;
}
#pragma mark--- 开始录制
//开始录制
- (void)recordingAction{
    //开始录屏
    if (_isRecing == YES) {
        return ;
    }
    _isRecing = YES;
    [[SMScreenRecording shareManager] startScreenRecordingWithScreenView:self.view failureBlock:^(NSError *error) {
    }];
                
}
- (void)recordingAction2{
        if (self.recordingBtn.isOn == YES) {
            //开始录制
            [self recordingAction];
        }else{
            //结束录制
            //停止录制
            [[SMScreenRecording shareManager] endScreenRecordingWithFinishBlock:^(NSError *error, NSString *videoPath, long int startCount, long int zCount) {
                _isRecing =NO;

                if (error != nil) {
                    [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"录制视频失败"];
                    return ;
                }
                NSLog(@"%@", videoPath);
                _opPath = videoPath;
                // 初始化视频媒体文件
                _count = zCount;
                _frameTime = zCount;
                _startCount = startCount;
                if (_theColor == YES) {
                    UIImage *img = [self getVideoPreViewImage];
                    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
                    [filter forceProcessingAtSize:img.size];
                    GPUImageColorInvertFilter *colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
                    //把多个滤镜对象放到数组中
                    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:img];
                    self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
                    //将滤镜组加在GPUImagePicture上
                    [stillImageSource addTarget:self.myFilterGroup];
                    //添加上滤镜
                    //将滤镜加在FilterGroup中
                    [self addGPUImageFilter:filter];
                    [self addGPUImageFilter:colorInvertFilter];
                    //开始渲染
                    [stillImageSource processImage];
                    [self.myFilterGroup useNextFrameForImageCapture];
                    //获取渲染后的图片
                    self.currentImageView.image = [self.myFilterGroup imageFromCurrentFramebuffer];
                }else if (_liangDu > 0){
                    UIImage *myImage = [self getVideoPreViewImage];
                    GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
                    [filter setBrightness:_liangDu];
                    [filter forceProcessingAtSize:myImage.size];
                    [filter useNextFrameForImageCapture];
                    GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:myImage];
                    [stillImageSource addTarget:filter];
                    [stillImageSource processImage];
                    self.currentImageView.image = [filter imageFromCurrentFramebuffer];
                }else{
                    self.currentImageView.image = [self getVideoPreViewImage];
                }
            }];
        }
}


- (UIButton *)nextBtn{
    if (_nextBtn == nil) {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nextBtn.frame = CGRectMake(20* widthScale,  150  * widthScale, 40 * widthScale,40 * widthScale );
        [self.nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.nextBtn setImage:[UIImage imageNamed:@"houtui"] forState:0];
        //button长按事件
        
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(btnLong:)];
        
        longPress.minimumPressDuration=0.8;//定义按的时间
        [self.nextBtn addGestureRecognizer:longPress];
        

    }
    return _nextBtn;
}

- (UIButton *)lastBtn{
    if (_lastBtn == nil) {
        self.lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.lastBtn.frame = CGRectMake(20* widthScale,  50  * widthScale, 40 * widthScale,40 * widthScale );
        [self.lastBtn addTarget:self action:@selector(lastAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.lastBtn setImage:[UIImage imageNamed:@"kuaijin"] forState:0];
        //button长按事件
        
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(lastLong:)];
        
        longPress.minimumPressDuration=0.8;//定义按的时间
        [self.lastBtn addGestureRecognizer:longPress];
        
        
    }
    return _lastBtn;
}


- (void)changeAction:(UIButton *)btn{
    
    if (btn.selected == NO) {
        btn.selected = YES;
        [_igcMenu showHorLineMenu];
        
    }else{
        btn.selected = NO;
        [_igcMenu hideHorLineMenu];
    }
}
- (void)showSetupMenu{
    self.selectBtn.clipsToBounds = YES;
    self.selectBtn.layer.cornerRadius = self.selectBtn.frame.size.height / 2;
    if (_igcMenu == nil) {
        _igcMenu = [[IGCMenu alloc] init];
        
    }
    
    _igcMenu.menuButton = self.selectBtn;   //Pass refernce of menu button
    _igcMenu.menuSuperView = self.buttonView;      //Pass reference of menu button super view
    _igcMenu.disableBackground = YES;        //Enable/disable menu background
    _igcMenu.numberOfMenuItem = 4;           //Number of menu items to display
    
    //Menu background. It can be BlurEffectExtraLight,BlurEffectLight,BlurEffectDark,Dark or None
    _igcMenu.backgroundType = None;
    _igcMenu.menuHeight = 50;
    /* Optional
     Pass name of menu items
     **/
    _igcMenu.menuItemsNameArray = [NSArray arrayWithObjects:@"saoma",@"setting",@"saoma",@"setting",nil];
    
    /*Optional
     Pass color of menu items
     **/
    UIColor *homeBackgroundColor = [UIColor clearColor];
    UIColor *searchBackgroundColor = [UIColor clearColor];
    
    _igcMenu.menuBackgroundColorsArray = [NSArray arrayWithObjects:homeBackgroundColor,searchBackgroundColor,searchBackgroundColor,searchBackgroundColor,nil];
    
    /*Optional
     Pass menu items icons
     **/
    _igcMenu.menuImagesNameArray = [NSArray arrayWithObjects:@"saoma",@"setting",@"saoma",@"setting",nil];
    
    /*Optional if you don't want to get notify for menu items selection
     conform delegate
     **/
    _igcMenu.delegate = self;
}
#pragma mark 工具事件
- (void)igcMenuSelected:(NSString *)selectedMenuName atIndex:(NSInteger)index{
    if (_myTimer2!= nil) {
        [_myTimer2 invalidate];
        _myTimer2 = nil;
    }
    [[SMScreenRecording shareManager] endScreenRecordingWithFinishBlock:^(NSError *error, NSString *videoPath, long int startCount, long int zCount) {
        _isRecing =NO;

        NSLog(@"%@", videoPath);
        _opPath = videoPath;
        // 初始化视频媒体文件
        _count = zCount;
        _frameTime = zCount;
        _startCount = startCount;
        self.currentImageView.image = [self getVideoPreViewImage];
        
        switch (index) {
            case 0:
            {
                //恢复
                
            }
                break;
            case 1:{
                //翻转
                [self rotateViewAnimated:self.remote withDuration:0.5 byAngle:180];
            }
                
                break;
            case 2:  {
                //亮度
                if (_opPath == nil) {
                    return;
                }
                if (_liangDu >= 0.8) {
                    _liangDu = 0.0;
                }else{
                    _liangDu += 0.4;
                }
                UIImage *myImage = [self getVideoPreViewImage];
                GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
                [filter setBrightness:_liangDu];
                [filter forceProcessingAtSize:myImage.size];
                [filter useNextFrameForImageCapture];
                GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:myImage];
                [stillImageSource addTarget:filter];
                [stillImageSource processImage];
                self.currentImageView.image = [filter imageFromCurrentFramebuffer];
                
            }
                break;
            case 3:{
                //去反色
                if (_opPath == nil) {
                    return;
                }
                if (_theColor == NO) {
                    
                    _theColor = YES;
                    UIImage *img = [self getVideoPreViewImage];
                    GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
                    [filter forceProcessingAtSize:img.size];
                    
                    GPUImageColorInvertFilter *colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
                    //把多个滤镜对象放到数组中
                    
                    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:img];
                    
                    self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
                    //将滤镜组加在GPUImagePicture上
                    [stillImageSource addTarget:self.myFilterGroup];
                    //添加上滤镜
                    //将滤镜加在FilterGroup中
                    [self addGPUImageFilter:filter];
                    [self addGPUImageFilter:colorInvertFilter];
                    //开始渲染
                    [stillImageSource processImage];
                    [self.myFilterGroup useNextFrameForImageCapture];
                    //获取渲染后的图片
                    self.currentImageView.image = [self.myFilterGroup imageFromCurrentFramebuffer];
                }else{
                    _theColor = NO;
                    self.currentImageView.image = [self getVideoPreViewImage];
                }
            }
                
                break;
            case 4:
                
                break;
            default:
                break;
        }
    }];
}
- (UIImageView *)currentImageView{
    if (_currentImageView == nil) {
        self.currentImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        self.currentImageView.image = [UIImage imageNamed:@"bg"];
        self.currentImageView.userInteractionEnabled = YES;
//        float centerX = self.view.bounds.size.width/2;
//        float centerY = self.view.bounds.size.height/2;
//        float x = self.view.bounds.size.width/2;
//        float y = self.view.bounds.size.height/2;
        
//        CGAffineTransform trans = GetCGAffineTransformRotateAroundPoint(centerX,centerY ,x ,y ,90/180.0*M_PI);
//        self.currentImageView.transform = CGAffineTransformIdentity;
//        self.currentImageView.transform = trans;
//        self.currentImageView.frame = CGRectMake(0, 0, KMainScreenWidth, KMainScreenHeight);
    }
    return _currentImageView;
}
CGAffineTransform  GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle)
{
    x = x - centerX; //计算(x,y)从(0,0)为原点的坐标系变换到(CenterX ，CenterY)为原点的坐标系下的坐标
    y = y - centerY; //(0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样
    
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}
#pragma mark 切换视频窗口大小
-(void)changeRemoteFrame:(UITapGestureRecognizer*)recognizer
{
    //处理双击操作
    if ( self.remote.frame.size.width != self.view.frame.size.width) {
        [UIView animateWithDuration:0.5 animations:^{
            self.remote.frame = self.view.frame;
        }];
        //开始录制
        [self recordingAction];
        self.recordingBtn.on = YES;

    }else{
        self.recordingBtn.on = NO;

    [UIView animateWithDuration:0.5 animations:^{
        self.remote.frame = CGRectMake(KMainScreenWidth - 100 * kwidthScale , KMainScreenHeight - 150 * kwidthScale, 100 * kwidthScale, 150 * kwidthScale);
    }];
        //停止录制
        [[SMScreenRecording shareManager] endScreenRecordingWithFinishBlock:^(NSError *error, NSString *videoPath, long int startCount, long int zCount) {
            _isRecing =NO;

            if (error != nil) {
                 [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"录制视频失败"];
                return ;
            }
            NSLog(@"%@", videoPath);
            _opPath = videoPath;
            // 初始化视频媒体文件
            _count = zCount;
            _frameTime = zCount;
            _startCount = startCount;
            if (_theColor == YES) {
                UIImage *img = [self getVideoPreViewImage];
                GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
                [filter forceProcessingAtSize:img.size];
                GPUImageColorInvertFilter *colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
                //把多个滤镜对象放到数组中
                GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:img];
                self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
                //将滤镜组加在GPUImagePicture上
                [stillImageSource addTarget:self.myFilterGroup];
                //添加上滤镜
                //将滤镜加在FilterGroup中
                [self addGPUImageFilter:filter];
                [self addGPUImageFilter:colorInvertFilter];
                //开始渲染
                [stillImageSource processImage];
                [self.myFilterGroup useNextFrameForImageCapture];
                //获取渲染后的图片
                self.currentImageView.image = [self.myFilterGroup imageFromCurrentFramebuffer];
            }else if (_liangDu > 0){
                UIImage *myImage = [self getVideoPreViewImage];
                GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
                [filter setBrightness:_liangDu];
                [filter forceProcessingAtSize:myImage.size];
                [filter useNextFrameForImageCapture];
                GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:myImage];
                [stillImageSource addTarget:filter];
                [stillImageSource processImage];
                self.currentImageView.image = [filter imageFromCurrentFramebuffer];
            }else{
                self.currentImageView.image = [self getVideoPreViewImage];
            }
        }];
    }
}
- (void)nextAction:(UIButton *)btn{
    if (_count ==0) {
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"没有录制视频"];
        return;
    }
      _count += 1;
    NSLog(@"当前数量-------%ld", _count);

    if (_count > _frameTime) {
        _count = _frameTime;
        if (_myTimer!= nil) {
            [_myTimer invalidate];
            _myTimer = nil;
        }
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"已经是最后一张了"];
        return;
    }
    if (_theColor == YES) {
        UIImage *img = [self getVideoPreViewImage];
        GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
        [filter forceProcessingAtSize:img.size];
        GPUImageColorInvertFilter *colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
        //把多个滤镜对象放到数组中
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:img];
        self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
        //将滤镜组加在GPUImagePicture上
        [stillImageSource addTarget:self.myFilterGroup];
        //添加上滤镜
        //将滤镜加在FilterGroup中
        [self addGPUImageFilter:filter];
        [self addGPUImageFilter:colorInvertFilter];
        //开始渲染
        [stillImageSource processImage];
        [self.myFilterGroup useNextFrameForImageCapture];
        //获取渲染后的图片
        self.currentImageView.image = [self.myFilterGroup imageFromCurrentFramebuffer];
    }else if (_liangDu > 0){
        UIImage *myImage = [self getVideoPreViewImage];
        GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
        [filter setBrightness:_liangDu];
        [filter forceProcessingAtSize:myImage.size];
        [filter useNextFrameForImageCapture];
        GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:myImage];
        [stillImageSource addTarget:filter];
        [stillImageSource processImage];
        self.currentImageView.image = [filter imageFromCurrentFramebuffer];
    }else{
        self.currentImageView.image = [self getVideoPreViewImage];
    }

  
}
- (void)lastAction:(UIButton *)btn{
    if (_count == 0) {
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"没有录制视频"];
        return;
    }

    _count -= 1;
    NSLog(@"当前数量-------%ld", _count);
    if (_count <= _startCount) {
        _count = _startCount;
        if (_myTimer1!= nil) {
            [_myTimer1 invalidate];
            _myTimer1 = nil;
        }
         [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"已经是第一张了"];
        return;
    }
    if (_opPath == nil) {
     [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"没有录制视频"];
    }else{
        if (_theColor == YES) {
            UIImage *img = [self getVideoPreViewImage];
            GPUImageGrayscaleFilter *filter = [[GPUImageGrayscaleFilter alloc] init];
            [filter forceProcessingAtSize:img.size];
            GPUImageColorInvertFilter *colorInvertFilter = [[GPUImageColorInvertFilter alloc] init];
            //把多个滤镜对象放到数组中
            GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:img];
            self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
            //将滤镜组加在GPUImagePicture上
            [stillImageSource addTarget:self.myFilterGroup];
            //添加上滤镜
            //将滤镜加在FilterGroup中
            [self addGPUImageFilter:filter];
            [self addGPUImageFilter:colorInvertFilter];
            //开始渲染
            [stillImageSource processImage];
            [self.myFilterGroup useNextFrameForImageCapture];
            //获取渲染后的图片
            self.currentImageView.image = [self.myFilterGroup imageFromCurrentFramebuffer];
        }else if (_liangDu > 0){
            UIImage *myImage = [self getVideoPreViewImage];
            GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
            [filter setBrightness:_liangDu];
            [filter forceProcessingAtSize:myImage.size];
            [filter useNextFrameForImageCapture];
            GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:myImage];
            [stillImageSource addTarget:filter];
            [stillImageSource processImage];
            self.currentImageView.image = [filter imageFromCurrentFramebuffer];
        }else{
            self.currentImageView.image = [self getVideoPreViewImage];
        }
    }
    

}
- (UIImage*)getVideoPreViewImage
{
    if (_opPath == nil) {
        return nil;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_opPath] options:nil];
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(_count, kFrames) actualTime:NULL error:&thumbnailImageGenerationError];
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}


-(void)btnLong:(UILongPressGestureRecognizer*)gestureRecognizer{
    if([gestureRecognizer state] ==UIGestureRecognizerStateBegan){
        if (_myTimer == nil) {
            _myTimer =  [NSTimer scheduledTimerWithTimeInterval: 1 / kFrames
                                                         target:self
                                                       selector:@selector(nextAction:)
                                                       userInfo:nil
                                                        repeats:YES];
        }
    }else if ( [gestureRecognizer state] == UIGestureRecognizerStateEnded){
        NSLog(@"终止");

            if (_myTimer!= nil) {
                [_myTimer invalidate];
                _myTimer = nil;
            }
    }
    
    
}
-(void)lastLong:(UILongPressGestureRecognizer*)gestureRecognizer{
    if([gestureRecognizer state] ==UIGestureRecognizerStateBegan){
        if (_myTimer1 == nil) {
            _myTimer1 =  [NSTimer scheduledTimerWithTimeInterval: 1 / kFrames
                                                         target:self
                                                       selector:@selector(lastAction:)
                                                       userInfo:nil
                                                        repeats:YES];
            

            
        }
    }else if ( [gestureRecognizer state] == UIGestureRecognizerStateEnded){

        if (_myTimer1!= nil) {
            [_myTimer1 invalidate];
            _myTimer1 = nil;
        }
    }
}



- (void)rotateViewAnimated:(UIView*)view
               withDuration:(CFTimeInterval)duration
                    byAngle:(CGFloat)angle
{
    [CATransaction begin];
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.byValue = [NSNumber numberWithFloat:angle];
    rotationAnimation.duration = duration;
    rotationAnimation.removedOnCompletion = YES;
    
    [CATransaction setCompletionBlock:^{
        //view.transform = CGAffineTransformRotate(view.transform, angle);
    }];
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [CATransaction commit];
}
- (UIView *)buttonView{
    if (_buttonView == nil) {
        self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0* widthScale, KMainScreenHeight - 50  * widthScale, KMainScreenWidth,40 * widthScale)];
    }
    return _buttonView;
}
#pragma mark 将滤镜加在FilterGroup中并且设置初始滤镜和末尾滤镜
- (void)addGPUImageFilter:(GPUImageFilter *)filter{
    
    [self.myFilterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = self.myFilterGroup.filterCount;
    
    if (count == 1)
    {
        //设置初始滤镜
        self.myFilterGroup.initialFilters = @[newTerminalFilter];
        //设置末尾滤镜
        self.myFilterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = self.myFilterGroup.terminalFilter;
        NSArray *initialFilters                          = self.myFilterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        //设置初始滤镜
        self.myFilterGroup.initialFilters = @[initialFilters[0]];
        //设置末尾滤镜
        self.myFilterGroup.terminalFilter = newTerminalFilter;
    }
}
@end
