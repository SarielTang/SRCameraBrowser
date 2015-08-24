//
//  ViewController.m
//  SRCameraBrowser
//
//  Created by SarielTang on 15/8/24.
//  Copyright (c) 2015年 Sariel. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc]init];
    [self.view addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick:(UIButton *)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
