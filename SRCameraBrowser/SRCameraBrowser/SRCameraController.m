//
//  SRCameraController.m
//  SRPhotoProcess
//
//  Created by SarielTang on 15/8/11.
//  Copyright (c) 2015年 Sariel. All rights reserved.
//

#import "SRCameraController.h"
#import "FastttCamera.h"
#import "Masonry.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface SRCameraController ()<FastttCameraDelegate,MWPhotoBrowserDelegate>
@property (nonatomic, strong) FastttCamera *fastCamera;

@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *torchButton;
@property (nonatomic, strong) UIButton *switchCameraButton;

@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation SRCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    _fastCamera = [FastttCamera new];
    self.fastCamera.delegate = self;
    
    [self fastttAddChildViewController:self.fastCamera];
    [self.fastCamera.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).offset(-120.0f);
    }];
    
    _takePhotoButton = [UIButton new];
    [self.takePhotoButton addTarget:self
                             action:@selector(takePhotoButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self.takePhotoButton setTitle:@"拍照"
                          forState:UIControlStateNormal];
    
    [self.view addSubview:self.takePhotoButton];
    [self.takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20.f);
    }];
    
    _flashButton = [UIButton new];
    self.flashButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.flashButton.titleLabel.numberOfLines = 0;
    [self.flashButton addTarget:self
                         action:@selector(flashButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.flashButton setTitle:@"打开闪光灯"
                      forState:UIControlStateNormal];
    
    [self.fastCamera setCameraFlashMode:FastttCameraFlashModeOff];
    
    [self.view addSubview:self.flashButton];
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.left.equalTo(self.view).offset(20.f);
    }];
    
    _switchCameraButton = [UIButton new];
    self.switchCameraButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.switchCameraButton.titleLabel.numberOfLines = 0;
    [self.switchCameraButton addTarget:self
                                action:@selector(switchCameraButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.switchCameraButton setTitle:@"切换摄像头"
                             forState:UIControlStateNormal];
    
    [self.fastCamera setCameraDevice:FastttCameraDeviceRear];
    
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.right.equalTo(self.view).offset(-20.f);
        make.size.equalTo(self.flashButton);
    }];
    
    _torchButton = [UIButton new];
    self.torchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.torchButton.titleLabel.numberOfLines = 0;
    [self.torchButton addTarget:self
                         action:@selector(torchButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.torchButton setTitle:@"打开背景灯"
                      forState:UIControlStateNormal];
    
    [self.fastCamera setCameraTorchMode:FastttCameraTorchModeOff];
    [self.view addSubview:self.torchButton];
    [self.torchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20.f);
        make.left.equalTo(self.flashButton.mas_right).offset(20.f);
        make.right.equalTo(self.switchCameraButton.mas_left).offset(-20.f);
        make.size.equalTo(self.flashButton);
    }];

}

- (void)takePhotoButtonPressed
{
    NSLog(@"点击拍照");
    
    [self.fastCamera takePicture];
}

- (void)flashButtonPressed
{
    NSLog(@"点击闪光灯");
    
    FastttCameraFlashMode flashMode;
    NSString *flashTitle;
    switch (self.fastCamera.cameraFlashMode) {
        case FastttCameraFlashModeOn:
            flashMode = FastttCameraFlashModeOff;
            flashTitle = @"打开闪光灯";
            break;
        case FastttCameraFlashModeOff:
        default:
            flashMode = FastttCameraFlashModeOn;
            flashTitle = @"关闭闪光灯";
            break;
    }
    if ([self.fastCamera isFlashAvailableForCurrentDevice]) {
        [self.fastCamera setCameraFlashMode:flashMode];
        [self.flashButton setTitle:flashTitle forState:UIControlStateNormal];
    }
}

- (void)torchButtonPressed
{
    NSLog(@"点击背景灯");
    
    FastttCameraTorchMode torchMode;
    NSString *torchTitle;
    switch (self.fastCamera.cameraTorchMode) {
        case FastttCameraTorchModeOn:
            torchMode = FastttCameraTorchModeOff;
            torchTitle = @"打开背景灯";
            break;
        case FastttCameraTorchModeOff:
        default:
            torchMode = FastttCameraTorchModeOn;
            torchTitle = @"关闭背景灯";
            break;
    }
    if ([self.fastCamera isTorchAvailableForCurrentDevice]) {
        [self.fastCamera setCameraTorchMode:torchMode];
        [self.torchButton setTitle:torchTitle forState:UIControlStateNormal];
    }
}

- (void)switchCameraButtonPressed
{
    NSLog(@"切换摄像头");
    
    FastttCameraDevice cameraDevice;
    switch (self.fastCamera.cameraDevice) {
        case FastttCameraDeviceFront:
            cameraDevice = FastttCameraDeviceRear;
            break;
        case FastttCameraDeviceRear:
        default:
            cameraDevice = FastttCameraDeviceFront;
            break;
    }
    if ([FastttCamera isCameraDeviceAvailable:cameraDevice]) {
        [self.fastCamera setCameraDevice:cameraDevice];
        if (![self.fastCamera isFlashAvailableForCurrentDevice]) {
            [self.flashButton setTitle:@"打开闪光灯" forState:UIControlStateNormal];
        }
    }
}

- (void)savePhotoToCameraRollWithImage:(UIImage *)image
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                              orientation:(ALAssetOrientation)[image imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error){
                              if (error) {
                                  NSLog(@"Error saving photo: %@", error.localizedDescription);
                              } else {
                                  NSLog(@"Saved photo to saved photos album.");
                              }
                          }];
}

#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(FastttCamera *)cameraController
 didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
    /**
     *  Here, capturedImage.fullImage contains the full-resolution captured
     *  image, while capturedImage.rotatedPreviewImage contains the full-resolution
     *  image with its rotation adjusted to match the orientation in which the
     *  image was captured.
     */
//    [self savePhotoToCameraRollWithImage:capturedImage.fullImage];
    NSLog(@"原始图片大小：%zd",UIImageJPEGRepresentation(capturedImage.fullImage, 1.0).length/1024);
}

- (void)cameraController:(FastttCamera *)cameraController
didFinishScalingCapturedImage:(FastttCapturedImage *)capturedImage
{
    /**
     *  Here, capturedImage.scaledImage contains the scaled-down version
     *  of the image.
     */
    [self savePhotoToCameraRollWithImage:capturedImage.scaledImage];
    NSLog(@"压缩图片大小：%zdKB",UIImageJPEGRepresentation(capturedImage.scaledImage, 1.0).length/1024);
}

- (void)cameraController:(FastttCamera *)cameraController
didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage
{
    /**
     *  Here, capturedImage.fullImage and capturedImage.scaledImage have
     *  been rotated so that they have image orientations equal to
     *  UIImageOrientationUp. These images are ready for saving and uploading,
     *  as they should be rendered more consistently across different web
     *  services than images with non-standard orientations.
     */
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    // Photos
    photo = [MWPhoto photoWithImage:capturedImage.scaledImage];
    photo.caption = @"感谢您使用斑马王国app，希望能带给您良好的体验。";
    [photos addObject:photo];
    
    self.photos = photos;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    [self.navigationController pushViewController:browser animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

@end
