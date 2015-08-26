//
//  ViewController.m
//  SRCameraBrowser
//
//  Created by SarielTang on 15/8/24.
//  Copyright (c) 2015年 Sariel. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "SRCameraController.h"
#import "SRPhotoBrowser.h"

@interface ViewController ()<UIActionSheetDelegate>
{
    UIButton *_uploadBtn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc]init];
    _uploadBtn = btn;
    [self.view addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)btnClick:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"上传图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相机" otherButtonTitles:@"从相册选择", nil];
    actionSheet.tag = 200;
    [actionSheet showFromRect:CGRectMake(160, 568, 320, 120) inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag==200)
    {
        switch (buttonIndex)
        {
            case 0://拍照
                NSLog(@"拍照");
                //判断相机、相册是否可用
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"相机无法使用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
                else
                {
                    SRCameraController *vc = [[SRCameraController alloc]init];
                    vc.uploadBtn = _uploadBtn;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            case 1://从相册选择
                NSLog(@"从相册选择");
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    NSLog(@"图片库可用");
                    SRPhotoBrowser *vc = [[SRPhotoBrowser alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"图片库不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
                break;
            case 2://取消
            {
                
            }
                break;
                
            default:
                break;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
