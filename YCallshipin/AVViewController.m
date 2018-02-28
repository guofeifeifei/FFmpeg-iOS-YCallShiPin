//
//  AVViewController.m
//  YCallshipin
//
//  Created by ZZCN77 on 2017/10/19.
//  Copyright © 2017年 ZZCN77. All rights reserved.
//

#import "AVViewController.h"
#import "ZGLVideoPlyer.h"

@interface AVViewController ()
@property (nonatomic, strong) ZGLVideoPlyer *player;

@end

@implementation AVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat deviceWith = [UIScreen mainScreen].bounds.size.width;
//    self.player = [[ZGLVideoPlyer alloc] initWithFrame:CGRectMake(0, 0, deviceWith, KMainScreenWidth)];
//    self.player.videoUrlStr = self.strPath;
//    [self.view addSubview:self.player];
//    
//    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(KMainScreenWidth - 40 * widthScale, 10 * widthScale, 30 * widthScale, 30 * widthScale)];
//    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
}
- (void)backAction{
   
    [self dismissViewControllerAnimated:YES completion:nil];
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
