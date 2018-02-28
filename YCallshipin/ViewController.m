//
//  ViewController.m
//  YCallshipin
//
//  Created by ZZCN77 on 2017/10/12.
//  Copyright © 2017年 ZZCN77. All rights reserved.
//

#import "ViewController.h"
#import <WilddogVideoCall/WilddogVideoCall.h>
#import <WilddogAuth/WilddogAuth.h>
#import <WilddogCore/WilddogCore.h>
#import <CoreTelephony/CTCellularData.h>
#import "CallViewController.h"
#import "AVViewController.h"
#import "HMScannerController.h"
#import "IGCMenu.h"
@interface ViewController ()
<WDGVideoCallDelegate, WDGConversationDelegate, UITextFieldDelegate,IGCMenuDelegate>
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, copy) NSString *callID;
@property (nonatomic, strong) UITextField *textFile;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *shaoBtn;
@property (nonatomic, strong) IGCMenu *igcMenu;
@property (nonatomic, strong) UIView *buttonView;

@end

@implementation ViewController

-(long int)getRandomNumber:(long int)from to:(long int)to
{
    return (long int)(from + (arc4random() % (to - from + 1)));
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(KMainScreenWidth/2 - 75 * widthScale, 80 * widthScale, 150 * widthScale, 150 * widthScale)];
    self.logoView.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:self.logoView];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg"].CGImage);
    [self.view addSubview:self.textFile];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(40 * widthScale, KMainScreenHeight/2 - 44 * widthScale, KMainScreenWidth - 80 * widthScale, 2)];
    lable.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lable];
    [self.view addSubview:self.loginBtn];
    [self.view addSubview:self.buttonView];

    [self.buttonView addSubview:self.shaoBtn];
     [self statrCreat];
     [self setupMenu];
}
- (void)statrCreat{
    //初始化 Auth SDK
    //wd2594166845uulehn
    NSString *appUrlID = @"wd2594166845uulehn";
    WDGOptions *options = [[WDGOptions alloc] initWithSyncURL:[NSString stringWithFormat:@"https://%@.wilddogio.com", appUrlID]];
    [WDGApp configureWithOptions:options];
    WDGAuth *auth = [WDGAuth auth];
    //注册
    NSString *appID = @"";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"username"] == nil) {
        appID = [NSString stringWithFormat:@"%ld@qq.com",  [self getRandomNumber:10000 to:100000]];
        //创建一个基于密码的帐户，创建成功后会自动登录
        [auth createUserWithEmail:appID password:appID completion:^(WDGUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"注册成功");
                //                  [self login:appID];
                [userDefaults setValue:appID forKey:@"username"];
            [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"注册成功"];
            }else{
                 [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"重试注册请稍等"];
         
               [self statrCreat];
            }
        }];
        
    }
    
}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [self.conversation close];
//
//    NSError *error = nil;
//    [[WDGAuth auth] signOut:&error];
//    if (!error) {
//        // 退出登录成功
//
//    }
//}
- (UITextField *)textFile{
    if (_textFile == nil) {
        self.textFile = [[UITextField alloc] initWithFrame:CGRectMake(40 * widthScale, KMainScreenHeight/2 - 80 * widthScale, KMainScreenWidth - 80 * widthScale, 40 * widthScale)];
        self.textFile.backgroundColor = [UIColor clearColor];
        self.textFile.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textFile.delegate = self;
        self.textFile.font = [UIFont systemFontOfSize:16 * widthScale weight:0.3];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"callID"] != nil) {
            self.textFile.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"callID"];
        }
        self.textFile.text = @"6a13d042afc7062459fcf7f069dd";
        self.textFile.textColor = [UIColor whiteColor];
        self.textFile.textAlignment = NSTextAlignmentCenter;
        // 创建一个富文本对象
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        // 设置富文本对象的颜色
        attributes[NSForegroundColorAttributeName] =  [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
        
        attributes[NSFontAttributeName] = [UIFont fontWithName:@"Helvetica-Oblique" size:16* widthScale];
        // 设置UITextField的占位文字
        self.textFile.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入被控ID" attributes:attributes];
    }
    return _textFile;
}
- (void)shaoAction:(UIButton *)btn{
    
    if (btn.selected == NO) {
        btn.selected = YES;
          [_igcMenu showLineMenu];
        
    }else{
            btn.selected = NO;
          [_igcMenu hideLineMenu];
    }
    
    
//    NSString *cardName = @"";
//    UIImage *avatar = [UIImage imageNamed:@"avatar"];
//
//    HMScannerController *scanner = [HMScannerController scannerWithCardName:cardName avatar:avatar completion:^(NSString *stringValue) {
//        NSLog(@"%@", stringValue);
//        self.textFile.text = stringValue;
//    }];
//
//    [scanner setTitleColor:[UIColor whiteColor] tintColor:[UIColor greenColor]];
//
//    [self showDetailViewController:scanner sender:nil];
    
}
- (UIButton *)loginBtn{
    if (_loginBtn == nil) {
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.loginBtn.frame = CGRectMake(KMainScreenWidth/2- 40 * widthScale ,  KMainScreenHeight/2,80 * widthScale ,40 * widthScale);
        self.loginBtn.backgroundColor =[UIColor clearColor];
        [self.loginBtn setTitle:@"登录" forState:0];
        self.loginBtn.layer.borderWidth = 2;
        self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:15 * widthScale weight:0.3];
        self.loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.loginBtn.layer.cornerRadius = 5* widthScale;
        [self.loginBtn addTarget:self action:@selector(avAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}
- (UIButton *)shaoBtn{
    if (_shaoBtn == nil) {
        self.shaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shaoBtn.frame = CGRectMake(10 * widthScale ,  130 * widthScale
                                         ,50 * widthScale ,50 * widthScale);
        [self.shaoBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
        [self.shaoBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateHighlighted];
        [self.shaoBtn addTarget:self action:@selector(shaoAction:) forControlEvents:UIControlEventTouchUpInside];
        self.shaoBtn.selected = NO;
    }
    return _shaoBtn;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textFile endEditing:YES];
    return YES;
}
- (void)avAction{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showLoadToView:self.view];

    });
    self.callID = self.textFile.text;
    if (self.callID.length <=0) {
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"添加被控ID"];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:self.callID forKey:@"callID"];
    CallViewController *callV = [[CallViewController alloc] init];
    callV.callID = self.callID;
    [self presentViewController:callV animated:YES completion:nil];
}


