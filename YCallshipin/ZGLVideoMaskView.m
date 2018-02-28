

//
//  ZGLVideoMaskView.m
//  ZGLVideoPlayer
//
//  Created by 智捷电商APPLE01 on 16/12/1.
//  Copyright © 2016年 智捷电商APPLE01. All rights reserved.
//

#import "ZGLVideoMaskView.h"


@interface ZGLVideoMaskView ()

@property (nonatomic, copy) ButtonClick playBtnClick;

@property (nonatomic, copy) ButtonClick fullScreenBtnClick;
@property (nonatomic, copy) ButtonClick kuaijinBtnClick;
@property (nonatomic, copy) ButtonClick houtuiBtnClick;
@property (nonatomic, copy) ButtonClick backBtnClick;

@end

@implementation ZGLVideoMaskView



- (instancetype)initWithFrame:(CGRect)frame
                 playBtnClick: (void (^) (UIButton *playBtn))playBtnClick
           fullScreenBtnClick: (void (^) (UIButton *fullScreenBtn))fullScreenBtnClick  kuaijinBtnClick: (void (^) (UIButton *kuaijin))kuaijinBtnClick
               houtuiBtnClick: (void (^) (UIButton *houtui))houtuiClick
                    backClick: (void (^) (UIButton *backBtn))backBtnClick{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.userInteractionEnabled = YES;
        self.playBtnClick = playBtnClick;
        self.fullScreenBtnClick = fullScreenBtnClick;
        self.kuaijinBtnClick = kuaijinBtnClick;
        self.houtuiBtnClick = houtuiClick;
        self.backBtnClick = backBtnClick;
        UITapGestureRecognizer *hidenTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenBottonView:)];
        
        [self addGestureRecognizer:hidenTap];
    }
    
    return self;
}

- (void)hiddenBottonView: (UITapGestureRecognizer *)tap {

    if (self.bottomBackgroundView.hidden) {
        self.bottomBackgroundView.hidden = NO;
        self.kuaijin.hidden = NO;
        self.houtui.hidden = NO;
    }else {
        self.kuaijin.hidden = YES;
        self.houtui.hidden = YES;
        self.bottomBackgroundView.hidden = YES;
    }
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    [self createViews];
}

-(void)createViews {
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.frame = CGRectMake(KMainScreenWidth - 40 * widthScale, 10 * widthScale, 30 * widthScale, 30 * widthScale);
    [self.backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateSelected];
//    [self addSubview:self.backBtn];
    
    self.kuaijin = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.kuaijin addTarget:self action:@selector(kuaijinClick:) forControlEvents:UIControlEventTouchUpInside];
    self.kuaijin.frame = CGRectMake(50 * widthScale, KMainScreenHeight/2 -100  * widthScale, 50 * widthScale, 50 * widthScale);

    [self.kuaijin setImage:[UIImage imageNamed:@"kuaijin"] forState:UIControlStateNormal];
    [self.kuaijin setImage:[UIImage imageNamed:@"kuaijin"] forState:UIControlStateSelected];
    [self addSubview:self.kuaijin];
    
    
    self.houtui = [UIButton buttonWithType:UIButtonTypeCustom];
    self.houtui.frame = CGRectMake(50 * widthScale, KMainScreenHeight/2 + 50 * widthScale, 50 * widthScale, 50 * widthScale);
    [self.houtui addTarget:self action:@selector(houtuiClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.houtui setImage:[UIImage imageNamed:@"houtui"] forState:UIControlStateNormal];
    [self.houtui setImage:[UIImage imageNamed:@"houtui"] forState:UIControlStateSelected];
    [self addSubview:self.houtui];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playBtn setImage:[UIImage imageNamed:@"videoPlayBtn"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"videoPauseBtn"] forState:UIControlStateSelected];
    
    self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  //  [self addSubview:self.activityView];
    
    self.bottomBackgroundView = [[UIView alloc] init];
    self.bottomBackgroundView.backgroundColor = [UIColor blackColor];
    self.bottomBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:self.bottomBackgroundView];
    [self.bottomBackgroundView addSubview:self.playBtn];
    
    self.currentTimeLabel = [[UILabel alloc]init];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:11];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.text = @"00:00";
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomBackgroundView addSubview:self.currentTimeLabel];
    
    self.totalTimeLabel = [[UILabel alloc]init];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:11];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.text = @"00:00";
    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomBackgroundView addSubview:self.totalTimeLabel];
    
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"exitFullScreen"] forState:UIControlStateSelected];
    [self.bottomBackgroundView addSubview:self.fullScreenBtn];
    
    self.videoSlider = [[UISlider alloc]init];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"videoPlayerSlider"] forState:UIControlStateNormal];
    self.videoSlider.minimumTrackTintColor = [UIColor whiteColor];
    self.videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    [self.bottomBackgroundView addSubview:self.videoSlider];
    
//    self.progessView = [[UIProgressView alloc]init];
//    self.progessView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
//    self.progessView.trackTintColor = [UIColor clearColor];
//
//    [self.bottomBackgroundView addSubview:self.progessView];
}

//playBtnClick
- (void)playBtnClick: (UIButton *)button {
    
    if (self.playBtnClick != nil) {
        self.playBtnClick(button);
    }
}

- (void)fullScreenBtnCLick: (UIButton *)button {
    
    if (self.fullScreenBtnClick != nil) {
        self.fullScreenBtnClick (button);
    }
}
- (void)kuaijinClick:(UIButton *)button {
    
    if (self.kuaijinBtnClick != nil) {
        self.kuaijinBtnClick(button);
    }
}
- (void)houtuiClick:(UIButton *)button {
    
    if (self.houtuiBtnClick != nil) {
        self.houtuiBtnClick(button);
    }
}
- (void)backClick:(UIButton *)button {
    
    if (self.backBtnClick != nil) {
        self.backBtnClick(button);
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat heihgt = self.frame.size.height;
    
    self.playBtn.frame = CGRectMake(0, 0, 50* widthScale, 50* widthScale);
    
    CGPoint center = CGPointMake(width / 2, heihgt / 2);
    self.activityView.center = center;
    
    self.bottomBackgroundView.frame = CGRectMake(0, 0, 50* widthScale, KMainScreenHeight);
    self.bottomBackgroundView.backgroundColor = [UIColor clearColor];
    self.currentTimeLabel.frame = CGRectMake(0, 30* widthScale, 50* widthScale, 50* widthScale);
    self.currentTimeLabel.transform =CGAffineTransformMakeRotation(M_PI_2);

    //self.fullScreenBtn.frame = CGRectMake(width - 50, 0, 50, self.bottomBackgroundView.frame.size.height);
    CGFloat totalX = CGRectGetMinX(self.fullScreenBtn.frame);
    
    self.totalTimeLabel.frame = CGRectMake(0, KMainScreenHeight - 60* widthScale, 50* widthScale , 60* widthScale);
 self.totalTimeLabel.transform =CGAffineTransformMakeRotation(M_PI_2);
    
    self.videoSlider.frame = CGRectMake(-235 * widthScale, KMainScreenHeight/2, KMainScreenHeight - 150* widthScale, 55* widthScale);
    self.videoSlider.transform =CGAffineTransformMakeRotation(M_PI_2);

    self.videoSlider.backgroundColor = [UIColor clearColor];

    //self.progessView.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), 24, sliderWidth, self.bottomBackgroundView.frame.size.height + 3);
}

@end