- (UIView *)buttonView{
    if (_buttonView == nil) {
        self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(KMainScreenWidth - 80 * kwidthScale, KMainScreenHeight - 200* kwidthScale, 80* kwidthScale, 200* kwidthScale)];
    }
    return _buttonView;
}
-(void)setupMenu{
    self.shaoBtn.clipsToBounds = YES;
    self.shaoBtn.layer.cornerRadius = self.shaoBtn.frame.size.height / 2;
    if (_igcMenu == nil) {
        _igcMenu = [[IGCMenu alloc] init];

    }
   
    _igcMenu.menuButton = self.shaoBtn;   //Pass refernce of menu button
    _igcMenu.menuSuperView = self.buttonView;      //Pass reference of menu button super view
    _igcMenu.disableBackground = YES;        //Enable/disable menu background
    _igcMenu.numberOfMenuItem = 2;           //Number of menu items to display
    
    //Menu background. It can be BlurEffectExtraLight,BlurEffectLight,BlurEffectDark,Dark or None
    _igcMenu.backgroundType = None;
    _igcMenu.menuHeight = 50;
    /* Optional
     Pass name of menu items
     **/
    _igcMenu.menuItemsNameArray = [NSArray arrayWithObjects:@"saoma",@"setting",nil];
    
    /*Optional
     Pass color of menu items
     **/
    UIColor *homeBackgroundColor = [UIColor clearColor];
    UIColor *searchBackgroundColor = [UIColor clearColor];
  
    _igcMenu.menuBackgroundColorsArray = [NSArray arrayWithObjects:homeBackgroundColor,searchBackgroundColor,nil];
    
    /*Optional
     Pass menu items icons
     **/
    _igcMenu.menuImagesNameArray = [NSArray arrayWithObjects:@"saoma.png",@"setting.png",nil];
    
    /*Optional if you don't want to get notify for menu items selection
     conform delegate
     **/
    _igcMenu.delegate = self;
}
- (void)igcMenuSelected:(NSString *)selectedMenuName atIndex:(NSInteger)index{
    
  
    switch (index) {
        case 0:
        {
                NSString *cardName = @"";
                UIImage *avatar = [UIImage imageNamed:@"avatar"];
            
                HMScannerController *scanner = [HMScannerController scannerWithCardName:cardName avatar:avatar completion:^(NSString *stringValue) {
                    NSLog(@"%@", stringValue);
                    self.textFile.text = stringValue;
                }];
            
                [scanner setTitleColor:[UIColor whiteColor] tintColor:[UIColor greenColor]];
            
                [self showDetailViewController:scanner sender:nil];
        }
        
            break;
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
        default:
            break;
    }
}

@end
